import 'package:flutter/foundation.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/task_entity.dart';

/// Dashboard data model for summary cards
class DashboardSummary {
  final double totalReserve;
  final double totalGoalAmount;
  final double progressPercentage;
  final double monthlyBalance;
  final double monthlyIncome;
  final double monthlyExpenses;

  const DashboardSummary({
    required this.totalReserve,
    required this.totalGoalAmount,
    required this.progressPercentage,
    required this.monthlyBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  });
}

/// Monthly data point for charts
class MonthlyDataPoint {
  final DateTime month;
  final double income;
  final double expenses;
  final double balance;

  const MonthlyDataPoint({
    required this.month,
    required this.income,
    required this.expenses,
    required this.balance,
  });
}

/// Goal progress data for charts
class GoalProgressData {
  final String goalId;
  final String goalTitle;
  final double progressPercentage;
  final int completedTasks;
  final int totalTasks;
  final bool isOnTrack;

  const GoalProgressData({
    required this.goalId,
    required this.goalTitle,
    required this.progressPercentage,
    required this.completedTasks,
    required this.totalTasks,
    required this.isOnTrack,
  });
}

/// Risky goal data for insights
class RiskyGoalData {
  final String goalId;
  final String goalTitle;
  final int daysRemaining;
  final double progressPercentage;

  const RiskyGoalData({
    required this.goalId,
    required this.goalTitle,
    required this.daysRemaining,
    required this.progressPercentage,
  });
}

/// Dashboard provider for calculating and managing dashboard data
class DashboardProvider extends ChangeNotifier {
  List<TransactionEntity> _transactions = [];
  List<GoalEntity> _goals = [];
  Map<String, List<TaskEntity>> _tasksByGoal = {};

  /// Update transactions data
  void updateTransactions(List<TransactionEntity> transactions) {
    _transactions = transactions;
    notifyListeners();
  }

  /// Update goals data
  void updateGoals(List<GoalEntity> goals) {
    _goals = goals;
    notifyListeners();
  }

  /// Update tasks by goal
  void updateTasksByGoal(Map<String, List<TaskEntity>> tasksByGoal) {
    _tasksByGoal = tasksByGoal;
    notifyListeners();
  }

  /// Calculate total reserve (sum of all transactions)
  double get totalReserve {
    return _transactions.fold(0.0, (sum, t) => sum + t.signedAmount);
  }

  /// Calculate total goal amount (sum of active goals)
  double get totalGoalAmount {
    return _goals
        .where((g) => g.isActive)
        .fold(0.0, (sum, g) => sum + (g.targetAmount / 100));
  }

