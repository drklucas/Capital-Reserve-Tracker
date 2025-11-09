import 'package:dartz/dartz.dart';
import '../../entities/ai_insight_entity.dart';
import '../../entities/ai_message_entity.dart';
import '../../repositories/ai_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for generating AI insights
class GenerateInsightsUseCase {
  final AIRepository repository;

  GenerateInsightsUseCase(this.repository);

  Future<Either<Failure, List<AIInsightEntity>>> call({
    required String userId,
    required AIProvider provider,
    Map<String, dynamic>? filters,
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

    return await repository.generateInsights(
      userId: userId,
      provider: provider,
      filters: filters,
    );
  }
}
