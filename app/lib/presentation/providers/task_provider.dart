import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task/create_task_usecase.dart';
import '../../domain/usecases/task/update_task_usecase.dart';
import '../../domain/usecases/task/delete_task_usecase.dart';
import '../../domain/usecases/task/toggle_task_usecase.dart';
import '../../domain/usecases/task/get_tasks_by_goal_usecase.dart';
import '../../domain/usecases/task/watch_tasks_by_goal_usecase.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/task_remote_datasource.dart';

/// Task provider status enumeration
enum TaskStatus {
  initial,
  loading,
  loaded,
  error,
  creating,
  updating,
  deleting,
  toggling,
  reordering,
}

/// Task provider for state management
class TaskProvider extends ChangeNotifier {
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final ToggleTaskUseCase toggleTaskUseCase;
  final GetTasksByGoalUseCase getTasksByGoalUseCase;
  final WatchTasksByGoalUseCase watchTasksByGoalUseCase;
  final TaskRepositoryImpl taskRepository;
  late final TaskRemoteDataSource _taskDataSource;

  TaskProvider({
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskUseCase,
    required this.getTasksByGoalUseCase,
    required this.watchTasksByGoalUseCase,
    required this.taskRepository,
  }) {
    _taskDataSource = taskRepository.remoteDataSource;
  }

  // State
  TaskStatus _status = TaskStatus.initial;
  List<TaskEntity> _tasks = [];
  String? _errorMessage;
  StreamSubscription? _tasksSubscription;
  bool _isReordering = false;

  // Getters
  TaskStatus get status => _status;
  List<TaskEntity> get tasks => _tasks;
  String? get errorMessage => _errorMessage;

  /// Get completed tasks
  List<TaskEntity> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  /// Get pending tasks
  List<TaskEntity> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  /// Get tasks count
  int get taskCount => _tasks.length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;

