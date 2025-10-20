import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final createdTask = await remoteDataSource.createTask(taskModel);
      return Right(createdTask.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final updatedTask = await remoteDataSource.updateTask(taskModel);
      return Right(updatedTask.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      // Note: We need userId for Firestore path, but it's not in the interface
      // This is a design limitation - for now, we'll need to handle it differently
      // TODO: Consider adding userId to delete method or finding another solution
      throw UnimplementedError(
        'Delete requires userId - use deleteTaskWithUserId instead',
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Delete with userId (workaround for Firestore path requirement)
  Future<Either<Failure, void>> deleteTaskWithUserId(
    String taskId,
    String userId,
  ) async {
    try {
      await remoteDataSource.deleteTask(taskId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskById(
    String taskId,
    String userId,
  ) async {
    try {
      final task = await remoteDataSource.getTaskById(taskId, userId);
      return Right(task.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByGoal(
    String goalId,
    String userId,
  ) async {
    try {
      final tasks = await remoteDataSource.getTasksByGoal(goalId, userId);
      return Right(tasks.map((task) => task.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId) async {
    try {
      final tasks = await remoteDataSource.getTasks(userId);
      return Right(tasks.map((task) => task.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasksByGoal(
    String goalId,
    String userId,
  ) {
    try {
      return remoteDataSource.watchTasksByGoal(goalId, userId).map(
            (tasks) => Right<Failure, List<TaskEntity>>(
              tasks.map((task) => task.toEntity()).toList(),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasks(String userId) {
    try {
      return remoteDataSource.watchTasks(userId).map(
            (tasks) => Right<Failure, List<TaskEntity>>(
              tasks.map((task) => task.toEntity()).toList(),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> toggleTaskCompletion(
    String taskId,
    String userId,
  ) async {
    try {
      final task = await remoteDataSource.toggleTaskCompletion(taskId, userId);
      return Right(task.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasksByGoal(
    String goalId,
    String userId,
  ) async {
    try {
      final tasks =
          await remoteDataSource.getCompletedTasksByGoal(goalId, userId);
      return Right(tasks.map((task) => task.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getPendingTasksByGoal(
    String goalId,
    String userId,
  ) async {
    try {
      final tasks =
          await remoteDataSource.getPendingTasksByGoal(goalId, userId);
      return Right(tasks.map((task) => task.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
