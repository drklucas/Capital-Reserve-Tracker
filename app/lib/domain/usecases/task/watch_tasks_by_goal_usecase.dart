import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for watching tasks by goal (real-time)
class WatchTasksByGoalUseCase {
  final TaskRepository repository;

  WatchTasksByGoalUseCase(this.repository);

  /// Execute the use case
  ///
  /// Returns a stream of tasks for a specific goal with real-time updates
  /// Returns Stream<Either<Failure, List<TaskEntity>>>
  Stream<Either<Failure, List<TaskEntity>>> call({
    required String goalId,
    required String userId,
  }) {
    return repository.watchTasksByGoal(goalId, userId);
  }
}
