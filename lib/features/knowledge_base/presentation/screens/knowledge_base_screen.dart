import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../tour/application/tour_notifier.dart';
import '../../../tour/application/tour_state.dart';
import '../../data/knowledge_base_data.dart';

/// Knowledge Base screen with searchable articles and tour launcher
class KnowledgeBaseScreen extends ConsumerStatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  ConsumerState<KnowledgeBaseScreen> createState() =>
      _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends ConsumerState<KnowledgeBaseScreen> {
  final _searchController = TextEditingController();
  String _selectedCategoryId = '';
  String _searchQuery = '';
  final Set<String> _expandedArticles = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<KBArticle> get _filteredArticles {
    return KnowledgeBaseData.filterArticles(
      categoryId: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
      query: _searchQuery,
    );
  }

  void _startTour(TourType tourType) {
    final router = GoRouter.of(context);
    ref.read(tourProvider.notifier).setRouter(router);
    ref.read(tourProvider.notifier).startTour(tourType);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final articles = _filteredArticles;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('knowledgeBase.title'.tr),
        centerTitle: true,
        backgroundColor:
            isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: CustomScrollView(
            slivers: [
              // Tour button + tour type chips
              SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: _TourSection(
                isDark: isDark,
                primaryColor: primaryColor,
                onStartFullTour: () => _startTour(TourType.fullApp),
                onStartOrdersTour: () => _startTour(TourType.ordersQuick),
                onStartMenuTour: () => _startTour(TourType.menuQuick),
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'knowledgeBase.searchHint'.tr,
                  hintStyle: TextStyle(
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20.w,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Icon(
                            Icons.close,
                            size: 18.w,
                            color: isDark
                                ? DarkColors.textTertiary
                                : LightColors.textTertiary,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? DarkColors.surface
                      : LightColors.backgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
            ),
          ),

          // Category chips
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: SizedBox(
                height: 36.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    _CategoryChip(
                      label: 'knowledgeBase.allCategories'.tr,
                      isSelected: _selectedCategoryId.isEmpty,
                      primaryColor: primaryColor,
                      isDark: isDark,
                      onTap: () =>
                          setState(() => _selectedCategoryId = ''),
                    ),
                    ...KnowledgeBaseData.categories.map((cat) {
                      return Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: _CategoryChip(
                          label: cat.name,
                          icon: cat.icon,
                          isSelected: _selectedCategoryId == cat.id,
                          primaryColor: primaryColor,
                          isDark: isDark,
                          onTap: () =>
                              setState(() => _selectedCategoryId = cat.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 12.h)),

          // Article count
          if (articles.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '${articles.length} ${articles.length == 1 ? 'article' : 'articles'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: 8.h)),

          // Articles list
          if (articles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_outlined,
                      size: 48.w,
                      color: isDark
                          ? DarkColors.textTertiary
                          : LightColors.textTertiary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'knowledgeBase.noResults'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final article = articles[index];
                    final isExpanded =
                        _expandedArticles.contains(article.id);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _ArticleCard(
                        article: article,
                        isExpanded: isExpanded,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedArticles.remove(article.id);
                            } else {
                              _expandedArticles.add(article.id);
                            }
                          });
                        },
                      ),
                    );
                  },
                  childCount: articles.length,
                ),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
        ),
      ),
    );
  }
}

// ──────────────── Tour Section ────────────────

class _TourSection extends StatelessWidget {
  const _TourSection({
    required this.isDark,
    required this.primaryColor,
    required this.onStartFullTour,
    required this.onStartOrdersTour,
    required this.onStartMenuTour,
  });

  final bool isDark;
  final Color primaryColor;
  final VoidCallback onStartFullTour;
  final VoidCallback onStartOrdersTour;
  final VoidCallback onStartMenuTour;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.12),
            primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main tour button
          GestureDetector(
            onTap: onStartFullTour,
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.tour_outlined,
                    size: 22.w,
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'knowledgeBase.startTour'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                      Text(
                        'knowledgeBase.tourDescription'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_outlined,
                  size: 28.w,
                  color: primaryColor,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Quick tour chips
          Row(
            children: [
              _TourChip(
                label: 'knowledgeBase.fullTour'.tr,
                icon: Icons.apps_outlined,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: onStartFullTour,
              ),
              SizedBox(width: 8.w),
              _TourChip(
                label: 'knowledgeBase.ordersTour'.tr,
                icon: Icons.receipt_long_outlined,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: onStartOrdersTour,
              ),
              SizedBox(width: 8.w),
              _TourChip(
                label: 'knowledgeBase.menuTour'.tr,
                icon: Icons.restaurant_menu_outlined,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: onStartMenuTour,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourChip extends StatelessWidget {
  const _TourChip({
    required this.label,
    required this.icon,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: isDark
                ? DarkColors.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14.w, color: primaryColor),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────── Category Chip ────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? DarkColors.surface : LightColors.backgroundSecondary),
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? DarkColors.border : LightColors.border,
                  width: 0.5,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14.w,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary),
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────── Article Card ────────────────

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.isExpanded,
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  final KBArticle article;
  final bool isExpanded;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Find category name
    final category = KnowledgeBaseData.categories
        .where((c) => c.id == article.categoryId)
        .firstOrNull;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isExpanded
              ? primaryColor.withValues(alpha: 0.3)
              : (isDark ? DarkColors.border : LightColors.border),
          width: isExpanded ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (always visible)
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      article.icon,
                      size: 20.w,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          article.description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                          maxLines: isExpanded ? null : 1,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.w,
                      color: isDark
                          ? DarkColors.textTertiary
                          : LightColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category tag (only when collapsed)
          if (!isExpanded && category != null)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
            ),

          // Expanded content
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? DarkColors.border : LightColors.border,
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ...article.sections.map((section) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            section.body,
                            style: TextStyle(
                              fontSize: 13.sp,
                              height: 1.5,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
