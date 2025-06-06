// models/production_batch.dart
import 'package:uuid/uuid.dart';
import 'package:visionapp/models/production.dart';

class ProductionBatch {
  final String id;
  final String batchNumber;
  final String productionId;
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

  ProductionBatch({
    String? id,
    required this.batchNumber,
    required this.productionId,
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

  factory ProductionBatch.fromJson(Map<String, dynamic> json) {
    return ProductionBatch(
      id: json['id'],
      batchNumber: json['batch_number'],
      productionId: json['production_id'],
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
      'production_id': productionId,
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
  final String productionId;
  final int queuePosition;
  final int quantity;
  final Production production;
  final ProductionBatch? batch;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool completed;
  final String displayName;
  final String status;

  ProductionQueueItem({
    String? id,
    required this.productionId,
    required this.queuePosition,
    required this.quantity,
    required this.production,
    this.batch,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.completed = false,
    required this.displayName,
    this.status = 'pending',
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory ProductionQueueItem.fromJson(Map<String, dynamic> json) {
    return ProductionQueueItem(
      id: json['id'],
      productionId: json['production_id'],
      queuePosition: json['queue_position'],
      quantity: json['quantity'],
      production: Production.fromJson(json['production']),
      batch: json['batch'] != null ? ProductionBatch.fromJson(json['batch']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      completed: json['completed'] ?? false,
      displayName: json['display_name'] ?? json['production']['product_name'],
      status: json['status'] ?? 'pending',
    );
  }

  bool get isCompleted => completed;
}