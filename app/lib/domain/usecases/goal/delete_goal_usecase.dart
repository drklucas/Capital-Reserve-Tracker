import 'package:dartz/dartz.dart';
import '../../repositories/goal_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for deleting a goal
///
/// This use case encapsulates the business logic for deleting a goal.
class DeleteGoalUseCase {
  final GoalRepository repository;

  DeleteGoalUseCase(this.repository);

  /// Execute the use case to delete a goal
  ///
  /// Returns [Right(void)] on success or [Left(Failure)] on error
  Future<Either<Failure, void>> call(String goalId, String userId) async {
    if (goalId.isEmpty) {
      return Left(ValidationFailure('ID da meta inválido'));
    }

    if (userId.isEmpty) {
      return Left(ValidationFailure('ID do usuário inválido'));
    }

    return await repository.deleteGoal(goalId, userId);
  }
}
