import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/usecases/goal/create_goal_usecase.dart';
import '../../domain/usecases/goal/update_goal_usecase.dart';
import '../../domain/usecases/goal/delete_goal_usecase.dart';
import '../../domain/usecases/goal/get_goals_usecase.dart';
import '../../domain/usecases/goal/get_goal_by_id_usecase.dart';
import '../../domain/usecases/goal/watch_goals_usecase.dart';
import '../../domain/usecases/goal/update_goal_status_usecase.dart';
import '../../data/datasources/goal_remote_datasource.dart';
import '../../data/datasources/task_remote_datasource.dart';

/// Goal provider status enumeration for UI state management
enum GoalProviderStatus {
  initial,
  loading,
  loaded,
  error,
  creating,
  updating,
  deleting,
}

/// Goal provider for state management
///
/// This provider manages goal state and handles all goal-related operations
/// including CRUD operations, real-time updates, and filtering.
class GoalProvider extends ChangeNotifier {
  final CreateGoalUseCase createGoalUseCase;
  final UpdateGoalUseCase updateGoalUseCase;
  final DeleteGoalUseCase deleteGoalUseCase;
  final GetGoalsUseCase getGoalsUseCase;
  final GetGoalByIdUseCase getGoalByIdUseCase;
  final WatchGoalsUseCase watchGoalsUseCase;
  final UpdateGoalStatusUseCase updateGoalStatusUseCase;
  final GoalRemoteDataSource goalRemoteDataSource;
  final TaskRemoteDataSource taskRemoteDataSource;

  GoalProvider({
    required this.createGoalUseCase,
    required this.updateGoalUseCase,
    required this.deleteGoalUseCase,
    required this.getGoalsUseCase,
    required this.getGoalByIdUseCase,
    required this.watchGoalsUseCase,
    required this.updateGoalStatusUseCase,
    required this.goalRemoteDataSource,
    required this.taskRemoteDataSource,
  });

  // State
  GoalProviderStatus _status = GoalProviderStatus.initial;
  List<GoalEntity> _goals = [];
  GoalEntity? _selectedGoal;
  String? _errorMessage;
  StreamSubscription<dynamic>? _goalsSubscription;

  // Task statistics for active goals
  int _totalTasksForActiveGoals = 0;
  int _completedTasksForActiveGoals = 0;

  // Getters
  GoalProviderStatus get status => _status;
  List<GoalEntity> get goals => _goals;
  GoalEntity? get selectedGoal => _selectedGoal;
  String? get errorMessage => _errorMessage;

  /// Get total tasks for active goals
  int get totalTasksForActiveGoals => _totalTasksForActiveGoals;

  /// Get completed tasks for active goals
  int get completedTasksForActiveGoals => _completedTasksForActiveGoals;

  /// Get task progress for active goals (0.0 to 1.0)
  double get activeGoalsTaskProgress {
    if (_totalTasksForActiveGoals == 0) return 0.0;
    return _completedTasksForActiveGoals / _totalTasksForActiveGoals;
  }

  /// Get active goals
  List<GoalEntity> get activeGoals =>
      _goals.where((goal) => goal.isActive).toList();

  /// Get completed goals
  List<GoalEntity> get completedGoals =>
      _goals.where((goal) => goal.isCompleted).toList();

  /// Get paused goals
  List<GoalEntity> get pausedGoals =>
      _goals.where((goal) => goal.isPaused).toList();

  /// Get cancelled goals
  List<GoalEntity> get cancelledGoals =>
      _goals.where((goal) => goal.isCancelled).toList();

  /// Get overdue goals
  List<GoalEntity> get overdueGoals =>
      _goals.where((goal) => goal.isOverdue).toList();

  /// Calculate total target amount across all active goals
  int get totalTargetAmount => activeGoals.fold(
      0, (sum, goal) => sum + goal.targetAmount);

  /// Calculate total current amount across all active goals
  int get totalCurrentAmount => activeGoals.fold(
      0, (sum, goal) => sum + goal.currentAmount);

  /// Calculate overall progress percentage
  double get overallProgress {
    if (totalTargetAmount <= 0) return 0.0;
    return (totalCurrentAmount / totalTargetAmount * 100).clamp(0.0, 100.0);
  }

  /// Update task statistics for active goals
  Future<void> _updateTaskStatistics(String userId) async {
    try {
      final activeGoalIds = activeGoals.map((g) => g.id).toList();

      if (activeGoalIds.isEmpty) {
        _totalTasksForActiveGoals = 0;
        _completedTasksForActiveGoals = 0;
        return;
      }

      final tasks = await taskRemoteDataSource.getTasksByGoalIds(
        activeGoalIds,
        userId,
      );

      _totalTasksForActiveGoals = tasks.length;
      _completedTasksForActiveGoals =
          tasks.where((task) => task.isCompleted).length;
    } catch (e) {
      debugPrint('Error updating task statistics: $e');
      _totalTasksForActiveGoals = 0;
      _completedTasksForActiveGoals = 0;
    }
  }

