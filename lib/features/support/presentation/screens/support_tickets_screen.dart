import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/support_notifier.dart';
import '../../data/models/support_ticket_model.dart';

class SupportTicketsScreen extends ConsumerStatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  ConsumerState<SupportTicketsScreen> createState() =>
      _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends ConsumerState<SupportTicketsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(supportProvider.notifier).loadTickets());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(supportProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(supportProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('support.title'.tr),
        centerTitle: true,
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.createSupportTicket),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Status filter chips
          _StatusFilterBar(
            selected: state.statusFilter,
            isDark: isDark,
            onSelected: (status) {
              ref.read(supportProvider.notifier).setStatusFilter(status);
            },
          ),

          // Tickets list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? _ErrorView(
                    error: state.error!,
                    isDark: isDark,
                    onRetry: () =>
                        ref.read(supportProvider.notifier).loadTickets(),
                  )
                : state.filteredTickets.isEmpty
                ? _EmptyView(isDark: isDark)
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(supportProvider.notifier).loadTickets(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      itemCount:
                          state.filteredTickets.length +
                          (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        if (index == state.filteredTickets.length) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        }
                        final ticket = state.filteredTickets[index];
                        return _TicketCard(
                          ticket: ticket,
                          isDark: isDark,
                          onTap: () => context.push(
                            Routes.supportTicketDetailPath(
                              ticket.id.toString(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends ConsumerWidget {
  const _StatusFilterBar({
    required this.selected,
    required this.isDark,
    required this.onSelected,
  });

  final TicketStatus? selected;
  final bool isDark;
  final ValueChanged<TicketStatus?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final filters = <({TicketStatus? status, String label})>[
      (status: null, label: 'support.all'.tr),
      (status: TicketStatus.open, label: 'support.statusOpen'.tr),
      (status: TicketStatus.inProgress, label: 'support.statusInProgress'.tr),
      (
        status: TicketStatus.waitingOnCustomer,
        label: 'support.statusWaitingOnCustomer'.tr,
      ),
      (status: TicketStatus.resolved, label: 'support.statusResolved'.tr),
      (status: TicketStatus.closed, label: 'support.statusClosed'.tr),
    ];

    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selected == filter.status;
          return GestureDetector(
            onTap: () => onSelected(filter.status),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark ? DarkColors.surface : LightColors.surface),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? DarkColors.border : LightColors.border),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TicketCard extends ConsumerWidget {
  const _TicketCard({
    required this.ticket,
    required this.isDark,
    required this.onTap,
  });

  final SupportTicket ticket;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Subject + Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                _StatusBadge(status: ticket.status, isDark: isDark),
              ],
            ),
            SizedBox(height: 8.h),

            // Category + Priority row
            Row(
              children: [
                _CategoryChip(category: ticket.category, isDark: isDark),
                SizedBox(width: 8.w),
                _PriorityIndicator(priority: ticket.priority, isDark: isDark),
                const Spacer(),
                Text(
                  _formatTimeAgo(ticket.lastActivityAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
              ],
            ),

            // Ticket ID
            SizedBox(height: 6.h),
            Text(
              '#${ticket.id}',
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isDark});

  final TicketStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case TicketStatus.open:
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        label = 'support.statusOpen'.tr;
      case TicketStatus.inProgress:
        bgColor = AppColors.info.withValues(alpha: 0.15);
        textColor = AppColors.info;
        label = 'support.statusInProgress'.tr;
      case TicketStatus.waitingOnCustomer:
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        label = 'support.statusWaitingOnCustomer'.tr;
      case TicketStatus.resolved:
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        label = 'support.statusResolved'.tr;
      case TicketStatus.closed:
        bgColor = (isDark ? DarkColors.textTertiary : LightColors.textTertiary)
            .withValues(alpha: 0.15);
        textColor = isDark ? DarkColors.textTertiary : LightColors.textTertiary;
        label = 'support.statusClosed'.tr;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.isDark});

  final TicketCategory category;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;

    switch (category) {
      case TicketCategory.order:
        icon = Icons.receipt_outlined;
        label = 'support.categoryOrder'.tr;
      case TicketCategory.payment:
        icon = Icons.payments_outlined;
        label = 'support.categoryPayment'.tr;
      case TicketCategory.delivery:
        icon = Icons.local_shipping_outlined;
        label = 'support.categoryDelivery'.tr;
      case TicketCategory.account:
        icon = Icons.account_circle_outlined;
        label = 'support.categoryAccount'.tr;
      case TicketCategory.other:
        icon = Icons.help_outline;
        label = 'support.categoryOther'.tr;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.w,
          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  const _PriorityIndicator({required this.priority, required this.isDark});

  final TicketPriority priority;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (priority) {
      case TicketPriority.low:
        color = AppColors.success;
        label = 'support.priorityLow'.tr;
      case TicketPriority.medium:
        color = AppColors.warning;
        label = 'support.priorityMedium'.tr;
      case TicketPriority.high:
        color = AppColors.error;
        label = 'support.priorityHigh'.tr;
      case TicketPriority.urgent:
        color = AppColors.error;
        label = 'support.priorityUrgent'.tr;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends ConsumerWidget {
  const _EmptyView({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent_outlined,
            size: 64.w,
            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            'support.noTickets'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'support.noTicketsDesc'.tr,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({
    required this.error,
    required this.isDark,
    required this.onRetry,
  });

  final String error;
  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.w, color: AppColors.error),
          SizedBox(height: 12.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text('common.retry'.tr),
          ),
        ],
      ),
    );
  }
}

String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return 'time.justNow'.tr;
  if (diff.inMinutes < 60) {
    return 'time.minutesAgo'.tr.replaceAll('{minutes}', '${diff.inMinutes}');
  }
  if (diff.inHours < 24) {
    return 'time.hoursAgo'.tr.replaceAll('{hours}', '${diff.inHours}');
  }
  return 'time.daysAgo'.tr.replaceAll('{days}', '${diff.inDays}');
}
