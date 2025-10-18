import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

/// Use case for updating an existing transaction
class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  /// Execute the use case
  ///
  /// Updates an existing transaction
  /// Returns Right(TransactionEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TransactionEntity>> call({
    required TransactionEntity transaction,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    TransactionCategory? category,
    String? goalId,
  }) async {
    // Validate amount if provided
    if (amount != null && amount <= 0) {
      return Left(
        ValidationFailure(message: 'O valor deve ser maior que zero'),
      );
    }

    // Validate description if provided
    if (description != null && description.trim().isEmpty) {
      return Left(
        ValidationFailure(message: 'A descrição não pode estar vazia'),
      );
    }

    // Create updated transaction
    final updatedTransaction = transaction.copyWith(
      type: type,
      amount: amount,
      description: description?.trim(),
      date: date,
      category: category,
      goalId: goalId,
      updatedAt: DateTime.now(),
    );

    return await repository.updateTransaction(updatedTransaction);
  }
}