  /// Calculate overall progress percentage (based on tasks)
  double get overallProgressPercentage {
    final activeGoals = _goals.where((g) => g.isActive).toList();
    if (activeGoals.isEmpty) return 0.0;

    int totalTasks = 0;
    int completedTasks = 0;

    for (var goal in activeGoals) {
      final tasks = _tasksByGoal[goal.id] ?? [];
      totalTasks += tasks.length;
      completedTasks += tasks.where((t) => t.isCompleted).length;
    }

    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks * 100).clamp(0.0, 100.0);
  }

  /// Calculate deficit or surplus
  double get deficitOrSurplus {
    return totalReserve - totalGoalAmount;
  }

  /// Get current month's balance
  double get currentMonthBalance {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where((t) =>
            t.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
            t.date.isBefore(lastDayOfMonth.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.signedAmount);
  }

  /// Get current month's income
  double get currentMonthIncome {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where((t) =>
            t.isIncome &&
            t.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
            t.date.isBefore(lastDayOfMonth.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get current month's expenses
  double get currentMonthExpenses {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where((t) =>
            t.isExpense &&
            t.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
            t.date.isBefore(lastDayOfMonth.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get dashboard summary
  DashboardSummary get summary {
    return DashboardSummary(
      totalReserve: totalReserve,
      totalGoalAmount: totalGoalAmount,
      progressPercentage: overallProgressPercentage,
      monthlyBalance: currentMonthBalance,
      monthlyIncome: currentMonthIncome,
      monthlyExpenses: currentMonthExpenses,
    );
  }

  /// Get monthly data for the last N months
  List<MonthlyDataPoint> getMonthlyData(int months) {
    final List<MonthlyDataPoint> data = [];
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final monthTransactions = _transactions.where((t) =>
          t.date.isAfter(month.subtract(const Duration(days: 1))) &&
          t.date.isBefore(nextMonth));

      final income =
          monthTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
      final expenses =
          monthTransactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

      data.add(MonthlyDataPoint(
        month: month,
        income: income,
        expenses: expenses,
        balance: income - expenses,
      ));
    }

    return data;
  }

  /// Get reserve evolution over the last N months
  List<MonthlyDataPoint> getReserveEvolution(int months) {
    final List<MonthlyDataPoint> data = [];
    final now = DateTime.now();
    double runningBalance = 0.0;

    // Sort transactions by date
    final sortedTransactions = List<TransactionEntity>.from(_transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      // Calculate balance up to this month
      final transactionsUpToMonth = sortedTransactions.where(
          (t) => t.date.isBefore(nextMonth));

      runningBalance = transactionsUpToMonth.fold(0.0, (sum, t) => sum + t.signedAmount);

      data.add(MonthlyDataPoint(
        month: month,
        income: 0, // Not used for reserve evolution
        expenses: 0, // Not used for reserve evolution
        balance: runningBalance,
      ));
    }

    return data;
  }

  /// Get goal progress data for all active goals (based on tasks)
  List<GoalProgressData> get goalsProgress {
    return _goals
        .where((g) => g.isActive)
        .map((g) {
          final tasks = _tasksByGoal[g.id] ?? [];
          final totalTasks = tasks.length;
          final completedTasks = tasks.where((t) => t.isCompleted).length;
          final progressPercentage = totalTasks > 0
              ? (completedTasks / totalTasks) * 100
              : 0.0;

          return GoalProgressData(
            goalId: g.id,
            goalTitle: g.title,
            progressPercentage: progressPercentage,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            isOnTrack: totalTasks > 0 ? progressPercentage >= 50 : true,
          );
        })
        .toList()
      ..sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
  }

  /// Identify risky goals (deadline < 30 days and progress < 50%)
  List<RiskyGoalData> get riskyGoals {
    return _goals
        .where((g) =>
            g.isActive &&
            g.daysRemaining <= 30 &&
            g.daysRemaining > 0 &&
            g.progressPercentage < 50)
        .map((g) => RiskyGoalData(
              goalId: g.id,
              goalTitle: g.title,
              daysRemaining: g.daysRemaining,
              progressPercentage: g.progressPercentage,
            ))
        .toList()
      ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
  }

  /// Calculate average monthly savings (last 6 months)
  double get averageMonthlySavings {
    final monthlyData = getMonthlyData(6);
    if (monthlyData.isEmpty) return 0.0;

    final totalBalance =
        monthlyData.fold(0.0, (sum, data) => sum + data.balance);
    return totalBalance / monthlyData.length;
  }

  /// Calculate savings velocity (per week)
  double get savingsVelocityPerWeek {
    // Get transactions from last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentBalance = _transactions
        .where((t) => t.date.isAfter(thirtyDaysAgo))
        .fold(0.0, (sum, t) => sum + t.signedAmount);

    // Convert to weekly rate
    return (recentBalance / 30) * 7;
  }

  /// Get number of active goals
  int get activeGoalsCount {
    return _goals.where((g) => g.isActive).length;
  }

  /// Get number of completed goals
  int get completedGoalsCount {
    return _goals.where((g) => g.status == GoalStatus.completed).length;
  }

  /// Get the goal closest to completion
  GoalEntity? get closestGoal {
    final activeGoals = _goals.where((g) => g.isActive).toList();
    if (activeGoals.isEmpty) return null;

    activeGoals.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
    return activeGoals.first;
  }

  /// Calculate average days to complete goals (from completed goals)
  double get averageDaysToComplete {
    final completedGoals =
        _goals.where((g) => g.status == GoalStatus.completed).toList();
    if (completedGoals.isEmpty) return 0.0;

    final totalDays =
        completedGoals.fold(0, (sum, g) => sum + g.daysElapsed);
    return totalDays / completedGoals.length;
  }
}
