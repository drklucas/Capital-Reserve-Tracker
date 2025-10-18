import 'package:equatable/equatable.dart';

/// Goal status enumeration
enum GoalStatus {
  active,
  completed,
  paused,
  cancelled;

  String get displayName {
    switch (this) {
      case GoalStatus.active:
        return 'Ativa';
      case GoalStatus.completed:
        return 'Concluída';
      case GoalStatus.paused:
        return 'Pausada';
      case GoalStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Parse string to GoalStatus
  static GoalStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return GoalStatus.active;
      case 'completed':
        return GoalStatus.completed;
      case 'paused':
        return GoalStatus.paused;
      case 'cancelled':
        return GoalStatus.cancelled;
      default:
        throw ArgumentError('Invalid goal status: $value');
    }
  }
}

/// Goal entity representing a financial goal in the domain layer
///
/// This entity represents a financial goal that the user wants to achieve,
/// such as saving for a sabbatical year. It contains all the business logic
/// related to goal tracking, progress calculation, and status management.
class GoalEntity extends Equatable {
  /// Unique identifier for the goal
  final String id;

  /// User ID who owns this goal
  final String userId;

  /// Goal title (e.g., "Sabbatical Year Fund")
  final String title;

  /// Detailed description of the goal
  final String description;

  /// Target amount to achieve (in cents to avoid floating point issues)
  final int targetAmount;

  /// Current amount saved towards the goal (calculated from transactions)
  final int currentAmount;

  /// Date when the goal was started
  final DateTime startDate;

  /// Target date to achieve the goal
  final DateTime targetDate;

  /// Current status of the goal
  final GoalStatus status;

  /// List of transaction IDs associated with this goal
  final List<String> associatedTransactionIds;

  /// Timestamp when the goal was created
  final DateTime createdAt;

  /// Timestamp when the goal was last updated
  final DateTime? updatedAt;

  const GoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.targetDate,
    required this.status,
    required this.associatedTransactionIds,
    required this.createdAt,
    this.updatedAt,
  });

  /// Calculate progress percentage (0-100)
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final progress = (currentAmount / targetAmount) * 100;
    return progress.clamp(0.0, 100.0);
  }

  /// Get remaining amount to achieve the goal
  int get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if goal is completed (reached target amount)
  bool get isCompleted => currentAmount >= targetAmount;

  /// Check if goal is active
  bool get isActive => status == GoalStatus.active;

  /// Check if goal is paused
  bool get isPaused => status == GoalStatus.paused;

  /// Check if goal is cancelled
  bool get isCancelled => status == GoalStatus.cancelled;

  /// Calculate days remaining until target date
  int get daysRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return targetDate.difference(now).inDays;
  }

  /// Calculate days elapsed since start date
  int get daysElapsed {
    final now = DateTime.now();
    return now.difference(startDate).inDays;
  }

  /// Calculate total days from start to target
  int get totalDays {
    return targetDate.difference(startDate).inDays;
  }

  /// Check if goal is overdue (past target date and not completed)
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(targetDate);
  }

  /// Calculate required daily savings to achieve goal
  double get requiredDailySavings {
    if (daysRemaining <= 0) return 0.0;
    return remainingAmount / daysRemaining;
  }

  /// Calculate average daily savings so far
  double get averageDailySavings {
    if (daysElapsed <= 0) return 0.0;
    return currentAmount / daysElapsed;
  }

  /// Check if on track to achieve goal (comparing average vs required)
  bool get isOnTrack {
    if (isCompleted) return true;
    if (daysRemaining <= 0) return false;
    return averageDailySavings >= requiredDailySavings;
  }

  /// Estimated completion date based on current progress
  DateTime? get estimatedCompletionDate {
    if (isCompleted) return DateTime.now();
    if (averageDailySavings <= 0) return null;

    final daysNeeded = (remainingAmount / averageDailySavings).ceil();
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  /// Check if goal has associated transactions
  bool get hasTransactions => associatedTransactionIds.isNotEmpty;

  /// Get number of associated transactions
  int get transactionCount => associatedTransactionIds.length;

  /// Create a copy of this entity with updated fields
  GoalEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? targetAmount,
    int? currentAmount,
    DateTime? startDate,
    DateTime? targetDate,
    GoalStatus? status,
    List<String>? associatedTransactionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      associatedTransactionIds:
          associatedTransactionIds ?? this.associatedTransactionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        targetAmount,
        currentAmount,
        startDate,
        targetDate,
        status,
        associatedTransactionIds,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'GoalEntity(id: $id, title: $title, progress: ${progressPercentage.toStringAsFixed(1)}%, status: $status)';
  }
}
