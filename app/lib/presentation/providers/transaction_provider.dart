import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/transaction/create_transaction_usecase.dart';
import '../../domain/usecases/transaction/delete_transaction_usecase.dart';
import '../../domain/usecases/transaction/get_transactions_usecase.dart';
import '../../domain/usecases/transaction/update_transaction_usecase.dart';
import '../../domain/usecases/transaction/watch_transactions_usecase.dart';

/// Transaction provider state
enum TransactionStatus {
  initial,
  loading,
  loaded,
  error,
  creating,
  updating,
  deleting,
}

/// Provider for managing transaction state
class TransactionProvider extends ChangeNotifier {
  final CreateTransactionUseCase createTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final WatchTransactionsUseCase watchTransactionsUseCase;

  TransactionProvider({
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.watchTransactionsUseCase,
  });

  TransactionStatus _status = TransactionStatus.initial;
  List<TransactionEntity> _transactions = [];
  String? _errorMessage;
  StreamSubscription<dynamic>? _transactionsSubscription;

  // Getters
  TransactionStatus get status => _status;
  List<TransactionEntity> get transactions => _transactions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TransactionStatus.loading;
  bool get hasError => _status == TransactionStatus.error;

  // Filtered lists
  List<TransactionEntity> get incomeTransactions =>
      _transactions.where((t) => t.isIncome).toList();

  List<TransactionEntity> get expenseTransactions =>
      _transactions.where((t) => t.isExpense).toList();

  // Calculate totals
  double get totalIncome => incomeTransactions.fold<double>(
        0.0,
        (sum, transaction) => sum + transaction.amount,
      );

  double get totalExpenses => expenseTransactions.fold<double>(
        0.0,
        (sum, transaction) => sum + transaction.amount,
      );

  double get balance => totalIncome - totalExpenses;

  /// Create a new transaction
  Future<bool> createTransaction({
    required String userId,
    required TransactionType type,
    required double amount,
    required String description,
    required DateTime date,
    required TransactionCategory category,
    String? goalId,
  }) async {
    _status = TransactionStatus.creating;
    _errorMessage = null;
    notifyListeners();

    final result = await createTransactionUseCase(
      userId: userId,
      type: type,
      amount: amount,
      description: description,
      date: date,
      category: category,
      goalId: goalId,
    );

    return result.fold(
      (failure) {
        _status = TransactionStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (transaction) {
        _status = TransactionStatus.loaded;
        // Transaction will be added via stream if watching
        notifyListeners();
        return true;
      },
    );
  }

  /// Update an existing transaction
  Future<bool> updateTransaction({
    required TransactionEntity transaction,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    TransactionCategory? category,
    String? goalId,
  }) async {
    _status = TransactionStatus.updating;
    _errorMessage = null;
    notifyListeners();

    final result = await updateTransactionUseCase(
      transaction: transaction,
      type: type,
      amount: amount,
      description: description,
      date: date,
      category: category,
      goalId: goalId,
    );

    return result.fold(
      (failure) {
        _status = TransactionStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedTransaction) {
        _status = TransactionStatus.loaded;
        // Update local list
        final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
        if (index != -1) {
          _transactions[index] = updatedTransaction;
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(String transactionId) async {
    _status = TransactionStatus.deleting;
    _errorMessage = null;
    notifyListeners();

    final result = await deleteTransactionUseCase(
      transactionId: transactionId,
    );

    return result.fold(
      (failure) {
        _status = TransactionStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _status = TransactionStatus.loaded;
        // Remove from local list
        _transactions.removeWhere((t) => t.id == transactionId);
        notifyListeners();
        return true;
      },
    );
  }

  /// Get transactions (one-time fetch)
  Future<void> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
    int? limit,
  }) async {
    _status = TransactionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getTransactionsUseCase(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      goalId: goalId,
      limit: limit,
    );

    result.fold(
      (failure) {
        _status = TransactionStatus.error;
        _errorMessage = failure.message;
        _transactions = [];
      },
      (transactions) {
        _status = TransactionStatus.loaded;
        _transactions = transactions;
      },
    );

    notifyListeners();
  }

  /// Watch transactions stream (real-time updates)
  void watchTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
  }) {
    // Cancel previous subscription
    _transactionsSubscription?.cancel();

    _status = TransactionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final stream = watchTransactionsUseCase(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      goalId: goalId,
    );

    _transactionsSubscription = stream.listen(
      (result) {
        result.fold(
          (failure) {
            _status = TransactionStatus.error;
            _errorMessage = failure.message;
            _transactions = [];
          },
          (transactions) {
            _status = TransactionStatus.loaded;
            _transactions = transactions;
          },
        );
        notifyListeners();
      },
      onError: (error) {
        _status = TransactionStatus.error;
        _errorMessage = 'Erro ao observar transações: $error';
        _transactions = [];
        notifyListeners();
      },
    );
  }

  /// Stop watching transactions
  void stopWatching() {
    _transactionsSubscription?.cancel();
    _transactionsSubscription = null;
  }

  /// Filter transactions by date range
  List<TransactionEntity> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get transactions by category
  List<TransactionEntity> getTransactionsByCategory(
    TransactionCategory category,
  ) {
    return _transactions.where((t) => t.category == category).toList();
  }

  /// Get transactions by goal
  List<TransactionEntity> getTransactionsByGoal(String goalId) {
    return _transactions.where((t) => t.goalId == goalId).toList();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_status == TransactionStatus.error) {
      _status = TransactionStatus.loaded;
    }
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    stopWatching();
    _status = TransactionStatus.initial;
    _transactions = [];
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopWatching();
    super.dispose();
  }
}
