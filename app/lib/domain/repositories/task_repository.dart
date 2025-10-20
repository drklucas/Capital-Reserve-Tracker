import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/task_entity.dart';

/// Repository interface for task operations
///
/// Defines all task-related data operations that can be performed.
/// Implementations will handle the actual data source interactions.
abstract class TaskRepository {
  /// Create a new task
  ///
  /// Returns Right(TaskEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);

  /// Update an existing task
  ///
  /// Returns Right(TaskEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);

  /// Delete a task by ID
  ///
  /// Returns Right(void) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, void>> deleteTask(String taskId);

  /// Get a task by ID
  ///
  /// Returns Right(TaskEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TaskEntity>> getTaskById(String taskId, String userId);

  /// Get all tasks for a specific goal
  ///
  /// Returns Right(List<TaskEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TaskEntity>>> getTasksByGoal(
    String goalId,
    String userId,
  );

  /// Get all tasks for a user
  ///
  /// Returns Right(List<TaskEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId);

  /// Watch tasks for a specific goal (real-time updates)
  ///
  /// Returns Stream<Either<Failure, List<TaskEntity>>>
  Stream<Either<Failure, List<TaskEntity>>> watchTasksByGoal(
    String goalId,
    String userId,
  );

  /// Watch all tasks for a user (real-time updates)
  ///
  /// Returns Stream<Either<Failure, List<TaskEntity>>>
  Stream<Either<Failure, List<TaskEntity>>> watchTasks(String userId);

  /// Toggle task completion status
  ///
  /// Returns Right(TaskEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TaskEntity>> toggleTaskCompletion(
    String taskId,
    String userId,
  );

  /// Get completed tasks for a goal
  ///
  /// Returns Right(List<TaskEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasksByGoal(
    String goalId,
    String userId,
  );

  /// Get pending tasks for a goal
  ///
  /// Returns Right(List<TaskEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TaskEntity>>> getPendingTasksByGoal(
    String goalId,
    String userId,
  );
}
