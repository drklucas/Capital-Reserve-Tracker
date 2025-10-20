import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/task_repository.dart';

/// Use case for deleting a task
class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// Deletes a task by ID
  /// Returns Right(void) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, void>> call({required String taskId}) async {
    return await repository.deleteTask(taskId);
  }
}
