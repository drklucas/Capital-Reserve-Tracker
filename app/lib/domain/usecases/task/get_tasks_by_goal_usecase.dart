import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for getting tasks by goal
class GetTasksByGoalUseCase {
  final TaskRepository repository;

  GetTasksByGoalUseCase(this.repository);

  /// Execute the use case
  ///
  /// Returns all tasks for a specific goal
  /// Returns Right(List<TaskEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TaskEntity>>> call({
    required String goalId,
    required String userId,
  }) async {
    return await repository.getTasksByGoal(goalId, userId);
  }
}
