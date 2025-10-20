import 'package:dartz/dartz.dart';
import '../../entities/goal_entity.dart';
import '../../repositories/goal_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for updating an existing goal
///
/// This use case encapsulates the business logic for updating a goal,
/// including validation and interaction with the repository.
class UpdateGoalUseCase {
  final GoalRepository repository;

  UpdateGoalUseCase(this.repository);

  /// Execute the use case to update a goal
  ///
  /// Validates the goal data before updating
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> call(GoalEntity goal) async {
    // Validate goal data
    final validation = _validateGoal(goal);
    if (validation != null) {
      return Left(ValidationFailure(message: validation));
    }

    // Update the goal with current timestamp
    final updatedGoal = goal.copyWith(
      updatedAt: DateTime.now(),
    );

    return await repository.updateGoal(updatedGoal);
  }

  /// Validate goal data
  ///
  /// Returns error message if validation fails, null otherwise
  String? _validateGoal(GoalEntity goal) {
    if (goal.id.isEmpty) {
      return 'ID da meta inválido';
    }

    if (goal.title.trim().isEmpty) {
      return 'O título da meta não pode estar vazio';
    }

    if (goal.title.length > 100) {
      return 'O título da meta deve ter no máximo 100 caracteres';
    }

    if (goal.description.length > 500) {
      return 'A descrição deve ter no máximo 500 caracteres';
    }

    // Removido: validação de targetAmount (não é mais usado)

    if (goal.targetDate.isBefore(goal.startDate)) {
      return 'A data alvo não pode ser anterior à data de início';
    }

    return null;
  }
}
