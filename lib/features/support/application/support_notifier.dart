/// Support tickets state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/models/support_ticket_model.dart';
import '../data/repositories/support_repository.dart';

/// Support state
class SupportState {
  SupportState({
    this.tickets = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
    this.selectedTicket,
    this.isLoadingDetail = false,
    this.isSending = false,
    this.isCreating = false,
    this.statusFilter,
  });

  final List<SupportTicket> tickets;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMorePages;
  final SupportTicket? selectedTicket;
  final bool isLoadingDetail;
  final bool isSending;
  final bool isCreating;
  final TicketStatus? statusFilter;

  List<SupportTicket> get filteredTickets {
    if (statusFilter == null) return tickets;
    return tickets.where((t) => t.status == statusFilter).toList();
  }

  SupportState copyWith({
    List<SupportTicket>? tickets,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMorePages,
    SupportTicket? selectedTicket,
    bool clearSelectedTicket = false,
    bool? isLoadingDetail,
    bool? isSending,
    bool? isCreating,
    TicketStatus? statusFilter,
    bool clearStatusFilter = false,
    bool clearError = false,
  }) {
    return SupportState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      selectedTicket:
          clearSelectedTicket ? null : (selectedTicket ?? this.selectedTicket),
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isSending: isSending ?? this.isSending,
      isCreating: isCreating ?? this.isCreating,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

/// Support notifier provider
final supportProvider = NotifierProvider<SupportNotifier, SupportState>(
  SupportNotifier.new,
);

/// Support notifier
class SupportNotifier extends Notifier<SupportState> {
  late SupportRepository _repository;

  @override
  SupportState build() {
    _repository = ref.watch(supportRepositoryProvider);
    return SupportState();
  }

  /// Load tickets (first page)
  Future<void> loadTickets() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getTickets(page: 1);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      tickets: result.data ?? [],
      currentPage: 1,
      hasMorePages: (result.data?.length ?? 0) >= 20,
    );
  }

  /// Load more tickets (next page)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMorePages) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final result = await _repository.getTickets(page: nextPage);

    if (result.failure != null) {
      state = state.copyWith(isLoadingMore: false);
      return;
    }

    final newTickets = result.data ?? [];
    state = state.copyWith(
      isLoadingMore: false,
      tickets: [...state.tickets, ...newTickets],
      currentPage: nextPage,
      hasMorePages: newTickets.length >= 20,
    );
  }

  /// Set status filter
  void setStatusFilter(TicketStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  /// Load ticket detail with messages
  Future<void> loadTicketDetail(int id) async {
    state = state.copyWith(isLoadingDetail: true, clearError: true);

    final result = await _repository.getTicketById(id);

    if (result.failure != null) {
      state = state.copyWith(
        isLoadingDetail: false,
        error: result.failure!.message,
      );
      return;
    }

    state = state.copyWith(
      isLoadingDetail: false,
      selectedTicket: result.data,
    );
  }

  /// Create a new ticket
  Future<bool> createTicket({
    required String subject,
    required TicketCategory category,
    required TicketPriority priority,
    int? orderId,
    int? restaurantId,
    int? driverId,
  }) async {
    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createTicket(
      subject: subject,
      category: category.apiValue,
      priority: priority.apiValue,
      orderId: orderId,
      restaurantId: restaurantId,
      driverId: driverId,
    );

    if (result.failure != null) {
      state = state.copyWith(
        isCreating: false,
        error: result.failure!.message,
      );
      return false;
    }

    // Add the new ticket to the top of the list
    state = state.copyWith(
      isCreating: false,
      tickets: [result.data!, ...state.tickets],
    );
    return true;
  }

  /// Send a message to the selected ticket
  Future<bool> sendMessage(int ticketId, String body) async {
    if (body.trim().isEmpty) return false;

    state = state.copyWith(isSending: true);

    final result = await _repository.sendMessage(ticketId, body: body.trim());

    if (result.failure != null) {
      state = state.copyWith(isSending: false);
      return false;
    }

    // Append the new message to the selected ticket
    if (state.selectedTicket != null &&
        state.selectedTicket!.id == ticketId) {
      final updatedMessages = [
        ...state.selectedTicket!.messages,
        result.data!,
      ];
      final updatedTicket = SupportTicket(
        id: state.selectedTicket!.id,
        subject: state.selectedTicket!.subject,
        category: state.selectedTicket!.category,
        priority: state.selectedTicket!.priority,
        status: state.selectedTicket!.status,
        requester: state.selectedTicket!.requester,
        requesterName: state.selectedTicket!.requesterName,
        order: state.selectedTicket!.order,
        restaurant: state.selectedTicket!.restaurant,
        driver: state.selectedTicket!.driver,
        assignedTo: state.selectedTicket!.assignedTo,
        assignedToName: state.selectedTicket!.assignedToName,
        createdAt: state.selectedTicket!.createdAt,
        updatedAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
        closedAt: state.selectedTicket!.closedAt,
        messages: updatedMessages,
      );
      state = state.copyWith(selectedTicket: updatedTicket);
    }

    state = state.copyWith(isSending: false);
    return true;
  }

  /// Clear selected ticket
  void clearSelectedTicket() {
    state = state.copyWith(clearSelectedTicket: true);
  }
}
