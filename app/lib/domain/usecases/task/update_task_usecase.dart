import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for updating an existing task
class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// Updates an existing task
  /// Returns Right(TaskEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TaskEntity>> call(TaskEntity task) async {
    // Validate title if provided
    if (task.title.trim().isEmpty) {
      return Left(
        ValidationFailure(message: 'O título da tarefa é obrigatório'),
      );
    }

    if (task.title.trim().length > 100) {
      return Left(
        ValidationFailure(
          message: 'O título não pode ter mais de 100 caracteres',
        ),
      );
    }

    // Validate priority
    if (task.priority < 1 || task.priority > 5) {
      return Left(
        ValidationFailure(message: 'A prioridade deve estar entre 1 e 5'),
      );
    }

    // Update with current timestamp
    final updatedTask = task.copyWith(
      updatedAt: DateTime.now(),
    );

    return await repository.updateTask(updatedTask);
  }
}
