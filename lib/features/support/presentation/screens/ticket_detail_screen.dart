import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../application/support_notifier.dart';
import '../../data/models/support_ticket_model.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final int ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(supportProvider.notifier).loadTicketDetail(widget.ticketId),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final body = _messageController.text.trim();
    if (body.isEmpty) return;

    _messageController.clear();
    final success = await ref
        .read(supportProvider.notifier)
        .sendMessage(widget.ticketId, body);

    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(supportProvider);
    final ticket = state.selectedTicket;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Scroll to bottom when messages change
    if (ticket != null && ticket.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              ticket?.subject ?? 'support.title'.tr,
              style: TextStyle(fontSize: 15.sp),
            ),
            if (ticket != null)
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
        centerTitle: true,
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
        actions: [
          if (ticket != null)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: _StatusBadge(status: ticket.status, isDark: isDark),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: state.isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.w, color: AppColors.error),
                  SizedBox(height: 12.h),
                  Text(state.error!),
                  SizedBox(height: 16.h),
                  TextButton.icon(
                    onPressed: () => ref
                        .read(supportProvider.notifier)
                        .loadTicketDetail(widget.ticketId),
                    icon: const Icon(Icons.refresh),
                    label: Text('common.retry'.tr),
                  ),
                ],
              ),
            )
          : ticket == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                // Ticket info header
                _TicketInfoHeader(ticket: ticket, isDark: isDark),

                // Messages list
                Expanded(
                  child: ticket.messages.isEmpty
                      ? Center(
                          child: Text(
                            'support.noTicketsDesc'.tr,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark
                                  ? DarkColors.textTertiary
                                  : LightColors.textTertiary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          itemCount: ticket.messages.length,
                          itemBuilder: (context, index) {
                            final message = ticket.messages[index];
                            final isMe =
                                message.authorRole == AuthorRole.seller;
                            return _MessageBubble(
                              message: message,
                              isMe: isMe,
                              isDark: isDark,
                              primaryColor: primaryColor,
                            );
                          },
                        ),
                ),

                // Message input bar
                if (ticket.status != TicketStatus.closed)
                  _MessageInputBar(
                    controller: _messageController,
                    isDark: isDark,
                    isSending: state.isSending,
                    primaryColor: primaryColor,
                    onSend: _sendMessage,
                  ),
              ],
            ),
        ),
      ),
    );
  }
}

class _TicketInfoHeader extends ConsumerWidget {
  const _TicketInfoHeader({required this.ticket, required this.isDark});

