import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/goal/watch_goals_usecase.dart';
import '../../domain/usecases/task/watch_tasks_by_goal_usecase.dart';

/// Provider dedicado para a Home Screen
///
/// Gerencia metas e tarefas especificamente para exibição na tela inicial
class HomeScreenProvider extends ChangeNotifier {
  final WatchGoalsUseCase _watchGoalsUseCase;
  final WatchTasksByGoalUseCase _watchTasksByGoalUseCase;

  List<GoalEntity> _goals = [];
  final Map<String, List<TaskEntity>> _tasksByGoal = {};

  StreamSubscription? _goalsSubscription;
  final Map<String, StreamSubscription> _taskSubscriptions = {};

  bool _isLoadingGoals = false;
  String? _error;

  HomeScreenProvider({
    required WatchGoalsUseCase watchGoalsUseCase,
    required WatchTasksByGoalUseCase watchTasksByGoalUseCase,
  })  : _watchGoalsUseCase = watchGoalsUseCase,
        _watchTasksByGoalUseCase = watchTasksByGoalUseCase;

  // Getters
  bool get isLoadingGoals => _isLoadingGoals;
  String? get error => _error;
  List<GoalEntity> get goals => _goals;
  List<GoalEntity> get activeGoals => _goals.where((g) => g.isActive).toList();
  Map<String, List<TaskEntity>> get tasksByGoal => _tasksByGoal;

  /// Retorna as tarefas de uma meta específica
  List<TaskEntity> getTasksForGoal(String goalId) {
    return _tasksByGoal[goalId] ?? [];
  }

  /// Get total tasks for active goals
  int get totalTasksForActiveGoals {
    int total = 0;
    for (var goal in activeGoals) {
      total += (_tasksByGoal[goal.id] ?? []).length;
    }
    return total;
  }

  /// Get completed tasks for active goals
  int get completedTasksForActiveGoals {
    int completed = 0;
    for (var goal in activeGoals) {
      final tasks = _tasksByGoal[goal.id] ?? [];
      completed += tasks.where((task) => task.isCompleted).length;
    }
    return completed;
  }

  /// Get task progress for active goals (0.0 to 1.0)
  double get activeGoalsTaskProgress {
    if (totalTasksForActiveGoals == 0) return 0.0;
    return completedTasksForActiveGoals / totalTasksForActiveGoals;
  }

  /// Inicia observação de metas em tempo real
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

            // Observar tarefas apenas para metas ativas (otimização para Home)
            final activeGoals = goals.where((g) => g.isActive).toList();
            for (var goal in activeGoals) {
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

  /// Observa tarefas de uma meta específica
  void _watchTasksForGoal(String userId, String goalId) {
    // Cancelar subscription existente
    _taskSubscriptions[goalId]?.cancel();

    final stream = _watchTasksByGoalUseCase(
      userId: userId,
      goalId: goalId,
    );

    _taskSubscriptions[goalId] = stream.listen(
      (either) {
        either.fold(
          (failure) {
            debugPrint('HomeScreen: Error watching tasks for goal $goalId: ${failure.message}');
          },
          (tasks) {
            _tasksByGoal[goalId] = tasks;
            notifyListeners();
          },
        );
      },
      onError: (error) {
        debugPrint('HomeScreen: Error in tasks stream for goal $goalId: $error');
      },
    );
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
}