  /// Get completion percentage
  double get completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    return (completedCount / taskCount) * 100;
  }

  /// Create a new task
  Future<bool> createTask({
    required String userId,
    required String goalId,
    required String title,
    String description = '',
    DateTime? dueDate,
    int priority = 3,
    String? transactionId,
  }) async {
    debugPrint('TaskProvider: Creating task - title=$title, goalId=$goalId, userId=$userId');
    _status = TaskStatus.creating;
    _errorMessage = null;
    notifyListeners();

    final result = await createTaskUseCase(
      userId: userId,
      goalId: goalId,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      transactionId: transactionId,
    );

    return result.fold(
      (failure) {
        debugPrint('TaskProvider: Error creating task - ${failure.message}');
        _status = TaskStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (task) {
        debugPrint('TaskProvider: Task created successfully - id=${task.id}');
        _status = TaskStatus.loaded;
        // Task will be added via stream if watching
        notifyListeners();
        return true;
      },
    );
  }

  /// Update an existing task
  Future<bool> updateTask(TaskEntity task) async {
    _status = TaskStatus.updating;
    _errorMessage = null;
    notifyListeners();

    final result = await updateTaskUseCase(task);

    return result.fold(
      (failure) {
        _status = TaskStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedTask) {
        _status = TaskStatus.loaded;
        // Update local list
        final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId, String userId) async {
    _status = TaskStatus.deleting;
    _errorMessage = null;
    notifyListeners();

    // Use the workaround method that includes userId
    final result = await taskRepository.deleteTaskWithUserId(taskId, userId);

    return result.fold(
      (failure) {
        _status = TaskStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _status = TaskStatus.loaded;
        // Remove from local list
        _tasks.removeWhere((t) => t.id == taskId);
        notifyListeners();
        return true;
      },
    );
  }

  /// Toggle task completion status
  Future<bool> toggleTask(String taskId, String userId) async {
    _status = TaskStatus.toggling;
    _errorMessage = null;

    final result = await toggleTaskUseCase(
      taskId: taskId,
      userId: userId,
    );

    return result.fold(
      (failure) {
        _status = TaskStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedTask) {
        _status = TaskStatus.loaded;
        // Update local list
        final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Get tasks for a goal (one-time fetch)
  Future<void> getTasksByGoal({
    required String goalId,
    required String userId,
  }) async {
    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getTasksByGoalUseCase(
      goalId: goalId,
      userId: userId,
    );

    result.fold(
      (failure) {
        _status = TaskStatus.error;
        _errorMessage = failure.message;
        _tasks = [];
        notifyListeners();
      },
      (tasks) {
        _status = TaskStatus.loaded;
        _tasks = tasks;
        notifyListeners();
      },
    );
  }

  /// Watch tasks for a goal (real-time updates)
  void watchTasksByGoal({
    required String goalId,
    required String userId,
  }) {
    debugPrint('TaskProvider: Starting to watch tasks for goalId=$goalId, userId=$userId');
    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Cancel previous subscription if exists
    _tasksSubscription?.cancel();

    _tasksSubscription = watchTasksByGoalUseCase(
      goalId: goalId,
      userId: userId,
    ).listen(
      (result) {
        result.fold(
          (failure) {
            debugPrint('TaskProvider: Error loading tasks - ${failure.message}');
            _status = TaskStatus.error;
            _errorMessage = failure.message;
            _tasks = [];
            notifyListeners();
          },
          (tasks) {
            debugPrint('TaskProvider: Loaded ${tasks.length} tasks');
            for (var task in tasks) {
              debugPrint('  - Task: ${task.title} (completed: ${task.isCompleted})');
            }
            // Skip stream updates during reordering to prevent visual glitches
            if (!_isReordering) {
              _status = TaskStatus.loaded;
              _tasks = tasks;
              notifyListeners();
            }
          },
        );
      },
      onError: (error) {
        debugPrint('TaskProvider: Stream error - $error');
        _status = TaskStatus.error;
        _errorMessage = error.toString();
        _tasks = [];
        notifyListeners();
      },
    );
  }

  /// Get tasks by priority
  List<TaskEntity> getTasksByPriority(int priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  /// Get overdue tasks
  List<TaskEntity> get overdueTasks {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  /// Get tasks with due date today
  List<TaskEntity> get tasksToday {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == now.year &&
          task.dueDate!.month == now.month &&
          task.dueDate!.day == now.day;
    }).toList();
  }

  /// Reorder tasks within a goal
  /// Updates the order of all tasks based on the new positions
  Future<bool> reorderTasks({
    required String userId,
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      // Set reordering flag to prevent stream updates
      _isReordering = true;
      _status = TaskStatus.reordering;

      // Create a copy of the current tasks list
      final List<TaskEntity> reorderedTasks = List.from(_tasks);

      // Remove the task from old position
      final task = reorderedTasks.removeAt(oldIndex);

      // Insert at new position
      reorderedTasks.insert(newIndex, task);

      // Update local state immediately for smooth UX
      _tasks = reorderedTasks
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(order: entry.key))
          .toList();

      _status = TaskStatus.loaded;
      notifyListeners();

      // Create map of taskId -> new order
      final Map<String, int> orderUpdates = {};
      for (int i = 0; i < reorderedTasks.length; i++) {
        if (reorderedTasks[i].order != i) {
          orderUpdates[reorderedTasks[i].id] = i;
        }
      }

      // Batch update orders in Firestore
      if (orderUpdates.isNotEmpty) {
        await _taskDataSource.batchUpdateTaskOrders(userId, orderUpdates);
      }

      // Wait a bit before allowing stream updates again
      await Future.delayed(const Duration(milliseconds: 500));
      _isReordering = false;

      return true;
    } catch (e) {
      debugPrint('TaskProvider: Error reordering tasks - $e');
      _isReordering = false;
      _status = TaskStatus.error;
      _errorMessage = 'Erro ao reordenar tarefas: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_status == TaskStatus.error) {
      _status = TaskStatus.loaded;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
