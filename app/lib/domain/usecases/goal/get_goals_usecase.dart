import 'package:dartz/dartz.dart';
import '../../entities/goal_entity.dart';
import '../../repositories/goal_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for getting all goals for a user
class GetGoalsUseCase {
  final GoalRepository repository;

  GetGoalsUseCase(this.repository);

  /// Execute the use case to get all goals
  ///
  /// Returns [Right(List<GoalEntity>)] on success or [Left(Failure)] on error
  Future<Either<Failure, List<GoalEntity>>> call(String userId) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'ID do usuário inválido'));
    }

    return await repository.getGoals(userId);
  }
}
