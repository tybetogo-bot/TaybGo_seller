import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/network/promos_api.dart';
import 'package:teybatseller/core/network/restaurant_api.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';
import 'package:teybatseller/features/promotions/application/promos_notifier.dart';
import 'package:teybatseller/features/promotions/data/models/promo_banner.dart';
import 'package:teybatseller/features/promotions/data/repositories/promos_repository.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';

Map<String, dynamic> row({
  String id = '1',
  String restaurant = '7',
  String status = 'PENDING',
  bool active = false,
}) => {
  'id': id,
  'restaurant': restaurant,
  'title': 'Fresh flavors',
  'description': null,
  'image_url': 'https://example.test/banner.png',
  'status': status,
  'is_active': active,
  'rejection_reason': status == 'REJECTED' ? 'Use a clearer image' : null,
};
PromoBanner promo({
  String id = '1',
  String restaurant = '7',
  String status = 'PENDING',
  bool active = false,
}) => PromoBanner.fromJson(
  row(id: id, restaurant: restaurant, status: status, active: active),
);

class RestaurantChoice extends Notifier<String?> {
  @override
  String? build() => '7';
  void choose(String id) => state = id;
}

final restaurantChoice = NotifierProvider<RestaurantChoice, String?>(
  RestaurantChoice.new,
);

class FakeRepository extends PromosRepository {
  FakeRepository() : super(PromosApi(Dio()));
  final calls = <(String, int)>[];
  Future<PaginatedResponse<PromoBanner>> Function(String, int)? respond;
  int publications = 0;
  @override
  Future<PaginatedResponse<PromoBanner>> list(
    String restaurantId, {
    int page = 1,
  }) {
    calls.add((restaurantId, page));
    return respond?.call(restaurantId, page) ??
        Future.value(
          PaginatedResponse(count: 1, results: [promo(status: 'APPROVED')]),
        );
  }

  @override
  Future<PromoBanner> setActive(String id, bool active) async {
    publications++;
    return promo(id: id, status: 'APPROVED', active: active);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await TranslationService.instance.load(const Locale('en'));
  });
  test(
    'approval is distinct from publication and rejected banners retain feedback',
    () {
      expect(
        promo(status: 'APPROVED').displayStatus,
        PromoDisplayStatus.paused,
      );
      expect(
        promo(status: 'APPROVED', active: true).displayStatus,
        PromoDisplayStatus.live,
      );
      expect(promo().canPublish, isFalse);
      expect(
        promo(status: 'REJECTED', active: true).displayStatus,
        PromoDisplayStatus.rejected,
      );
      expect(promo(status: 'REJECTED').rejectionReason, 'Use a clearer image');
      expect(promo(status: 'APPROVED').needsReviewOnEdit, isTrue);
      expect(promo().needsReviewOnEdit, isFalse);
    },
  );

  test(
    'API uses restaurant-scoped listing and correct create/edit/action payloads',
    () async {
      final dio = Dio();
      final requests = <RequestOptions>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: options.method == 'GET'
                    ? {
                        'count': 1,
                        'next': null,
                        'previous': null,
                        'results': [row()],
                      }
                    : row(),
              ),
            );
          },
        ),
      );
      final api = PromosApi(dio);
      expect((await api.list('7')).results.single.restaurantId, '7');
      expect(requests.last.queryParameters, {'restaurant_id': '7', 'page': 1});
      await api.save(
        restaurantId: '7',
        title: ' Headline ',
        description: ' Details ',
        imageUrl: 'https://example.test/image.png',
      );
      expect(requests.last.path, '/api/seller/promos/');
      expect(requests.last.data, {
        'restaurant_id': 7,
        'title': 'Headline',
        'description': 'Details',
        'image_url': 'https://example.test/image.png',
      });
      expect(requests.last.extra['disableRetry'], isTrue);
      await api.save(
        id: '1',
        restaurantId: '7',
        title: 'Edited',
        description: '',
        imageUrl: 'https://example.test/image.png',
      );
      expect(requests.last.method, 'PATCH');
      expect((requests.last.data as Map).containsKey('restaurant_id'), isFalse);
      await api.setActive('1', true);
      expect(requests.last.path, '/api/seller/promos/1/activate/');
      await api.setActive('1', false);
      expect(requests.last.path, '/api/seller/promos/1/deactivate/');
      await api.delete('1');
      expect(requests.last.method, 'DELETE');
    },
  );

  test('unpaginated backend lists are also supported', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) =>
              h.resolve(Response(requestOptions: o, data: [row()])),
        ),
      );
    expect((await PromosApi(dio).list('7')).results.length, 1);
  });

  group('session and restaurant ownership', () {
    final session = SessionLifecycle.instance;
    late FakeRepository repository;
    late ProviderContainer container;
    late ProviderSubscription<PromosState> subscription;
    setUp(() async {
      await session.end(() async {});
      session.accept(await session.beginLogin());
      repository = FakeRepository();
      container = ProviderContainer(
        overrides: [
          selectedRestaurantIdProvider.overrideWith(
            (ref) => ref.watch(restaurantChoice),
          ),
          promosRepositoryProvider.overrideWithValue(repository),
        ],
      );
      subscription = container.listen(promosProvider, (_, _) {});
    });
    tearDown(() {
      subscription.close();
      container.dispose();
    });
    test(
      'publishing an approved banner updates the list from the server',
      () async {
        await Future<void>.delayed(Duration.zero);
        expect(
          await container
              .read(promosProvider.notifier)
              .change(promo(status: 'APPROVED'), active: true),
          isNull,
        );
        expect(
          container.read(promosProvider).items.single.displayStatus,
          PromoDisplayStatus.live,
        );
        expect(repository.publications, 1);
        expect(
          await container
              .read(promosProvider.notifier)
              .change(promo(), active: true),
          isNotNull,
        );
        expect(repository.publications, 1);
      },
    );
    test(
      'late restaurant response cannot restore a previous restaurant',
      () async {
        final old = Completer<PaginatedResponse<PromoBanner>>();
        repository.respond = (restaurant, page) => restaurant == '7'
            ? old.future
            : Future.value(
                PaginatedResponse(count: 1, results: [promo(restaurant: '8')]),
              );
        await Future<void>.delayed(Duration.zero);
        container.read(restaurantChoice.notifier).choose('8');
        await container.pump();
        await Future<void>.delayed(Duration.zero);
        old.complete(PaginatedResponse(count: 1, results: [promo()]));
        await Future<void>.delayed(Duration.zero);
        expect(container.read(promosProvider).items.single.restaurantId, '8');
      },
    );
    test('late account response cannot repopulate signed-out state', () async {
      final old = Completer<PaginatedResponse<PromoBanner>>();
      repository.respond = (_, _) => old.future;
      await Future<void>.delayed(Duration.zero);
      await session.end(() async {});
      await container.pump();
      old.complete(PaginatedResponse(count: 1, results: [promo()]));
      await Future<void>.delayed(Duration.zero);
      expect(container.read(promosProvider).items, isEmpty);
    });
    test(
      'pagination retains and deduplicates previously loaded banners',
      () async {
        repository.respond = (restaurant, page) => Future.value(
          PaginatedResponse(
            count: 2,
            next: page == 1 ? '/api/seller/promos/?page=2' : null,
            results: page == 1 ? [promo()] : [promo(), promo(id: '2')],
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await container.read(promosProvider.notifier).refresh(more: true);
        expect(container.read(promosProvider).items.map((p) => p.id), [
          '1',
          '2',
        ]);
        expect(container.read(promosProvider).nextPage, isNull);
      },
    );
  });
}
