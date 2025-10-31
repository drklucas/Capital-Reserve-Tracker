import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/goal/watch_goals_usecase.dart';
import '../../domain/usecases/task/watch_tasks_by_goal_usecase.dart';

/// Provider dedicado para a tela de Metas (GoalsScreen)
///
/// Gerencia suas próprias instâncias de metas e tarefas,
/// mantendo os dados sempre disponíveis e evitando recarregamentos
class GoalsScreenProvider extends ChangeNotifier {
  final WatchGoalsUseCase _watchGoalsUseCase;
  final WatchTasksByGoalUseCase _watchTasksByGoalUseCase;

  List<GoalEntity> _goals = [];
  final Map<String, List<TaskEntity>> _tasksByGoal = {};

  StreamSubscription? _goalsSubscription;
  final Map<String, StreamSubscription> _taskSubscriptions = {};

  bool _isLoadingGoals = false;
  String? _error;

  GoalsScreenProvider({
    required WatchGoalsUseCase watchGoalsUseCase,
    required WatchTasksByGoalUseCase watchTasksByGoalUseCase,
  })  : _watchGoalsUseCase = watchGoalsUseCase,
        _watchTasksByGoalUseCase = watchTasksByGoalUseCase;

  // Getters
  bool get isLoadingGoals => _isLoadingGoals;
  String? get error => _error;
  List<GoalEntity> get goals => _goals;
  Map<String, List<TaskEntity>> get tasksByGoal => _tasksByGoal;

  /// Retorna apenas as metas ativas
  List<GoalEntity> get activeGoals =>
      _goals.where((goal) => goal.status == GoalStatus.active).toList();

  /// Retorna apenas as metas concluídas
  List<GoalEntity> get completedGoals =>
      _goals.where((goal) => goal.status == GoalStatus.completed).toList();

  /// Total de tarefas para metas ativas
  int get totalTasksForActiveGoals {
    final activeGoalIds = activeGoals.map((g) => g.id).toSet();
    int total = 0;
    for (var goalId in activeGoalIds) {
      total += (_tasksByGoal[goalId] ?? []).length;
    }
    return total;
  }

  /// Total de tarefas concluídas para metas ativas
  int get completedTasksForActiveGoals {
    final activeGoalIds = activeGoals.map((g) => g.id).toSet();
    int completed = 0;
    for (var goalId in activeGoalIds) {
      completed += (_tasksByGoal[goalId] ?? [])
          .where((task) => task.isCompleted)
          .length;
    }
    return completed;
  }

  /// Retorna as tarefas de uma meta específica
  List<TaskEntity> getTasksForGoal(String goalId) {
    return _tasksByGoal[goalId] ?? [];
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

            // Observar tarefas para cada meta
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
            debugPrint('GoalsScreen: Error watching tasks for goal $goalId: ${failure.message}');
          },
          (tasks) {
            _tasksByGoal[goalId] = tasks;
            notifyListeners();
          },
        );
      },
      onError: (error) {
        debugPrint('GoalsScreen: Error in tasks stream for goal $goalId: $error');
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
