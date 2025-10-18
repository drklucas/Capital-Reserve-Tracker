import 'package:dartz/dartz.dart';
import '../../entities/goal_entity.dart';
import '../../repositories/goal_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for getting a single goal by ID
class GetGoalByIdUseCase {
  final GoalRepository repository;

  GetGoalByIdUseCase(this.repository);

  /// Execute the use case to get a goal by ID
  ///
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> call(
    String goalId,
    String userId,
  ) async {
    if (goalId.isEmpty) {
      return Left(ValidationFailure('ID da meta inválido'));
    }

    if (userId.isEmpty) {
      return Left(ValidationFailure('ID do usuário inválido'));
    }

    return await repository.getGoalById(goalId, userId);
  }
}
