import 'package:dartz/dartz.dart';
import '../../entities/goal_entity.dart';
import '../../repositories/goal_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for creating a new goal
///
/// This use case encapsulates the business logic for creating a goal,
/// including validation and interaction with the repository.
class CreateGoalUseCase {
  final GoalRepository repository;

  CreateGoalUseCase(this.repository);

  /// Execute the use case to create a new goal
  ///
  /// Validates the goal data before creating
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> call(GoalEntity goal) async {
    // Validate goal data
    final validation = _validateGoal(goal);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }

    // Create the goal
    return await repository.createGoal(goal);
  }

  /// Validate goal data
  ///
  /// Returns error message if validation fails, null otherwise
  String? _validateGoal(GoalEntity goal) {
    if (goal.title.trim().isEmpty) {
      return 'O título da meta não pode estar vazio';
    }

    if (goal.title.length > 100) {
      return 'O título da meta deve ter no máximo 100 caracteres';
    }

    if (goal.description.length > 500) {
      return 'A descrição deve ter no máximo 500 caracteres';
    }

    if (goal.targetAmount <= 0) {
      return 'O valor alvo deve ser maior que zero';
    }

    if (goal.targetAmount > 1000000000) {
      // 10 million in currency
      return 'O valor alvo é muito alto';
    }

    if (goal.targetDate.isBefore(goal.startDate)) {
      return 'A data alvo não pode ser anterior à data de início';
    }

    if (goal.startDate.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      return 'A data de início não pode ser muito distante no futuro';
    }

    return null;
  }
}