  /// Watch goals in real-time for a user
  void watchGoals(String userId) {
    _status = GoalProviderStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _goalsSubscription?.cancel();
    _goalsSubscription = watchGoalsUseCase(userId).listen(
      (either) {
        either.fold(
          (failure) {
            _status = GoalProviderStatus.error;
            _errorMessage = failure.message;
            notifyListeners();
          },
          (goals) async {
            _goals = goals;
            _status = GoalProviderStatus.loaded;
            _errorMessage = null;
            notifyListeners();

            // Update task statistics for active goals
            await _updateTaskStatistics(userId);
            notifyListeners();
          },
        );
      },
      onError: (error) {
        _status = GoalProviderStatus.error;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Load goals for a user
  Future<void> loadGoals(String userId) async {
    _status = GoalProviderStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getGoalsUseCase(userId);

    result.fold(
      (failure) {
        _status = GoalProviderStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (goals) async {
        _goals = goals;
        _status = GoalProviderStatus.loaded;
        _errorMessage = null;
        notifyListeners();

        // Update task statistics for active goals
        await _updateTaskStatistics(userId);
        notifyListeners();
      },
    );
  }

  /// Create a new goal
  Future<bool> createGoal(GoalEntity goal) async {
    _status = GoalProviderStatus.creating;
    _errorMessage = null;
    notifyListeners();

    final result = await createGoalUseCase(goal);

    return result.fold(
      (failure) {
        _status = GoalProviderStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (createdGoal) {
        // Goal will be added via real-time listener if watching
        _status = GoalProviderStatus.loaded;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Update an existing goal
  Future<bool> updateGoal(GoalEntity goal) async {
    _status = GoalProviderStatus.updating;
    _errorMessage = null;
    notifyListeners();

    final result = await updateGoalUseCase(goal);

    return result.fold(
      (failure) {
        _status = GoalProviderStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedGoal) {
        // Goal will be updated via real-time listener if watching
        _status = GoalProviderStatus.loaded;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Delete a goal
  Future<bool> deleteGoal(String goalId, String userId) async {
    _status = GoalProviderStatus.deleting;
    _errorMessage = null;
    notifyListeners();

    final result = await deleteGoalUseCase(goalId, userId);

    return result.fold(
      (failure) {
        _status = GoalProviderStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        // Goal will be removed via real-time listener if watching
        _status = GoalProviderStatus.loaded;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Load a specific goal by ID
  Future<void> loadGoalById(String goalId, String userId) async {
    _status = GoalProviderStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getGoalByIdUseCase(goalId, userId);

    result.fold(
      (failure) {
        _status = GoalProviderStatus.error;
        _errorMessage = failure.message;
        _selectedGoal = null;
        notifyListeners();
      },
      (goal) {
        _selectedGoal = goal;
        _status = GoalProviderStatus.loaded;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  /// Update goal status
  Future<bool> updateGoalEntityStatus(
    String goalId,
    String userId,
    GoalStatus newStatus,
  ) async {
    _status = GoalProviderStatus.updating;
    _errorMessage = null;
    notifyListeners();

    final result = await updateGoalStatusUseCase(
      goalId,
      userId,
      newStatus,
    );

    return result.fold(
      (failure) {
        _status = GoalProviderStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedGoal) {
        _status = GoalProviderStatus.loaded;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Clear selected goal
  void clearSelectedGoal() {
    _selectedGoal = null;
    notifyListeners();
  }

  /// Recalculate goal's current amount based on transactions
  /// This is called automatically when transactions linked to a goal are modified
  Future<void> recalculateGoalAmount(String goalId, String userId) async {
    try {
      // Calculate current amount from transactions
      final currentAmount = await goalRemoteDataSource.calculateGoalCurrentAmount(
        goalId,
        userId,
      );

      // Get the current goal to preserve other fields
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return;

      final currentGoal = _goals[goalIndex];

      // Update the goal with new current amount
      final updatedGoal = GoalEntity(
        id: currentGoal.id,
        userId: currentGoal.userId,
        title: currentGoal.title,
        description: currentGoal.description,
        targetAmount: currentGoal.targetAmount,
        currentAmount: currentAmount,
        startDate: currentGoal.startDate,
        targetDate: currentGoal.targetDate,
        status: currentGoal.status,
        associatedTransactionIds: currentGoal.associatedTransactionIds,
        createdAt: currentGoal.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await updateGoalUseCase(updatedGoal);

      // The real-time listener will update the local state automatically
    } catch (e) {
      // Silently fail - this is a background operation
      debugPrint('Error recalculating goal amount: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _goalsSubscription?.cancel();
    super.dispose();
  }
}
