import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

/// Remote datasource for transaction operations with Firestore
class TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;

  TransactionRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get transactions collection reference for a user
  CollectionReference _getTransactionsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  /// Create a new transaction
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final docRef = _getTransactionsCollection(transaction.userId).doc();

      final transactionWithId = TransactionModel.fromEntity(
        transaction.copyWith(id: docRef.id),
      );

      await docRef.set(transactionWithId.toFirestore());

      return transactionWithId;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to create transaction: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error creating transaction: $e',
      );
    }
  }

  /// Update an existing transaction
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final updatedTransaction = TransactionModel.fromEntity(
        transaction.copyWith(updatedAt: DateTime.now()),
      );

      await _getTransactionsCollection(transaction.userId)
          .doc(transaction.id)
          .update(updatedTransaction.toFirestore());

      return updatedTransaction;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update transaction: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error updating transaction: $e',
      );
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await _getTransactionsCollection(userId).doc(transactionId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to delete transaction: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error deleting transaction: $e',
      );
    }
  }

  /// Get a single transaction by ID
  Future<TransactionModel> getTransactionById(
    String userId,
    String transactionId,
  ) async {
    try {
      final doc = await _getTransactionsCollection(userId)
          .doc(transactionId)
          .get();

      if (!doc.exists) {
        throw ServerException(
          message: 'Transaction not found',
          code: 'not-found',
        );
      }

      return TransactionModel.fromFirestore(doc);
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get transaction: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error getting transaction: $e',
      );
    }
  }

  /// Get all transactions for a user with optional filters
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
    int? limit,
  }) async {
    try {
      Query query = _getTransactionsCollection(userId);

      // Apply filters
      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (goalId != null) {
        query = query.where('goalId', isEqualTo: goalId);
      }

      // Order by date descending
      query = query.orderBy('date', descending: true);

      // Apply limit if specified
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get transactions: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error getting transactions: $e',
      );
    }
  }

  /// Watch transactions stream for real-time updates
  Stream<List<TransactionModel>> watchTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? goalId,
  }) {
    try {
      Query query = _getTransactionsCollection(userId);

      // Apply filters
      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (goalId != null) {
        query = query.where('goalId', isEqualTo: goalId);
      }

      // Order by date descending
      query = query.orderBy('date', descending: true);

      return query.snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => TransactionModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error watching transactions: $e',
      );
    }
  }

  /// Get transactions by category
  Future<List<TransactionModel>> getTransactionsByCategory({
    required String userId,
    required TransactionCategory category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _getTransactionsCollection(userId)
          .where('category', isEqualTo: category.name);

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      query = query.orderBy('date', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get transactions by category: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error getting transactions by category: $e',
      );
    }
  }

  /// Calculate total for transactions (income or expenses)
  Future<double> calculateTotal({
    required String userId,
    required TransactionType type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await getTransactions(
        userId: userId,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      return transactions.fold<double>(
        0.0,
        (sum, transaction) => sum + transaction.amount,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error calculating total: $e',
      );
    }
  }
}
