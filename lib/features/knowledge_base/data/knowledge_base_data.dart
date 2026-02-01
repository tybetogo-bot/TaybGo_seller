import 'package:flutter/material.dart';

import '../../../core/i18n/i18n.dart';

/// A single section within an article
class ArticleSection {
  final String titleKey;
  final String bodyKey;

  const ArticleSection({required this.titleKey, required this.bodyKey});

  String get title => titleKey.tr;
  String get body => bodyKey.tr;
}

/// A knowledge base article
class KBArticle {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final String categoryId;
  final List<ArticleSection> sections;

  const KBArticle({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.categoryId,
    required this.sections,
  });

  String get title => titleKey.tr;
  String get description => descriptionKey.tr;

  /// Whether this article matches a search query
  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    if (title.toLowerCase().contains(q)) return true;
    if (description.toLowerCase().contains(q)) return true;
    for (final section in sections) {
      if (section.title.toLowerCase().contains(q)) return true;
      if (section.body.toLowerCase().contains(q)) return true;
    }
    return false;
  }
}

/// A category grouping articles
class KBCategory {
  final String id;
  final String nameKey;
  final IconData icon;

  const KBCategory({
    required this.id,
    required this.nameKey,
    required this.icon,
  });

  String get name => nameKey.tr;
}

/// Static knowledge base content
class KnowledgeBaseData {
  KnowledgeBaseData._();

  static const List<KBCategory> categories = [
    KBCategory(id: 'getting_started', nameKey: 'kb.categories.gettingStarted', icon: Icons.rocket_launch_outlined),
    KBCategory(id: 'orders', nameKey: 'kb.categories.orders', icon: Icons.receipt_long_outlined),
    KBCategory(id: 'menu', nameKey: 'kb.categories.menu', icon: Icons.restaurant_menu_outlined),
    KBCategory(id: 'coupons', nameKey: 'kb.categories.coupons', icon: Icons.local_offer_outlined),
    KBCategory(id: 'settings', nameKey: 'kb.categories.settings', icon: Icons.settings_outlined),
    KBCategory(id: 'statistics', nameKey: 'kb.categories.statistics', icon: Icons.bar_chart_outlined),
    KBCategory(id: 'tips', nameKey: 'kb.categories.tips', icon: Icons.lightbulb_outlined),
  ];

