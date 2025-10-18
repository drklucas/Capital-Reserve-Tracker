import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/transaction_repository.dart';

/// Use case for deleting a transaction
class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  /// Execute the use case
  ///
  /// Deletes a transaction by ID
  /// Returns Right(void) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, void>> call({
    required String transactionId,
  }) async {
    if (transactionId.trim().isEmpty) {
      return Left(
        ValidationFailure(message: 'ID da transação é obrigatório'),
      );
    }

    return await repository.deleteTransaction(transactionId);
  }
}
