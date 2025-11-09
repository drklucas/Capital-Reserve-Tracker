import 'package:dartz/dartz.dart';
import '../../entities/ai_message_entity.dart';
import '../../repositories/ai_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for getting AI recommendations for achieving goals
class GetGoalRecommendationsUseCase {
  final AIRepository repository;

  GetGoalRecommendationsUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String userId,
    required String goalId,
    required AIProvider provider,
  }) async {
    // Validate inputs
    if (userId.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'User ID cannot be empty',
          fieldErrors: {'userId': 'Required field'},
        ),
      );
    }

    if (goalId.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Goal ID cannot be empty',
          fieldErrors: {'goalId': 'Required field'},
        ),
      );
    }

    return await repository.getGoalRecommendations(
      userId: userId,
      goalId: goalId,
      provider: provider,
    );
  }
}