  final SupportTicket ticket;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _InfoItem(
                label: 'support.category'.tr,
                value: _categoryLabel(ticket.category),
                isDark: isDark,
              ),
              SizedBox(width: 20.w),
              _InfoItem(
                label: 'support.priority'.tr,
                value: _priorityLabel(ticket.priority),
                isDark: isDark,
                valueColor: _priorityColor(ticket.priority),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _InfoItem(
                label: 'support.createdAt'.tr,
                value: _formatDate(ticket.createdAt),
                isDark: isDark,
              ),
              SizedBox(width: 20.w),
              _InfoItem(
                label: 'support.assignedTo'.tr,
                value: ticket.assignedToName ?? 'support.unassigned'.tr,
                isDark: isDark,
              ),
            ],
          ),
          if (ticket.order != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                _InfoItem(
                  label: 'support.relatedOrder'.tr,
                  value: '#${ticket.order}',
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _categoryLabel(TicketCategory cat) {
    switch (cat) {
      case TicketCategory.order:
        return 'support.categoryOrder'.tr;
      case TicketCategory.payment:
        return 'support.categoryPayment'.tr;
      case TicketCategory.delivery:
        return 'support.categoryDelivery'.tr;
      case TicketCategory.account:
        return 'support.categoryAccount'.tr;
      case TicketCategory.other:
        return 'support.categoryOther'.tr;
    }
  }

  String _priorityLabel(TicketPriority p) {
    switch (p) {
      case TicketPriority.low:
        return 'support.priorityLow'.tr;
      case TicketPriority.medium:
        return 'support.priorityMedium'.tr;
      case TicketPriority.high:
        return 'support.priorityHigh'.tr;
      case TicketPriority.urgent:
        return 'support.priorityUrgent'.tr;
    }
  }

  Color _priorityColor(TicketPriority p) {
    switch (p) {
      case TicketPriority.low:
        return AppColors.success;
      case TicketPriority.medium:
        return AppColors.warning;
      case TicketPriority.high:
        return AppColors.error;
      case TicketPriority.urgent:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color:
                  valueColor ??
                  (isDark ? DarkColors.textPrimary : LightColors.textPrimary),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isDark,
    required this.primaryColor,
  });

  final TicketMessage message;
  final bool isMe;
  final bool isDark;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 4.w,
              right: isMe ? 4.w : 0,
              bottom: 4.h,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMe ? 'support.you'.tr : message.authorName,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                if (!isMe && message.authorRole == AuthorRole.staff) ...[
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'support.supportAgent'.tr,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  _MessageAvatar(
                    role: message.authorRole,
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                  SizedBox(width: 8.w),
                ],
                Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? primaryColor
                            : (isDark
                                  ? DarkColors.surface
                                  : LightColors.backgroundSecondary),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                          bottomLeft: isMe
                              ? Radius.circular(16.r)
                              : Radius.circular(4.r),
                          bottomRight: isMe
                              ? Radius.circular(4.r)
                              : Radius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        message.body,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isMe
                              ? Colors.white
                              : (isDark
                                    ? DarkColors.textPrimary
                                    : LightColors.textPrimary),
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (message.attachments.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      ...message.attachments.map(
                        (att) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: GestureDetector(
                            onTap: att.fileUrl.isEmpty
                                ? null
                                : () => _openAttachment(att.fileUrl),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: maxBubbleWidth,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? DarkColors.surface
                                    : LightColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isDark
                                      ? DarkColors.border
                                      : LightColors.border,
                                  width: 0.5,
                                ),
                              ),
                              child: att.isImage
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(8.r),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: att.fileUrl,
                                            width: double.infinity,
                                            height: 160.h,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  height: 160.h,
                                                  color: isDark
                                                      ? DarkColors.surface
                                                      : LightColors.surface,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  height: 160.h,
                                                  alignment: Alignment.center,
                                                  color: isDark
                                                      ? DarkColors.surface
                                                      : LightColors.surface,
                                                  child: Icon(
                                                    Icons.broken_image_outlined,
                                                    color: isDark
                                                        ? DarkColors
                                                              .textSecondary
                                                        : LightColors
                                                              .textSecondary,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 8.h,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  att.displayName,
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: isDark
                                                        ? DarkColors
                                                              .textSecondary
                                                        : LightColors
                                                              .textSecondary,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                'common.open'.tr,
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 8.h,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attach_file,
                                            size: 14.w,
                                            color: isDark
                                                ? DarkColors.textSecondary
                                                : LightColors.textSecondary,
                                          ),
                                          SizedBox(width: 4.w),
                                          Flexible(
                                            child: Text(
                                              att.displayName,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: isDark
                                                    ? DarkColors.textSecondary
                                                    : LightColors.textSecondary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'common.open'.tr,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: EdgeInsets.only(
                        left: isMe ? 0 : 4.w,
                        right: isMe ? 4.w : 0,
                        top: 4.h,
                      ),
                      child: Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDark
                              ? DarkColors.textTertiary
                              : LightColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isMe) ...[
                  SizedBox(width: 8.w),
                  _MessageAvatar(
                    role: message.authorRole,
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageAvatar extends StatelessWidget {
  const _MessageAvatar({
    required this.role,
    required this.isDark,
    required this.primaryColor,
  });

  final AuthorRole role;
  final bool isDark;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (role) {
      AuthorRole.seller => primaryColor,
      AuthorRole.customer => AppColors.info,
      AuthorRole.driver => AppColors.success,
      AuthorRole.staff => AppColors.warning,
    };

    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? DarkColors.border
              : Colors.white.withValues(alpha: 0.85),
          width: 0.8,
        ),
      ),
      child: Icon(
        switch (role) {
          AuthorRole.seller => Icons.storefront_outlined,
          AuthorRole.customer => Icons.person_outline,
          AuthorRole.driver => Icons.local_shipping_outlined,
          AuthorRole.staff => Icons.support_agent_outlined,
        },
        size: 16.w,
        color: Colors.white,
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

Future<void> _openAttachment(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.isDark,
    required this.isSending,
    required this.primaryColor,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isDark;
  final bool isSending;
  final Color primaryColor;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.h,
        8.w,
        8.h + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? DarkColors.border : LightColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'support.messageHint'.tr,
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? DarkColors.textTertiary
                      : LightColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide(
                    color: isDark ? DarkColors.border : LightColors.border,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide(
                    color: isDark ? DarkColors.border : LightColors.border,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide(color: primaryColor, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                filled: true,
                fillColor: isDark
                    ? DarkColors.background
                    : LightColors.background,
              ),
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.send_rounded, size: 20.w, color: Colors.white),
            ),
          ),
        ],
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

    return Center(
      child: Container(
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
      ),
    );
  }
}
