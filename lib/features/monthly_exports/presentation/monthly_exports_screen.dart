import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/i18n/i18n.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/monthly_exports_notifier.dart';
import '../data/monthly_export_model.dart';

/// Seller Monthly Umsatzbericht PDF statements screen.
class MonthlyExportsScreen extends ConsumerWidget {
  const MonthlyExportsScreen({super.key});

  Future<void> _downloadPdf(
    BuildContext context,
    WidgetRef ref,
    SellerMonthlyExport export,
  ) async {
    final notifier = ref.read(monthlyExportsProvider.notifier);
    final url = await notifier.fetchFreshDownloadUrl(export);
    if (!context.mounted) return;
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('monthlyExports.downloadFailed'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('monthlyExports.downloadFailed'.tr),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final state = ref.watch(monthlyExportsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('monthlyExports.title'.tr),
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'common.refresh'.tr,
            onPressed: state.isLoading
                ? null
                : () => ref.read(monthlyExportsProvider.notifier).loadExports(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(monthlyExportsProvider.notifier).loadExports(),
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'monthlyExports.subtitle'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              isExpanded: true,
                              initialValue: state.selectedYear,
                              decoration: InputDecoration(
                                labelText: 'monthlyExports.year'.tr,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('common.all'.tr),
                                ),
                                for (var i = 0; i < 4; i++)
                                  DropdownMenuItem<int?>(
                                    value: now.year - i,
                                    child: Text('${now.year - i}'),
                                  ),
                              ],
                              onChanged: (value) {
                                ref
                                    .read(monthlyExportsProvider.notifier)
                                    .loadExports(
                                      year: value,
                                      clearYear: value == null,
                                    );
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              isExpanded: true,
                              initialValue: state.selectedMonth,
                              decoration: InputDecoration(
                                labelText: 'monthlyExports.month'.tr,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('common.all'.tr),
                                ),
                                for (var m = 1; m <= 12; m++)
                                  DropdownMenuItem<int?>(
                                    value: m,
                                    child: Text(m.toString().padLeft(2, '0')),
                                  ),
                              ],
                              onChanged: (value) {
                                ref
                                    .read(monthlyExportsProvider.notifier)
                                    .loadExports(
                                      month: value,
                                      clearMonth: value == null,
                                    );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                if (state.isLoading && state.exports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null && state.exports.isEmpty)
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          state.error!,
                          style: TextStyle(color: AppColors.error),
                        ),
                        SizedBox(height: 12.h),
                        OutlinedButton(
                          onPressed: () => ref
                              .read(monthlyExportsProvider.notifier)
                              .loadExports(),
                          child: Text('common.retry'.tr),
                        ),
                      ],
                    ),
                  )
                else if (state.exports.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 28.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 40.w,
                            color: isDark
                                ? DarkColors.textTertiary
                                : LightColors.textTertiary,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'monthlyExports.empty'.tr,
                            textAlign: TextAlign.center,
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
                  ...state.exports.map(
                    (export) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _MonthlyExportCard(
                        export: export,
                        isDark: isDark,
                        isDownloading: state.downloadingExportId == export.id,
                        onDownload: export.isReady
                            ? () => _downloadPdf(context, ref, export)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyExportCard extends StatelessWidget {
  const _MonthlyExportCard({
    required this.export,
    required this.isDark,
    required this.isDownloading,
    this.onDownload,
  });

  final SellerMonthlyExport export;
  final bool isDark;
  final bool isDownloading;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final statusColor = export.isReady ? AppColors.success : AppColors.warning;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: primary,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      export.periodLabel,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                    if (export.restaurantName.isNotEmpty)
                      Text(
                        export.restaurantName,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  export.status,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 6.h,
            children: [
              Text(
                '${export.rowCount} ${'monthlyExports.orders'.tr}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              Text(
                '€${export.grossTotalEur.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
          if (export.errorMessage != null &&
              export.errorMessage!.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              export.errorMessage!,
              style: TextStyle(fontSize: 12.sp, color: AppColors.error),
            ),
          ],
          if (onDownload != null) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: ValueKey('download-monthly-pdf-${export.id}'),
                onPressed: isDownloading ? null : onDownload,
                icon: isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text('monthlyExports.downloadPdf'.tr),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
