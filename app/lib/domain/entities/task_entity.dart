import 'package:equatable/equatable.dart';

/// Task entity representing a subtask/checklist item for a goal
/// Tasks can be linked to transactions (both income and expense)
class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String goalId; // Required: task belongs to a goal
  final String title;
  final String description;
  final bool isCompleted;
  final String? transactionId; // Optional: linked transaction
  final DateTime? dueDate;
  final int priority; // 1 (low) to 5 (high)
  final int order; // Order for manual sorting
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.goalId,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.transactionId,
    this.dueDate,
    this.priority = 3,
    this.order = 0,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  /// Check if task has a linked transaction
  bool get hasTransaction => transactionId != null && transactionId!.isNotEmpty;

  /// Check if task is overdue
  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if task has a due date
  bool get hasDueDate => dueDate != null;

  /// Copy with method for creating modified copies
  TaskEntity copyWith({
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
    return TaskEntity(
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

  @override
  List<Object?> get props => [
        id,
        userId,
        goalId,
        title,
        description,
        isCompleted,
        transactionId,
        dueDate,
        priority,
        order,
        createdAt,
        updatedAt,
        completedAt,
      ];

  @override
  String toString() {
    return 'TaskEntity(id: $id, title: $title, isCompleted: $isCompleted, '
        'goalId: $goalId, transactionId: $transactionId)';
  }
}
