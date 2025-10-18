import 'package:dartz/dartz.dart';
import '../../entities/goal_entity.dart';
import '../../repositories/goal_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for watching goals in real-time
class WatchGoalsUseCase {
  final GoalRepository repository;

  WatchGoalsUseCase(this.repository);

  /// Execute the use case to watch goals
  ///
  /// Returns a stream that emits [Right(List<GoalEntity>)] on success
  /// or [Left(Failure)] on error
  Stream<Either<Failure, List<GoalEntity>>> call(String userId) {
    if (userId.isEmpty) {
      return Stream.value(Left(ValidationFailure(message: 'ID do usuário inválido')));
    }

    return repository.watchGoals(userId);
  }
}
