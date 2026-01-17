import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Sync operation type for offline queue
enum SyncOperationType { create, update, delete }

/// Entity type for sync operations
enum SyncEntityType { order, menuItem, coupon, category }

/// Sync operation model for queued offline operations
class SyncOperation {
  SyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  final String id;
  final SyncOperationType type;
  final SyncEntityType entityType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  int retryCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'entityType': entityType.name,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        id: json['id'] as String,
        type: SyncOperationType.values.byName(json['type'] as String),
        entityType: SyncEntityType.values.byName(json['entityType'] as String),
        data: json['data'] as Map<String, dynamic>,
        timestamp: DateTime.parse(json['timestamp'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

/// Connection state
enum ConnectionState { online, offline }

/// Offline service for managing offline operations and sync
class OfflineService {
  OfflineService(this._syncQueueBox);

  final Box<String> _syncQueueBox;
  final Connectivity _connectivity = Connectivity();
  final _connectionController = StreamController<ConnectionState>.broadcast();

  static const int maxRetries = 3;

  /// Stream of connection state changes
  Stream<ConnectionState> get connectionStream => _connectionController.stream;

  /// Initialize the service and start listening to connectivity changes
  void initialize() {
    _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);
      _connectionController.add(
        isOnline ? ConnectionState.online : ConnectionState.offline,
      );

      if (isOnline) {
        syncPendingOperations();
      }
    });
  }

  /// Check if currently online
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty &&
        results.any((r) => r != ConnectivityResult.none);
  }

  /// Queue an operation for later sync
  Future<void> queueOperation(SyncOperation operation) async {
    await _syncQueueBox.put(operation.id, jsonEncode(operation.toJson()));
  }

  /// Remove an operation from the queue
  Future<void> removeOperation(String operationId) async {
    await _syncQueueBox.delete(operationId);
  }

  /// Get all pending operations
  List<SyncOperation> getPendingOperations() {
    return _syncQueueBox.values.map((json) {
      return SyncOperation.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get pending operations count
  int get pendingCount => _syncQueueBox.length;

  /// Check if there are pending operations
  bool get hasPendingOperations => _syncQueueBox.isNotEmpty;

  /// Sync all pending operations (called when online)
  Future<void> syncPendingOperations() async {
    if (!await isOnline()) return;

    final operations = getPendingOperations();
    for (final operation in operations) {
      try {
        await _executeSyncOperation(operation);
        await removeOperation(operation.id);
      } catch (e) {
        operation.retryCount++;
        if (operation.retryCount >= maxRetries) {
          // Remove after max retries (could also move to a failed queue)
          await removeOperation(operation.id);
        } else {
          // Update retry count
          await queueOperation(operation);
        }
      }
    }
  }

  /// Execute a sync operation against the API
  Future<void> _executeSyncOperation(SyncOperation operation) async {
    // TODO: Implement actual API calls based on operation type and entity
    // This will be connected to the repository layer
    switch (operation.entityType) {
      case SyncEntityType.order:
        await _syncOrder(operation);
        break;
      case SyncEntityType.menuItem:
        await _syncMenuItem(operation);
        break;
      case SyncEntityType.coupon:
        await _syncCoupon(operation);
        break;
      case SyncEntityType.category:
        await _syncCategory(operation);
        break;
    }
  }

  Future<void> _syncOrder(SyncOperation operation) async {
    // TODO: Implement order sync
  }

  Future<void> _syncMenuItem(SyncOperation operation) async {
    // TODO: Implement menu item sync
  }

  Future<void> _syncCoupon(SyncOperation operation) async {
    // TODO: Implement coupon sync
  }

  Future<void> _syncCategory(SyncOperation operation) async {
    // TODO: Implement category sync
  }

  /// Clear all pending operations
  Future<void> clearAll() async {
    await _syncQueueBox.clear();
  }

  /// Dispose resources
  void dispose() {
    _connectionController.close();
  }
}

/// Provider for the sync queue box
final syncQueueBoxProvider = Provider<Box<String>>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// Provider for the offline service
final offlineServiceProvider = Provider<OfflineService>((ref) {
  final box = ref.watch(syncQueueBoxProvider);
  final service = OfflineService(box);
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for connection state stream
final connectionStateProvider = StreamProvider<ConnectionState>((ref) {
  final service = ref.watch(offlineServiceProvider);
  return service.connectionStream;
});

/// Provider to check if currently online
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(offlineServiceProvider);
  return service.isOnline();
});

/// Provider for pending sync count
final pendingSyncCountProvider = Provider<int>((ref) {
  final service = ref.watch(offlineServiceProvider);
  return service.pendingCount;
});
