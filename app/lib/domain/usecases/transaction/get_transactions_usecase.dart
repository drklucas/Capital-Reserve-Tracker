import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

/// Use case for getting transactions with optional filters
class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  /// Execute the use case
  ///
  /// Gets all transactions for a user with optional filters
  /// Returns Right(List<TransactionEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TransactionEntity>>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
    int? limit,
  }) async {
    if (userId.trim().isEmpty) {
      return Left(
        ValidationFailure(message: 'ID do usuário é obrigatório'),
      );
    }

    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Left(
        ValidationFailure(
          message: 'A data inicial deve ser anterior à data final',
        ),
      );
    }

    return await repository.getTransactions(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      goalId: goalId,
      limit: limit,
    );
  }
}
