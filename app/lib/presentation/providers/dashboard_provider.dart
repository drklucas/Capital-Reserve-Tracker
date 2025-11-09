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
    // Only update and notify if transactions actually changed
    if (_transactions.length != transactions.length ||
        !_areTransactionsEqual(_transactions, transactions)) {
      _transactions = transactions;
      notifyListeners();
    }
  }

  /// Check if two transaction lists are equal
  bool _areTransactionsEqual(List<TransactionEntity> list1, List<TransactionEntity> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
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

  // ==================== SPENDING ANALYSIS METHODS ====================

  /// Get spending by category for expenses only
  /// Returns data sorted by amount (highest first)
  List<CategorySpendingData> getCategorySpending({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Filter transactions
    final filteredTransactions = _transactions.where((t) {
      if (!t.isExpense) return false;
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    if (filteredTransactions.isEmpty) return [];

    // Group by category
    final Map<TransactionCategory, List<TransactionEntity>> categoryGroups = {};
    for (var transaction in filteredTransactions) {
      categoryGroups.putIfAbsent(transaction.category, () => []).add(transaction);
    }

    // Calculate total for percentage
    final totalAmount = filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);

    // Convert to CategorySpendingData
    final data = categoryGroups.entries.map((entry) {
      final amount = entry.value.fold(0.0, (sum, t) => sum + t.amount);
      final percentage = (amount / totalAmount) * 100;
      return CategorySpendingData(
        category: entry.key,
        amount: amount,
        percentage: percentage,
        transactionCount: entry.value.length,
      );
    }).toList();

    // Sort by amount (highest first)
    data.sort((a, b) => b.amount.compareTo(a.amount));

    return data;
  }

  /// Get hourly spending distribution (expenses only)
  /// Returns data for all 24 hours, with 0 for hours with no transactions
  List<HourlySpendingData> getHourlySpending({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Filter expense transactions
    final filteredTransactions = _transactions.where((t) {
      if (!t.isExpense) return false;
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    // Initialize data for all 24 hours
    final Map<int, List<TransactionEntity>> hourlyGroups = {};
    for (int hour = 0; hour < 24; hour++) {
      hourlyGroups[hour] = [];
    }

    // Group transactions by hour
    for (var transaction in filteredTransactions) {
      final hour = transaction.date.hour;
      hourlyGroups[hour]!.add(transaction);
    }

    // Convert to HourlySpendingData
    return hourlyGroups.entries.map((entry) {
      final amount = entry.value.fold(0.0, (sum, t) => sum + t.amount);
      return HourlySpendingData(
        hour: entry.key,
        amount: amount,
        transactionCount: entry.value.length,
      );
    }).toList()..sort((a, b) => a.hour.compareTo(b.hour));
  }

  /// Get daily spending pattern (by day of week)
  /// Returns data for all 7 days of the week
  List<DailySpendingPatternData> getDailySpendingPattern({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Filter expense transactions
    final filteredTransactions = _transactions.where((t) {
      if (!t.isExpense) return false;
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    // Initialize data for all 7 days (1=Monday to 7=Sunday)
    final Map<int, List<TransactionEntity>> dailyGroups = {};
    for (int day = 1; day <= 7; day++) {
      dailyGroups[day] = [];
    }

    // Group transactions by day of week
    for (var transaction in filteredTransactions) {
      final dayOfWeek = transaction.date.weekday; // 1=Monday, 7=Sunday
      dailyGroups[dayOfWeek]!.add(transaction);
    }

    // Convert to DailySpendingPatternData
    return dailyGroups.entries.map((entry) {
      final amount = entry.value.fold(0.0, (sum, t) => sum + t.amount);
      return DailySpendingPatternData(
        dayOfWeek: entry.key,
        amount: amount,
        transactionCount: entry.value.length,
      );
    }).toList()..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
  }

  /// Get value range distribution for expenses
  /// Automatically creates ranges based on data distribution
  List<ValueRangeData> getValueRangeDistribution({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Filter expense transactions
    final filteredTransactions = _transactions.where((t) {
      if (!t.isExpense) return false;
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    if (filteredTransactions.isEmpty) return [];

    // Define value ranges (in BRL)
    final ranges = [
      {'min': 0.0, 'max': 50.0, 'label': 'R\$ 0-50'},
      {'min': 50.0, 'max': 100.0, 'label': 'R\$ 50-100'},
      {'min': 100.0, 'max': 200.0, 'label': 'R\$ 100-200'},
      {'min': 200.0, 'max': 500.0, 'label': 'R\$ 200-500'},
      {'min': 500.0, 'max': 1000.0, 'label': 'R\$ 500-1K'},
      {'min': 1000.0, 'max': double.infinity, 'label': 'R\$ 1K+'},
    ];

    // Group transactions by range
    final rangeData = <ValueRangeData>[];
    for (var range in ranges) {
      final min = range['min'] as double;
      final max = range['max'] as double;
      final label = range['label'] as String;

      final rangeTransactions = filteredTransactions.where((t) {
        return t.amount >= min && t.amount < max;
      }).toList();

      if (rangeTransactions.isNotEmpty) {
        final totalAmount = rangeTransactions.fold(0.0, (sum, t) => sum + t.amount);
        rangeData.add(
          ValueRangeData(
            range: label,
            minValue: min,
            maxValue: max == double.infinity ? rangeTransactions.map((t) => t.amount).reduce((a, b) => a > b ? a : b) : max,
            transactionCount: rangeTransactions.length,
            totalAmount: totalAmount,
          ),
        );
      }
    }

    return rangeData;
  }
}

// ==================== DATA MODELS FOR CHARTS ====================

/// Category spending data model
class CategorySpendingData {
  final TransactionCategory category;
  final double amount;
  final double percentage;
  final int transactionCount;

  const CategorySpendingData({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

/// Hourly spending data model
class HourlySpendingData {
  final int hour; // 0-23
  final double amount;
  final int transactionCount;

  const HourlySpendingData({
    required this.hour,
    required this.amount,
    required this.transactionCount,
  });
}

/// Daily spending pattern data model
class DailySpendingPatternData {
  final int dayOfWeek; // 1 (Monday) - 7 (Sunday)
  final double amount;
  final int transactionCount;

  const DailySpendingPatternData({
    required this.dayOfWeek,
    required this.amount,
    required this.transactionCount,
  });
}

/// Value range data model
class ValueRangeData {
  final String range; // e.g., "R\$ 0-50"
  final double minValue;
  final double maxValue;
  final int transactionCount;
  final double totalAmount;

  const ValueRangeData({
    required this.range,
    required this.minValue,
    required this.maxValue,
    required this.transactionCount,
    required this.totalAmount,
  });
}
