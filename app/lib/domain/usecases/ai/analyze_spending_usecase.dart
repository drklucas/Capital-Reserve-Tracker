import 'package:dartz/dartz.dart';
import '../../entities/ai_message_entity.dart';
import '../../repositories/ai_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for analyzing spending patterns
class AnalyzeSpendingUseCase {
  final AIRepository repository;

  AnalyzeSpendingUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String userId,
    required AIProvider provider,
    DateTime? startDate,
    DateTime? endDate,
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

    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Left(
        ValidationFailure(
          message: 'Start date must be before end date',
          fieldErrors: {'dateRange': 'Invalid date range'},
        ),
      );
    }

    return await repository.analyzeSpending(
      userId: userId,
      provider: provider,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
