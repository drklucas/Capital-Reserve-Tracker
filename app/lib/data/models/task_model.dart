import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

/// Task model for data layer with Firestore serialization
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.userId,
    required super.goalId,
    required super.title,
    required super.description,
    required super.isCompleted,
    super.transactionId,
    super.dueDate,
    required super.priority,
    required super.order,
    required super.createdAt,
    super.updatedAt,
    super.completedAt,
  });

  /// Create TaskModel from TaskEntity
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      userId: entity.userId,
      goalId: entity.goalId,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      transactionId: entity.transactionId,
      dueDate: entity.dueDate,
      priority: entity.priority,
      order: entity.order,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      completedAt: entity.completedAt,
    );
  }

  /// Create TaskModel from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      userId: data['userId'] as String,
      goalId: data['goalId'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      isCompleted: data['isCompleted'] as bool,
      transactionId: data['transactionId'] as String?,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      priority: data['priority'] as int? ?? 3,
      order: data['order'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create TaskModel from JSON map
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool,
      transactionId: json['transactionId'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: json['priority'] as int? ?? 3,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'goalId': goalId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'transactionId': transactionId,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'goalId': goalId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'transactionId': transactionId,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Convert to entity
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      userId: userId,
      goalId: goalId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      transactionId: transactionId,
      dueDate: dueDate,
      priority: priority,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
    );
  }

  /// Create a copy with updated fields
  @override
  TaskModel copyWith({
    String? id,
    String? userId,
    String? goalId,
    String? title,
    String? description,
    bool? isCompleted,
    String? transactionId,
    DateTime? dueDate,
    int? priority,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      transactionId: transactionId ?? this.transactionId,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