  static const List<KBArticle> articles = [
    // ──────────────── Getting Started ────────────────
    KBArticle(
      id: 'gs_welcome',
      titleKey: 'kb.gsWelcome.title',
      descriptionKey: 'kb.gsWelcome.description',
      icon: Icons.waving_hand_outlined,
      categoryId: 'getting_started',
      sections: [
        ArticleSection(titleKey: 'kb.gsWelcome.s1Title', bodyKey: 'kb.gsWelcome.s1Body'),
        ArticleSection(titleKey: 'kb.gsWelcome.s2Title', bodyKey: 'kb.gsWelcome.s2Body'),
        ArticleSection(titleKey: 'kb.gsWelcome.s3Title', bodyKey: 'kb.gsWelcome.s3Body'),
      ],
    ),
    KBArticle(
      id: 'gs_navigation',
      titleKey: 'kb.gsNav.title',
      descriptionKey: 'kb.gsNav.description',
      icon: Icons.explore_outlined,
      categoryId: 'getting_started',
      sections: [
        ArticleSection(titleKey: 'kb.gsNav.s1Title', bodyKey: 'kb.gsNav.s1Body'),
        ArticleSection(titleKey: 'kb.gsNav.s2Title', bodyKey: 'kb.gsNav.s2Body'),
        ArticleSection(titleKey: 'kb.gsNav.s3Title', bodyKey: 'kb.gsNav.s3Body'),
      ],
    ),

    // ──────────────── Orders ────────────────
    KBArticle(
      id: 'orders_managing',
      titleKey: 'kb.ordersManaging.title',
      descriptionKey: 'kb.ordersManaging.description',
      icon: Icons.list_alt_outlined,
      categoryId: 'orders',
      sections: [
        ArticleSection(titleKey: 'kb.ordersManaging.s1Title', bodyKey: 'kb.ordersManaging.s1Body'),
        ArticleSection(titleKey: 'kb.ordersManaging.s2Title', bodyKey: 'kb.ordersManaging.s2Body'),
        ArticleSection(titleKey: 'kb.ordersManaging.s3Title', bodyKey: 'kb.ordersManaging.s3Body'),
        ArticleSection(titleKey: 'kb.ordersManaging.s4Title', bodyKey: 'kb.ordersManaging.s4Body'),
      ],
    ),
    KBArticle(
      id: 'orders_status',
      titleKey: 'kb.ordersStatus.title',
      descriptionKey: 'kb.ordersStatus.description',
      icon: Icons.swap_horiz_outlined,
      categoryId: 'orders',
      sections: [
        ArticleSection(titleKey: 'kb.ordersStatus.s1Title', bodyKey: 'kb.ordersStatus.s1Body'),
        ArticleSection(titleKey: 'kb.ordersStatus.s2Title', bodyKey: 'kb.ordersStatus.s2Body'),
        ArticleSection(titleKey: 'kb.ordersStatus.s3Title', bodyKey: 'kb.ordersStatus.s3Body'),
      ],
    ),
    KBArticle(
      id: 'orders_create',
      titleKey: 'kb.ordersCreate.title',
      descriptionKey: 'kb.ordersCreate.description',
      icon: Icons.add_box_outlined,
      categoryId: 'orders',
      sections: [
        ArticleSection(titleKey: 'kb.ordersCreate.s1Title', bodyKey: 'kb.ordersCreate.s1Body'),
        ArticleSection(titleKey: 'kb.ordersCreate.s2Title', bodyKey: 'kb.ordersCreate.s2Body'),
        ArticleSection(titleKey: 'kb.ordersCreate.s3Title', bodyKey: 'kb.ordersCreate.s3Body'),
      ],
    ),
    KBArticle(
      id: 'orders_scan',
      titleKey: 'kb.ordersScan.title',
      descriptionKey: 'kb.ordersScan.description',
      icon: Icons.document_scanner_outlined,
      categoryId: 'orders',
      sections: [
        ArticleSection(titleKey: 'kb.ordersScan.s1Title', bodyKey: 'kb.ordersScan.s1Body'),
        ArticleSection(titleKey: 'kb.ordersScan.s2Title', bodyKey: 'kb.ordersScan.s2Body'),
        ArticleSection(titleKey: 'kb.ordersScan.s3Title', bodyKey: 'kb.ordersScan.s3Body'),
      ],
    ),

    // ──────────────── Menu ────────────────
    KBArticle(
      id: 'menu_items',
      titleKey: 'kb.menuItems.title',
      descriptionKey: 'kb.menuItems.description',
      icon: Icons.restaurant_outlined,
      categoryId: 'menu',
      sections: [
        ArticleSection(titleKey: 'kb.menuItems.s1Title', bodyKey: 'kb.menuItems.s1Body'),
        ArticleSection(titleKey: 'kb.menuItems.s2Title', bodyKey: 'kb.menuItems.s2Body'),
        ArticleSection(titleKey: 'kb.menuItems.s3Title', bodyKey: 'kb.menuItems.s3Body'),
        ArticleSection(titleKey: 'kb.menuItems.s4Title', bodyKey: 'kb.menuItems.s4Body'),
        ArticleSection(titleKey: 'kb.menuItems.s5Title', bodyKey: 'kb.menuItems.s5Body'),
      ],
    ),
    KBArticle(
      id: 'menu_categories',
      titleKey: 'kb.menuCats.title',
      descriptionKey: 'kb.menuCats.description',
      icon: Icons.category_outlined,
      categoryId: 'menu',
      sections: [
        ArticleSection(titleKey: 'kb.menuCats.s1Title', bodyKey: 'kb.menuCats.s1Body'),
        ArticleSection(titleKey: 'kb.menuCats.s2Title', bodyKey: 'kb.menuCats.s2Body'),
        ArticleSection(titleKey: 'kb.menuCats.s3Title', bodyKey: 'kb.menuCats.s3Body'),
      ],
    ),
    KBArticle(
      id: 'menu_customizations',
      titleKey: 'kb.menuCustom.title',
      descriptionKey: 'kb.menuCustom.description',
      icon: Icons.tune_outlined,
      categoryId: 'menu',
      sections: [
        ArticleSection(titleKey: 'kb.menuCustom.s1Title', bodyKey: 'kb.menuCustom.s1Body'),
        ArticleSection(titleKey: 'kb.menuCustom.s2Title', bodyKey: 'kb.menuCustom.s2Body'),
        ArticleSection(titleKey: 'kb.menuCustom.s3Title', bodyKey: 'kb.menuCustom.s3Body'),
      ],
    ),

    // ──────────────── Coupons ────────────────
    KBArticle(
      id: 'coupons_create',
      titleKey: 'kb.couponsCreate.title',
      descriptionKey: 'kb.couponsCreate.description',
      icon: Icons.confirmation_number_outlined,
      categoryId: 'coupons',
      sections: [
        ArticleSection(titleKey: 'kb.couponsCreate.s1Title', bodyKey: 'kb.couponsCreate.s1Body'),
        ArticleSection(titleKey: 'kb.couponsCreate.s2Title', bodyKey: 'kb.couponsCreate.s2Body'),
        ArticleSection(titleKey: 'kb.couponsCreate.s3Title', bodyKey: 'kb.couponsCreate.s3Body'),
      ],
    ),
    KBArticle(
      id: 'coupons_manage',
      titleKey: 'kb.couponsManage.title',
      descriptionKey: 'kb.couponsManage.description',
      icon: Icons.edit_note_outlined,
      categoryId: 'coupons',
      sections: [
        ArticleSection(titleKey: 'kb.couponsManage.s1Title', bodyKey: 'kb.couponsManage.s1Body'),
        ArticleSection(titleKey: 'kb.couponsManage.s2Title', bodyKey: 'kb.couponsManage.s2Body'),
        ArticleSection(titleKey: 'kb.couponsManage.s3Title', bodyKey: 'kb.couponsManage.s3Body'),
      ],
    ),

    // ──────────────── Settings ────────────────
    KBArticle(
      id: 'settings_theme',
      titleKey: 'kb.settingsTheme.title',
      descriptionKey: 'kb.settingsTheme.description',
      icon: Icons.palette_outlined,
      categoryId: 'settings',
      sections: [
        ArticleSection(titleKey: 'kb.settingsTheme.s1Title', bodyKey: 'kb.settingsTheme.s1Body'),
        ArticleSection(titleKey: 'kb.settingsTheme.s2Title', bodyKey: 'kb.settingsTheme.s2Body'),
      ],
    ),
    KBArticle(
      id: 'settings_language',
      titleKey: 'kb.settingsLang.title',
      descriptionKey: 'kb.settingsLang.description',
      icon: Icons.translate_outlined,
      categoryId: 'settings',
      sections: [
        ArticleSection(titleKey: 'kb.settingsLang.s1Title', bodyKey: 'kb.settingsLang.s1Body'),
        ArticleSection(titleKey: 'kb.settingsLang.s2Title', bodyKey: 'kb.settingsLang.s2Body'),
      ],
    ),
    KBArticle(
      id: 'settings_notifications',
      titleKey: 'kb.settingsNotif.title',
      descriptionKey: 'kb.settingsNotif.description',
      icon: Icons.notifications_active_outlined,
      categoryId: 'settings',
      sections: [
        ArticleSection(titleKey: 'kb.settingsNotif.s1Title', bodyKey: 'kb.settingsNotif.s1Body'),
        ArticleSection(titleKey: 'kb.settingsNotif.s2Title', bodyKey: 'kb.settingsNotif.s2Body'),
        ArticleSection(titleKey: 'kb.settingsNotif.s3Title', bodyKey: 'kb.settingsNotif.s3Body'),
      ],
    ),

    // ──────────────── Statistics ────────────────
    KBArticle(
      id: 'stats_overview',
      titleKey: 'kb.statsOverview.title',
      descriptionKey: 'kb.statsOverview.description',
      icon: Icons.insights_outlined,
      categoryId: 'statistics',
      sections: [
        ArticleSection(titleKey: 'kb.statsOverview.s1Title', bodyKey: 'kb.statsOverview.s1Body'),
        ArticleSection(titleKey: 'kb.statsOverview.s2Title', bodyKey: 'kb.statsOverview.s2Body'),
        ArticleSection(titleKey: 'kb.statsOverview.s3Title', bodyKey: 'kb.statsOverview.s3Body'),
      ],
    ),

    // ──────────────── Tips & Tricks ────────────────
    KBArticle(
      id: 'tips_gestures',
      titleKey: 'kb.tipsGestures.title',
      descriptionKey: 'kb.tipsGestures.description',
      icon: Icons.swipe_outlined,
      categoryId: 'tips',
      sections: [
        ArticleSection(titleKey: 'kb.tipsGestures.s1Title', bodyKey: 'kb.tipsGestures.s1Body'),
        ArticleSection(titleKey: 'kb.tipsGestures.s2Title', bodyKey: 'kb.tipsGestures.s2Body'),
        ArticleSection(titleKey: 'kb.tipsGestures.s3Title', bodyKey: 'kb.tipsGestures.s3Body'),
      ],
    ),
    KBArticle(
      id: 'tips_best_practices',
      titleKey: 'kb.tipsBest.title',
      descriptionKey: 'kb.tipsBest.description',
      icon: Icons.star_outline,
      categoryId: 'tips',
      sections: [
        ArticleSection(titleKey: 'kb.tipsBest.s1Title', bodyKey: 'kb.tipsBest.s1Body'),
        ArticleSection(titleKey: 'kb.tipsBest.s2Title', bodyKey: 'kb.tipsBest.s2Body'),
        ArticleSection(titleKey: 'kb.tipsBest.s3Title', bodyKey: 'kb.tipsBest.s3Body'),
        ArticleSection(titleKey: 'kb.tipsBest.s4Title', bodyKey: 'kb.tipsBest.s4Body'),
      ],
    ),
  ];

  /// Get articles filtered by category
  static List<KBArticle> getArticlesByCategory(String categoryId) {
    return articles.where((a) => a.categoryId == categoryId).toList();
  }

  /// Search articles by query
  static List<KBArticle> searchArticles(String query) {
    if (query.isEmpty) return articles;
    return articles.where((a) => a.matchesQuery(query)).toList();
  }

  /// Filter by category and search
  static List<KBArticle> filterArticles({String? categoryId, String query = ''}) {
    var result = articles.toList();
    if (categoryId != null && categoryId.isNotEmpty) {
      result = result.where((a) => a.categoryId == categoryId).toList();
    }
    if (query.isNotEmpty) {
      result = result.where((a) => a.matchesQuery(query)).toList();
    }
    return result;
  }
}
