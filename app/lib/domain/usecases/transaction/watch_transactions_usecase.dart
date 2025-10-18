import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

/// Use case for watching transactions stream with real-time updates
class WatchTransactionsUseCase {
  final TransactionRepository repository;

  WatchTransactionsUseCase(this.repository);

  /// Execute the use case
  ///
  /// Returns a stream of transactions with real-time updates
  /// Returns Stream<Right(List<TransactionEntity>)> on success
  /// Returns Stream<Left(Failure)> on error
  Stream<Either<Failure, List<TransactionEntity>>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
  }) {
    if (userId.trim().isEmpty) {
      return Stream.value(
        Left(ValidationFailure(message: 'ID do usuário é obrigatório')),
      );
    }

    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Stream.value(
        Left(
          ValidationFailure(
            message: 'A data inicial deve ser anterior à data final',
          ),
        ),
      );
    }

    return repository.watchTransactions(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      goalId: goalId,
    );
  }
}
