import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';

class ChangelogScreen extends ConsumerWidget {
  const ChangelogScreen({super.key});

  static const _releases = [
    _ReleaseNotes(
      version: '1.0.14+15',
      dateKey: 'changelog.v1014.date',
      isCurrent: true,
      changeKeys: [
        'changelog.v1014.change1',
        'changelog.v1014.change2',
        'changelog.v1014.change3',
        'changelog.v1014.change4',
        'changelog.v1014.change5',
        'changelog.v1014.change6',
      ],
    ),
    _ReleaseNotes(
      version: '1.0.13+14',
      dateKey: 'changelog.v1013.date',
      changeKeys: [
        'changelog.v1013.change1',
        'changelog.v1013.change2',
        'changelog.v1013.change3',
        'changelog.v1013.change4',
        'changelog.v1013.change5',
        'changelog.v1013.change6',
        'changelog.v1013.change7',
        'changelog.v1013.change8',
      ],
    ),
    _ReleaseNotes(
      version: '1.0.12+13',
      dateKey: 'changelog.v1012.date',
      changeKeys: [
        'changelog.v1012.change1',
        'changelog.v1012.change2',
        'changelog.v1012.change3',
      ],
    ),
    _ReleaseNotes(
      version: '1.0.11+12',
      dateKey: 'changelog.v1011.date',
      changeKeys: [
        'changelog.v1011.change1',
        'changelog.v1011.change2',
        'changelog.v1011.change3',
      ],
    ),
    _ReleaseNotes(
      version: '1.0.10+11',
      dateKey: 'changelog.v1010.date',
      changeKeys: [
        'changelog.v1010.change1',
        'changelog.v1010.change2',
        'changelog.v1010.change3',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('changelog.title'.tr),
        centerTitle: true,
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'changelog.title'.tr,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'changelog.subtitle'.tr,
                            style: TextStyle(
                              fontSize: 13.sp,
                              height: 1.4,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              for (var index = 0; index < _releases.length; index++) ...[
                _ReleaseCard(release: _releases[index], isDark: isDark),
                if (index != _releases.length - 1) SizedBox(height: 14.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReleaseNotes {
  const _ReleaseNotes({
    required this.version,
    required this.dateKey,
    required this.changeKeys,
    this.isCurrent = false,
  });

  final String version;
  final String dateKey;
  final List<String> changeKeys;
  final bool isCurrent;
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({required this.release, required this.isDark});

  final _ReleaseNotes release;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textPrimary = isDark
        ? DarkColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? DarkColors.textSecondary
        : LightColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: release.isCurrent
              ? primaryColor.withValues(alpha: 0.45)
              : (isDark ? DarkColors.border : LightColors.border),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(release.version),
          initiallyExpanded: release.isCurrent,
          maintainState: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
          childrenPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 10.h),
          iconColor: primaryColor,
          collapsedIconColor: textSecondary,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'changelog.version'.trParams({'version': release.version}),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              if (release.isCurrent) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'changelog.current'.tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              release.dateKey.tr,
              style: TextStyle(fontSize: 12.sp, color: textSecondary),
            ),
          ),
          children: [
            Divider(
              height: 18.h,
              color: isDark ? DarkColors.border : LightColors.border,
            ),
            for (final changeKey in release.changeKeys)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 17.w,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        changeKey.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.45,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
