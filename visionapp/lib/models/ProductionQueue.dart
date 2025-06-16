// models/production_batch.dart
import 'package:uuid/uuid.dart';
import 'package:visionapp/models/production.dart';
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
    'paused'
  ];

  ProductionQueue({
    String? id,
    required this.batchNumber,
    required this.inventoryId, // Changed from productionId
    String? status,
    this.progress = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? const Uuid().v4(),
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

// models/production_queue_item.dart
class ProductionQueueItem {
  final String id;
  final String inventoryId;
  final int queuePosition;
  final int quantity;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Inventory? inventory;

  ProductionQueueItem({
    String? id,
    required this.inventoryId,
    required this.queuePosition,
    required this.quantity,
    this.completed = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.inventory,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory ProductionQueueItem.fromJson(Map<String, dynamic> json) {
    if (json == null) throw ArgumentError('json cannot be null');
    
    return ProductionQueueItem(
      id: json['id']?.toString() ?? const Uuid().v4(),
      inventoryId: json['inventory_id']?.toString() ?? '',
      queuePosition: (json['queue_position'] ?? 0) as int,
      quantity: (json['quantity'] ?? 0) as int,
      completed: json['completed'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : DateTime.now(),
      inventory: json['inventory'] != null 
          ? Inventory.fromJson(Map<String, dynamic>.from(json['inventory'])) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_id': inventoryId,
      'queue_position': queuePosition,
      'quantity': quantity,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}