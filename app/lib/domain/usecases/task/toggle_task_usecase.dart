import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for toggling task completion status
class ToggleTaskUseCase {
  final TaskRepository repository;

  ToggleTaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// Toggles task completion status (true <-> false)
  /// Updates completedAt timestamp when marking as complete
  /// Returns Right(TaskEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TaskEntity>> call({
    required String taskId,
    required String userId,
  }) async {
    return await repository.toggleTaskCompletion(taskId, userId);
  }
}
