import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

/// Implementation of TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await remoteDataSource.createTransaction(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado ao criar transação'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await remoteDataSource.updateTransaction(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao atualizar transação'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      // Note: userId should be passed from the use case layer
      // For now, we'll need to modify this when we implement the use case
      throw UnimplementedError(
        'deleteTransaction requires userId - use deleteTransactionUseCase',
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao deletar transação'),
      );
    }
  }

  /// Delete transaction with userId (internal method)
  Future<Either<Failure, void>> _deleteTransactionWithUserId(
    String userId,
    String transactionId,
  ) async {
    try {
      await remoteDataSource.deleteTransaction(userId, transactionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao deletar transação'),
      );
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(
    String transactionId,
  ) async {
    try {
      // Note: userId should be passed from the use case layer
      throw UnimplementedError(
        'getTransactionById requires userId - use getTransactionByIdUseCase',
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao buscar transação'),
      );
    }
  }

  /// Get transaction by ID with userId (internal method)
  Future<Either<Failure, TransactionEntity>> _getTransactionByIdWithUserId(
    String userId,
    String transactionId,
  ) async {
    try {
      final result = await remoteDataSource.getTransactionById(
        userId,
        transactionId,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao buscar transação'),
      );
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
    int? limit,
  }) async {
    try {
      if (userId == null) {
        return Left(
          ValidationFailure(message: 'ID do usuário é obrigatório'),
        );
      }

      final results = await remoteDataSource.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        type: type,
        goalId: goalId,
        limit: limit,
      );

      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao buscar transações'),
      );
    }
  }

  @override
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactions({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
  }) {
    try {
      if (userId == null) {
        return Stream.value(
          Left(ValidationFailure(message: 'ID do usuário é obrigatório')),
        );
      }

      return remoteDataSource
          .watchTransactions(
            userId: userId,
            startDate: startDate,
            endDate: endDate,
            type: type,
            goalId: goalId,
          )
          .map(
            (models) => Right<Failure, List<TransactionEntity>>(
              models.map((model) => model.toEntity()).toList(),
            ),
          )
          .handleError(
            (error) => Left<Failure, List<TransactionEntity>>(
              ServerFailure(message: 'Erro ao observar transações: $error'),
            ),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure(message: 'Erro inesperado ao observar transações')),
      );
    }
  }

  @override
  Future<Either<Failure, double>> getTotalIncome({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (userId == null) {
        return Left(
          ValidationFailure(message: 'ID do usuário é obrigatório'),
        );
      }

      final total = await remoteDataSource.calculateTotal(
        userId: userId,
        type: TransactionType.income,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(total);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao calcular receita total'),
      );
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpenses({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (userId == null) {
        return Left(
          ValidationFailure(message: 'ID do usuário é obrigatório'),
        );
      }

      final total = await remoteDataSource.calculateTotal(
        userId: userId,
        type: TransactionType.expense,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(total);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao calcular despesas totais'),
      );
    }
  }

  @override
  Future<Either<Failure, double>> getBalance({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (userId == null) {
        return Left(
          ValidationFailure(message: 'ID do usuário é obrigatório'),
        );
      }

      final incomeResult = await getTotalIncome(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final expensesResult = await getTotalExpenses(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return incomeResult.fold(
        (failure) => Left(failure),
        (income) => expensesResult.fold(
          (failure) => Left(failure),
          (expenses) => Right(income - expenses),
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao calcular saldo'),
      );
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByGoal(
    String goalId,
  ) async {
    try {
      // Note: userId should be passed from the use case layer
      throw UnimplementedError(
        'getTransactionsByGoal requires userId - use getTransactionsByGoalUseCase',
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Erro inesperado ao buscar transações por meta'),
      );
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCategory(
    TransactionCategory category, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Note: userId should be passed from the use case layer
      throw UnimplementedError(
        'getTransactionsByCategory requires userId - use getTransactionsByCategoryUseCase',
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erro inesperado ao buscar transações por categoria',
        ),
      );
    }
  }

  /// Get transactions by category with userId (internal method)
  Future<Either<Failure, List<TransactionEntity>>>
      _getTransactionsByCategoryWithUserId({
    required String userId,
    required TransactionCategory category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final results = await remoteDataSource.getTransactionsByCategory(
        userId: userId,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(results.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Erro inesperado ao buscar transações por categoria',
        ),
      );
    }
  }
}
