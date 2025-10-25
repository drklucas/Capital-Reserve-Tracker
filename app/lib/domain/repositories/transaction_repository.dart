import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

/// Transaction repository interface defining contract for transaction operations
abstract class TransactionRepository {
  /// Create a new transaction
  /// Returns Right(TransactionEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );

  /// Update an existing transaction
  /// Returns Right(TransactionEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );

  /// Delete a transaction by ID
  /// Returns Right(void) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, void>> deleteTransaction(
    String transactionId,
    String userId,
  );

  /// Get a single transaction by ID
  /// Returns Right(TransactionEntity) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, TransactionEntity>> getTransactionById(
    String transactionId,
  );

  /// Get all transactions for a user
  /// Returns Right(List<TransactionEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
    int? limit,
  });

  /// Get transactions stream for real-time updates
  /// Returns Stream of Right(List<TransactionEntity>) on success
  /// Returns Stream of Left(Failure) on error
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactions({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
  });

  /// Get total income for a period
  /// Returns Right(double) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, double>> getTotalIncome({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get total expenses for a period
  /// Returns Right(double) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, double>> getTotalExpenses({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get balance (income - expenses) for a period
  /// Returns Right(double) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, double>> getBalance({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get transactions by goal ID
  /// Returns Right(List<TransactionEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByGoal(
    String goalId,
  );

  /// Get transactions by category
  /// Returns Right(List<TransactionEntity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCategory(
    TransactionCategory category, {
    DateTime? startDate,
    DateTime? endDate,
  });
}
