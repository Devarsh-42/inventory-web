// models/production_batch.dart
import 'package:uuid/uuid.dart';
import 'package:visionapp/models/inventory.dart';

class ProductionQueue {
  final String id;
  final String batchNumber;
  final String inventoryId; // Changed from productionId
  final String status;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const List<String> validStatuses = [
    'queued',
    'in progress',
    'completed',
    'paused',
  ];

  ProductionQueue({
    String? id,
    required this.batchNumber,
    required this.inventoryId, // Changed from productionId
    String? status,
    this.progress = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.id = id ?? const Uuid().v4(),
       this.status = status ?? 'queued',
       this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now() {
    // Validate status
    if (!validStatuses.contains(this.status)) {
      throw ArgumentError('Invalid status: ${this.status}');
    }
    // Validate progress
    if (progress < 0 || progress > 100) {
      throw ArgumentError('Progress must be between 0 and 100');
    }
  }

  factory ProductionQueue.fromJson(Map<String, dynamic> json) {
    return ProductionQueue(
      id: json['id'],
      batchNumber: json['batch_number'],
      inventoryId: json['inventory_id'], // Changed from productionId
      status: json['status'],
      progress: (json['progress'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_number': batchNumber,
      'inventory_id': inventoryId, // Changed from productionId
      'status': status,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'in progress':
        return 'In Progress (${progress.toInt()}%)';
      case 'completed':
        return 'Completed';
      case 'queued':
        return 'Queued';
      case 'paused':
        return 'Paused';
      default:
        return status;
    }
  }
}

class ProductionQueueItem {
  final String id;
  final String inventoryId;
  final int quantity;
  final bool completed;
  final int queuePosition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Inventory? inventory; // Add inventory field

  ProductionQueueItem({
    String? id,
    required this.inventoryId,
    required this.quantity,
    this.completed = false,
    this.queuePosition = 0,
    this.inventory, // Add to constructor
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.id = id ?? const Uuid().v4(),
       this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  factory ProductionQueueItem.fromJson(Map<String, dynamic> json) {
    return ProductionQueueItem(
      id: json['id'],
      inventoryId: json['inventory_id'],
      quantity: json['quantity'],
      completed: json['completed'] ?? false,
      queuePosition: json['queue_position'] ?? 0,
      inventory: json['inventory'] != null ? Inventory.fromJson(Map<String, dynamic>.from(json['inventory'])) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_id': inventoryId,
      'quantity': quantity,
      'completed': completed,
      'queue_position': queuePosition,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (inventory != null) 'inventory': inventory!.toJson(),
    };
  }

  // Helper methods
  bool get canComplete => !completed;

  // Helper method to get inventory name
  String get productName => inventory?.productName ?? 'Unknown Product';
}
