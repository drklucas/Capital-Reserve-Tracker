import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/goal/watch_goals_usecase.dart';
import '../../domain/usecases/task/watch_tasks_by_goal_usecase.dart';

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
  final WatchGoalsUseCase _watchGoalsUseCase;
  final WatchTasksByGoalUseCase _watchTasksByGoalUseCase;

  List<TransactionEntity> _transactions = [];
  List<GoalEntity> _goals = [];
  final Map<String, List<TaskEntity>> _tasksByGoal = {};

  StreamSubscription? _goalsSubscription;
  final Map<String, StreamSubscription> _taskSubscriptions = {};

  bool _isLoadingGoals = false;
  String? _error;

  DashboardProvider({
    required WatchGoalsUseCase watchGoalsUseCase,
    required WatchTasksByGoalUseCase watchTasksByGoalUseCase,
  })  : _watchGoalsUseCase = watchGoalsUseCase,
        _watchTasksByGoalUseCase = watchTasksByGoalUseCase;

  bool get isLoadingGoals => _isLoadingGoals;
  String? get error => _error;
  List<GoalEntity> get goals => _goals;
  Map<String, List<TaskEntity>> get tasksByGoal => _tasksByGoal;

  /// Watch goals for the dashboard
  void watchGoals(String userId) {
    _isLoadingGoals = true;
    _error = null;
    notifyListeners();

    _goalsSubscription?.cancel();

    final stream = _watchGoalsUseCase(userId);

    _goalsSubscription = stream.listen(
      (either) {
        either.fold(
          (failure) {
            _error = failure.message;
            _isLoadingGoals = false;
            notifyListeners();
          },
          (goals) {
            _goals = goals;
            _isLoadingGoals = false;
            _error = null;
            notifyListeners();

            // Watch tasks for each goal
            for (var goal in goals) {
              _watchTasksForGoal(userId, goal.id);
            }
          },
        );
      },
      onError: (error) {
        _error = error.toString();
        _isLoadingGoals = false;
        notifyListeners();
      },
    );
  }

  /// Watch tasks for a specific goal
  void _watchTasksForGoal(String userId, String goalId) {
    // Cancel existing subscription for this goal if any
    _taskSubscriptions[goalId]?.cancel();

    final stream = _watchTasksByGoalUseCase(
      userId: userId,
      goalId: goalId,
    );

    _taskSubscriptions[goalId] = stream.listen(
      (either) {
        either.fold(
          (failure) {
            debugPrint('Dashboard: Error watching tasks for goal $goalId: ${failure.message}');
          },
          (tasks) {
            _tasksByGoal[goalId] = tasks;
            notifyListeners();
          },
        );
      },
      onError: (error) {
        debugPrint('Dashboard: Error in tasks stream for goal $goalId: $error');
      },
    );
  }

  /// Update transactions data (still accepts external transaction data)
  void updateTransactions(List<TransactionEntity> transactions) {
    _transactions = transactions;
    notifyListeners();
  }

  @override
  void dispose() {
    _goalsSubscription?.cancel();
    for (var subscription in _taskSubscriptions.values) {
      subscription.cancel();
    }
    _taskSubscriptions.clear();
    super.dispose();
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

  /// Get daily income/expense data for the last week
  List<MonthlyDataPoint> getIncomeExpensesLastWeek() {
    final List<MonthlyDataPoint> data = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));

      final dayTransactions = _transactions.where((t) =>
          t.date.isAfter(day.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(nextDay));

      final income =
          dayTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
      final expenses =
          dayTransactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

      data.add(MonthlyDataPoint(
        month: day,
        income: income,
        expenses: expenses,
        balance: income - expenses,
      ));
    }

    return data;
  }

  /// Get daily income/expense data for the last month
  List<MonthlyDataPoint> getIncomeExpensesLastMonth() {
    final List<MonthlyDataPoint> data = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 29; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));

      final dayTransactions = _transactions.where((t) =>
          t.date.isAfter(day.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(nextDay));

      final income =
          dayTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
      final expenses =
          dayTransactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

      data.add(MonthlyDataPoint(
        month: day,
        income: income,
        expenses: expenses,
        balance: income - expenses,
      ));
    }

    return data;
  }

  /// Get monthly income/expense data for the last year
  List<MonthlyDataPoint> getIncomeExpensesLastYear() {
    final List<MonthlyDataPoint> data = [];
    final now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
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

  /// Get reserve evolution for today (hourly granularity)
  List<MonthlyDataPoint> getReserveEvolutionToday() {
    final List<MonthlyDataPoint> data = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Sort transactions by date
    final sortedTransactions = List<TransactionEntity>.from(_transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get all transactions up to today
    final transactionsUpToToday = sortedTransactions.where(
        (t) => t.date.isBefore(today));

    // Calculate balance at start of day
    final startOfDayBalance = transactionsUpToToday.fold(0.0, (sum, t) => sum + t.signedAmount);

    // Get today's transactions
    final todayTransactions = sortedTransactions.where(
        (t) => t.date.isAfter(today.subtract(const Duration(seconds: 1))) &&
               t.date.isBefore(tomorrow));

    if (todayTransactions.isEmpty) {
      // If no transactions today, show start and end of day with same balance
      data.add(MonthlyDataPoint(
        month: today,
        income: 0,
        expenses: 0,
        balance: startOfDayBalance,
      ));
      data.add(MonthlyDataPoint(
        month: now,
        income: 0,
        expenses: 0,
        balance: startOfDayBalance,
      ));
    } else {
      // Add data point at start of day
      data.add(MonthlyDataPoint(
        month: today,
        income: 0,
        expenses: 0,
        balance: startOfDayBalance,
      ));

      // Add data points for each transaction
      double runningBalance = startOfDayBalance;
      for (var transaction in todayTransactions) {
        runningBalance += transaction.signedAmount;
        data.add(MonthlyDataPoint(
          month: transaction.date,
          income: 0,
          expenses: 0,
          balance: runningBalance,
        ));
      }
    }

    return data;
  }

  /// Get reserve evolution for the last week (daily granularity)
  List<MonthlyDataPoint> getReserveEvolutionLastWeek() {
    final List<MonthlyDataPoint> data = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Sort transactions by date
    final sortedTransactions = List<TransactionEntity>.from(_transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Generate data points for last 7 days
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));

      // Calculate balance up to end of this day
      final transactionsUpToDay = sortedTransactions.where(
          (t) => t.date.isBefore(nextDay));

      final balance = transactionsUpToDay.fold(0.0, (sum, t) => sum + t.signedAmount);

      data.add(MonthlyDataPoint(
        month: day,
        income: 0,
        expenses: 0,
        balance: balance,
      ));
    }

    return data;
  }

  /// Get reserve evolution for the last month (daily granularity)
  List<MonthlyDataPoint> getReserveEvolutionLastMonth() {
    final List<MonthlyDataPoint> data = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Sort transactions by date
    final sortedTransactions = List<TransactionEntity>.from(_transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Generate data points for last 30 days
    for (int i = 29; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));

      // Calculate balance up to end of this day
      final transactionsUpToDay = sortedTransactions.where(
          (t) => t.date.isBefore(nextDay));

      final balance = transactionsUpToDay.fold(0.0, (sum, t) => sum + t.signedAmount);

      data.add(MonthlyDataPoint(
        month: day,
        income: 0,
        expenses: 0,
        balance: balance,
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
