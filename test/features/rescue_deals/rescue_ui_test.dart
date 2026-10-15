import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teybatseller/app/router/routes.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';
import 'package:teybatseller/core/theme/app_theme.dart';
import 'package:teybatseller/features/rescue_deals/application/rescue_deals_notifier.dart';
import 'package:teybatseller/features/rescue_deals/presentation/widgets/rescue_widgets.dart';
import 'package:teybatseller/features/rescue_deals/presentation/screens/rescue_deals_screen.dart';
import 'package:teybatseller/features/rescue_deals/presentation/screens/rescue_deal_details_screen.dart';
import 'package:teybatseller/features/rescue_deals/presentation/screens/rescue_deal_editor_screen.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';
import 'package:teybatseller/features/restaurant/data/models/restaurant_model.dart';
import 'rescue_contract_test.dart' show choiceProvider;
import 'rescue_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RescueUiRepository repository;
  late GoRouter router;
  ProviderContainer? container;
  setUpAll(() async {
    final loader = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await loader.load();
  });
  setUp(() async {
    await SessionLifecycle.instance.end(() async {});
    SessionLifecycle.instance.accept(
      await SessionLifecycle.instance.beginLogin(),
    );
    await TranslationService.instance.load(const Locale('en'));
    GoogleFonts.config.allowRuntimeFetching = false;
    repository = RescueUiRepository();
  });
  tearDown(() => router.dispose());

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> open(
    WidgetTester tester, {
    String? location,
    double width = 390,
    bool arabic = false,
    bool dark = false,
    double textScale = 1,
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
    router = GoRouter(
      initialLocation: location ?? Routes.rescueDeals,
      routes: [
        GoRoute(
          path: Routes.rescueDeals,
          builder: (_, _) => const RescueDealsScreen(),
        ),
        GoRoute(
          path: Routes.addRescueDeal,
          builder: (_, _) => const RescueDealEditorScreen(),
        ),
        GoRoute(
          path: Routes.editRescueDeal,
          builder: (_, state) =>
              RescueDealEditorScreen(dealId: state.pathParameters['dealId']!),
        ),
        GoRoute(
          path: Routes.rescueDealDetails,
          builder: (_, state) =>
              RescueDealDetailsScreen(dealId: state.pathParameters['dealId']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rescueDealsRepositoryProvider.overrideWithValue(repository),
          selectedRestaurantIdProvider.overrideWith(
            (ref) => ref.watch(choiceProvider),
          ),
          selectedRestaurantProvider.overrideWithValue(
            const RestaurantModel(id: '7', name: 'Olive & Thyme Kitchen'),
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return ScreenUtilInit(
              designSize: Size(width <= 480 ? 375 : width / 1.28, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, _) => RepaintBoundary(
                key: const ValueKey('rescue-preview'),
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  routerConfig: router,
                  locale: Locale(arabic ? 'ar' : 'en'),
                  supportedLocales: const [Locale('en'), Locale('ar')],
                  localizationsDelegates: GlobalMaterialLocalizations.delegates,
                  theme: dark ? AppTheme.dark : AppTheme.light,
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(textScale)),
                    child: RescueTheme(child: child!),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await settle(tester);
    await tester.runAsync(() => GoogleFonts.pendingFonts());
    await settle(tester);
  }

  Future<void> chooseItem(WidgetTester tester) async {
    await tester.tap(find.text('Choose a menu item'));
    await settle(tester);
    await tester.tap(find.text('Roasted vegetable bowl').last);
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('rescue-quantity')), '10');
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('RESCUE_PREVIEWS')) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('rescue-preview')),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        '/private/tmp/rescue-$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('mobile list has clear prices, stock and status', (tester) async {
    repository.rows.add({
      ...rescueRow(id: '2', name: 'Chicken & rice box'),
      'deal_price': '5.50',
      'is_active': false,
    });
    await open(tester);
    expect(find.text('Good food, less waste.'), findsOneWidget);
    expect(find.text('€6.00'), findsOneWidget);
    expect(find.text('7 portions left'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    await capture(tester, 'mobile-list');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'create validates price and sends cents as decimals and dates in UTC',
    (tester) async {
      await open(tester, location: Routes.addRescueDeal);
      await chooseItem(tester);
      await tester.enterText(
        find.byKey(const ValueKey('rescue-price')),
        '12.00',
      );
      await tester.tap(find.text('Publish deal'));
      await settle(tester);
      expect(repository.saves, isEmpty);
      expect(
        find.text('Enter a price above zero and below the menu price.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('rescue-price')),
        '6,25',
      );
      await tester.tap(find.text('Publish deal'));
      await settle(tester);
      final data = repository.saves.single;
      expect(data['deal_price'], '6.25');
      expect(data['restaurant_id'], 7);
      expect(data['item_id'], 21);
      expect(data['starts_at'].toString(), endsWith('Z'));
      expect(data['ends_at'].toString(), endsWith('Z'));
      expect(data, isNot(contains('original_price_snapshot')));
      expect(data, isNot(contains('remaining_qty')));
      expect(find.byType(RescueDealDetailsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('field errors keep the entered draft editable', (tester) async {
    repository.saveError = DioException(
      requestOptions: RequestOptions(path: '/'),
      response: Response(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 400,
        data: {
          'deal_price': ['The menu price changed. Choose a lower price.'],
        },
      ),
    );
    await open(tester, location: Routes.addRescueDeal);
    await chooseItem(tester);
    await tester.enterText(find.byKey(const ValueKey('rescue-price')), '6.25');
    await tester.tap(find.text('Publish deal'));
    await settle(tester);
    expect(
      find.text('The menu price changed. Choose a lower price.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('rescue-price')))
          .controller!
          .text,
      '6.25',
    );
    expect(find.byType(RescueDealEditorScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'stock removal rejects reserved stock and uses signed adjustments',
    (tester) async {
      await open(tester, location: Routes.rescueDealPath('1'));
      await tester.ensureVisible(find.text('Adjust portions'));
      await tester.tap(find.text('Adjust portions'));
      await settle(tester);
      await tester.tap(find.text('Remove'));
      await tester.enterText(find.byType(TextField).last, '8');
      await tester.tap(find.text('Confirm adjustment'));
      await settle(tester);
      expect(repository.stockCalls, isEmpty);
      await tester.enterText(find.byType(TextField).last, '3');
      await tester.tap(find.text('Confirm adjustment'));
      await settle(tester);
      expect(repository.stockCalls, [-3]);
      expect(repository.rows.first['remaining_qty'], 4);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('archive explains retained history and updates details', (
    tester,
  ) async {
    await open(tester, location: Routes.rescueDealPath('1'));
    await tester.ensureVisible(find.text('Archive deal'));
    await tester.tap(find.text('Archive deal'));
    await settle(tester);
    expect(find.textContaining('order history will remain'), findsOneWidget);
    await tester.tap(find.text('Archive deal').last);
    await settle(tester);
    expect(repository.archived, true);
    expect(find.text('Archived'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('a restaurant change hides the draft and prevents publication', (
    tester,
  ) async {
    await open(tester, location: Routes.addRescueDeal);
    await chooseItem(tester);
    await tester.enterText(find.byKey(const ValueKey('rescue-price')), '6.25');
    container!.read(choiceProvider.notifier).choose('8');
    await settle(tester);
    expect(find.text('Your restaurant or account changed'), findsOneWidget);
    expect(find.text('Publish deal'), findsNothing);
    expect(repository.saves, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('leaving an edited draft asks before discarding', (tester) async {
    await open(tester, location: Routes.addRescueDeal);
    await tester.enterText(find.byKey(const ValueKey('rescue-price')), '6');
    await tester.tap(find.byTooltip('Back'));
    await settle(tester);
    expect(find.text('Discard your changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await settle(tester);
    expect(find.text('6'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('desktop create preview and dark details have no layout errors', (
    tester,
  ) async {
    await open(tester, location: Routes.addRescueDeal, width: 1100);
    await chooseItem(tester);
    await tester.enterText(find.byKey(const ValueKey('rescue-price')), '6.00');
    await settle(tester);
    expect(tester.takeException(), isNull);
    await capture(tester, 'desktop-create');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Arabic small screen and large text remain readable', (
    tester,
  ) async {
    await open(
      tester,
      location: Routes.addRescueDeal,
      width: 360,
      arabic: true,
      textScale: 1.2,
    );
    expect(find.text('نشر العرض'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'arabic-create');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('editing timing never overwrites price or inventory', (
    tester,
  ) async {
    await open(tester, location: Routes.editRescueDealPath('1'));
    final toggle = find.text('Limit per customer (optional)');
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);
    final sent = repository.saves.single;
    expect(sent.keys.toSet(), {'ends_at', 'max_per_customer'});
    expect(sent['max_per_customer'], isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('an older backend cannot trigger destructive archiving', (
    tester,
  ) async {
    repository.rows[0].remove('archived_at');
    repository.rows[0].remove('reserved_qty');
    repository.rows[0].remove('sold_qty');
    await open(tester, location: Routes.rescueDealPath('1'));
    await tester.ensureVisible(find.text('Archive deal'));
    final button = find.ancestor(
      of: find.text('Archive deal'),
      matching: find.byType(TextButton),
    );
    expect(tester.widget<TextButton>(button).onPressed, isNull);
    expect(repository.archived, false);
    expect(
      find.textContaining('Deal management is being updated'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('dark deal details keep stock distinct from sold portions', (
    tester,
  ) async {
    await open(tester, location: Routes.rescueDealPath('1'), dark: true);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Reserved'), findsOneWidget);
    expect(find.text('Sold'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'dark-details');
    await tester.pumpWidget(const SizedBox());
  });
}
