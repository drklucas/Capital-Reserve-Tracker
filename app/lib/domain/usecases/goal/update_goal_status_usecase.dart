import 'package:dartz/dartz.dart';
import '../../entities/goal_entity.dart';
import '../../repositories/goal_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for updating goal status
class UpdateGoalStatusUseCase {
  final GoalRepository repository;

  UpdateGoalStatusUseCase(this.repository);

  /// Execute the use case to update goal status
  ///
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> call(
    String goalId,
    String userId,
    GoalStatus status,
  ) async {
    if (goalId.isEmpty) {
      return Left(ValidationFailure('ID da meta inválido'));
    }

    if (userId.isEmpty) {
      return Left(ValidationFailure('ID do usuário inválido'));
    }

    return await repository.updateGoalStatus(goalId, userId, status);
  }
}
