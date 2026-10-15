import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teybatseller/core/errors/failures.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/network/promos_api.dart';
import 'package:teybatseller/core/network/restaurant_api.dart';
import 'package:teybatseller/core/providers/providers.dart';
import 'package:teybatseller/core/services/cloudinary_service.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';
import 'package:teybatseller/features/menu/presentation/widgets/image_picker_widget.dart';
import 'package:teybatseller/features/promotions/application/promos_notifier.dart';
import 'package:teybatseller/features/promotions/data/models/promo_banner.dart';
import 'package:teybatseller/features/promotions/data/repositories/promos_repository.dart';
import 'package:teybatseller/features/promotions/presentation/screens/promotion_editor_screen.dart';
import 'package:teybatseller/features/promotions/presentation/screens/promotions_screen.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';
import 'package:teybatseller/features/restaurant/data/models/restaurant_model.dart';
import 'promos_contract_test.dart' show promo;

class UiRepository extends PromosRepository {
  UiRepository() : super(PromosApi(Dio()));
  PromoBanner? existing;
  final saves = <Map<String, Object?>>[];
  @override
  Future<PaginatedResponse<PromoBanner>> list(
    String restaurantId, {
    int page = 1,
  }) async => PaginatedResponse(
    count: existing == null ? 0 : 1,
    results: existing == null ? [] : [existing!],
  );
  @override
  Future<PromoBanner> detail(String id) async => existing!;
  @override
  Future<PromoBanner> save({
    String? id,
    required String restaurantId,
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    saves.add({
      'id': id,
      'restaurantId': restaurantId,
      'title': title,
      'imageUrl': imageUrl,
    });
    return promo();
  }
}

class FakePicker extends ImagePicker {
  FakePicker(this.bytes);
  final Uint8List bytes;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => XFile.fromData(bytes, name: 'banner.png', mimeType: 'image/png');
}

class FakeCloudinary extends CloudinaryService {
  FakeCloudinary() : super(Dio());
  final result = Completer<CloudinaryResult>();
  @override
  Future<CloudinaryResult> uploadImageFromBytes(
    Uint8List bytes, {
    required String fileName,
    void Function(double progress)? onProgress,
  }) {
    onProgress?.call(.5);
    return result.future;
  }
}

Future<void> pumpUi(WidgetTester tester) async {
  // Network-image placeholders may animate while mocked API state is settled.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final session = SessionLifecycle.instance;
  late UiRepository repository;
  late FakeCloudinary cloudinary;
  late Uint8List png;
  late GoRouter router;
  setUp(() async {
    await session.end(() async {});
    session.accept(await session.beginLogin());
    await TranslationService.instance.load(const Locale('en'));
    repository = UiRepository();
    cloudinary = FakeCloudinary();
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.green, BlendMode.src);
    final image = await recorder.endRecording().toImage(32, 14);
    png = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    image.dispose();
  });
  tearDown(() {
    router.dispose();
  });
  Future<void> open(
    WidgetTester tester, {
    bool edit = false,
    bool list = false,
    bool arabic = false,
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (arabic) {
      await tester.runAsync(
        () => TranslationService.instance.load(const Locale('ar')),
      );
    }
    cloudinary = FakeCloudinary();
    router = GoRouter(
      initialLocation: list ? '/profile/promotions' : '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          builder: (_, _) => Directionality(
            textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
            child: PromotionEditorScreen(promoId: edit ? '1' : null),
          ),
        ),
        GoRoute(
          path: '/profile/promotions',
          builder: (_, _) => Directionality(
            textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
            child: const PromotionsScreen(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          promosRepositoryProvider.overrideWithValue(repository),
          selectedRestaurantIdProvider.overrideWithValue('7'),
          selectedRestaurantProvider.overrideWithValue(
            const RestaurantModel(id: '7', name: 'Seed Restaurant'),
          ),
          cloudinaryServiceProvider.overrideWithValue(cloudinary),
          imagePickerProvider.overrideWithValue(FakePicker(png)),
        ],
        child: ScreenUtilInit(
          designSize: Size(width, 844),
          builder: (_, _) => MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await pumpUi(tester);
  }

  Future<void> pick(WidgetTester tester) async {
    await tester.ensureVisible(find.text('menu.addImage'.tr));
    await tester.tap(find.text('menu.addImage'.tr));
    await pumpUi(tester);
    await tester.tap(find.text('menu.gallery'.tr));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
    'create requires an image and title without making a backend request',
    (tester) async {
      await open(tester);
      await tester.pump();
      await tester.ensureVisible(find.text('Submit for review'));
      await tester.tap(find.text('Submit for review'));
      await tester.pump();
      await tester.pump();
      expect(
        find.text('Add a banner image before submitting.'),
        findsOneWidget,
      );
      expect(find.text('Enter a headline.'), findsOneWidget);
      expect(repository.saves, isEmpty);
    },
  );

  testWidgets(
    'upload blocks submit and successful upload URL is sent for review',
    (tester) async {
      await open(tester);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Weekend flavors',
      );
      await pick(tester);
      expect(find.text('Uploading image…'), findsOneWidget);
      final button = find
          .ancestor(
            of: find.text('Uploading image…'),
            matching: find.byWidgetPredicate((w) => w is FilledButton),
          )
          .first;
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.runAsync(() async {
        cloudinary.result.complete((
          failure: null,
          imageUrl: 'https://example.test/banner.png',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await pumpUi(tester);
      expect(
        find.text('Submit for review'),
        findsOneWidget,
        reason: tester.allWidgets
            .whereType<Text>()
            .map((w) => w.data)
            .join(' | '),
      );
      await tester.pump();
      await tester.ensureVisible(find.text('Submit for review'));
      await tester.tap(find.text('Submit for review'));
      await tester.pump();
      await pumpUi(tester);
      expect(repository.saves.single, {
        'id': null,
        'restaurantId': '7',
        'title': 'Weekend flavors',
        'imageUrl': 'https://example.test/banner.png',
      });
      expect(find.byType(PromotionsScreen), findsOneWidget);
    },
  );

  testWidgets(
    'failed upload keeps the form editable and does not submit an image',
    (tester) async {
      await open(tester);
      await pick(tester);
      await tester.runAsync(() async {
        cloudinary.result.complete((
          failure: const NetworkFailure(message: 'Upload unavailable'),
          imageUrl: null,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await pumpUi(tester);
      await tester.pump();
      await tester.ensureVisible(find.text('Submit for review'));
      await tester.tap(find.text('Submit for review'));
      await tester.pump();
      await tester.pump();
      expect(
        find.text('Add a banner image before submitting.'),
        findsOneWidget,
      );
      expect(repository.saves, isEmpty);
    },
  );

  testWidgets(
    'editing a live banner explains re-review and requires actual changes',
    (tester) async {
      repository.existing = promo(status: 'APPROVED', active: true);
      await open(tester, edit: true);
      expect(
        find.text(
          'Saving changes will pause this live banner and send it for review again.',
        ),
        findsOneWidget,
      );
      final button = find
          .ancestor(
            of: find.text('Resubmit for review'),
            matching: find.byWidgetPredicate((w) => w is FilledButton),
          )
          .first;
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.enterText(find.byType(TextFormField).first, 'New flavors');
      await tester.pump();
      await tester.ensureVisible(find.text('Resubmit for review'));
      await tester.tap(find.text('Resubmit for review'));
      await pumpUi(tester);
      expect(repository.saves.single['id'], '1');
    },
  );

  testWidgets('leaving a changed form asks before discarding it', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Draft');
    await tester.tap(find.byTooltip('Back'));
    await pumpUi(tester);
    expect(find.text('Discard your changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await pumpUi(tester);
    expect(find.text('Draft'), findsOneWidget);
    expect(repository.saves, isEmpty);
  });

  testWidgets('Arabic mobile empty state and editor do not overflow', (
    tester,
  ) async {
    await open(tester, list: true, arabic: true, width: 360);
    expect(find.text('ابدأ بلافتتك الأولى'), findsOneWidget);
    expect(tester.takeException(), isNull);
    router.go('/editor');
    await pumpUi(tester);
    expect(find.text('صورة اللافتة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('approved desktop banner has publish and edit controls', (
    tester,
  ) async {
    repository.existing = promo(status: 'APPROVED');
    await open(tester, list: true, width: 1100);
    expect(find.text('Approved · Paused'), findsOneWidget);
    expect(find.text('Publish'), findsOneWidget);
    expect(find.byTooltip('Edit promotion'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
