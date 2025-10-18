import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

/// Remote data source for goal operations using Firestore
///
/// This class handles all Firestore operations for goals, including
/// CRUD operations, queries, and real-time updates.
class GoalRemoteDataSource {
  final FirebaseFirestore firestore;

  GoalRemoteDataSource({required this.firestore});

  /// Get reference to user's goals collection
  CollectionReference<Map<String, dynamic>> _goalsCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('goals');
  }

  /// Create a new goal in Firestore
  Future<GoalModel> createGoal(GoalModel goal) async {
    try {
      final docRef = await _goalsCollection(goal.userId).add(goal.toFirestore());
      final doc = await docRef.get();
      return GoalModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao criar meta: $e');
    }
  }

  /// Update an existing goal in Firestore
  Future<GoalModel> updateGoal(GoalModel goal) async {
    try {
      await _goalsCollection(goal.userId).doc(goal.id).update(goal.toFirestore());
      final doc = await _goalsCollection(goal.userId).doc(goal.id).get();
      return GoalModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao atualizar meta: $e');
    }
  }

  /// Delete a goal from Firestore
  Future<void> deleteGoal(String goalId, String userId) async {
    try {
      await _goalsCollection(userId).doc(goalId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar meta: $e');
    }
  }

  /// Get a single goal by ID
  Future<GoalModel> getGoalById(String goalId, String userId) async {
    try {
      final doc = await _goalsCollection(userId).doc(goalId).get();

      if (!doc.exists) {
        throw Exception('Meta não encontrada');
      }

      return GoalModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar meta: $e');
    }
  }

  /// Get all goals for a user
  Future<List<GoalModel>> getGoals(String userId) async {
    try {
      final querySnapshot = await _goalsCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => GoalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar metas: $e');
    }
  }

  /// Get active goals for a user
  Future<List<GoalModel>> getActiveGoals(String userId) async {
    try {
      final querySnapshot = await _goalsCollection(userId)
          .where('status', isEqualTo: 'active')
          .orderBy('targetDate')
          .get();

      return querySnapshot.docs
          .map((doc) => GoalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar metas ativas: $e');
    }
  }

  /// Get completed goals for a user
  Future<List<GoalModel>> getCompletedGoals(String userId) async {
    try {
      final querySnapshot = await _goalsCollection(userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => GoalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar metas concluídas: $e');
    }
  }

  /// Watch goals in real-time
  Stream<List<GoalModel>> watchGoals(String userId) {
    try {
      return _goalsCollection(userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => GoalModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw Exception('Erro ao observar metas: $e');
    }
  }

  /// Watch a single goal in real-time
  Stream<GoalModel> watchGoalById(String goalId, String userId) {
    try {
      return _goalsCollection(userId)
          .doc(goalId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw Exception('Meta não encontrada');
        }
        return GoalModel.fromFirestore(snapshot);
      });
    } catch (e) {
      throw Exception('Erro ao observar meta: $e');
    }
  }

  /// Update goal's current amount
  Future<GoalModel> updateGoalAmount(
    String goalId,
    String userId,
    int newAmount,
  ) async {
    try {
      await _goalsCollection(userId).doc(goalId).update({
        'currentAmount': newAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _goalsCollection(userId).doc(goalId).get();
      return GoalModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao atualizar valor da meta: $e');
    }
  }

  /// Add transaction ID to goal's associated transactions
  Future<void> addTransactionToGoal(
    String goalId,
    String userId,
    String transactionId,
  ) async {
    try {
      await _goalsCollection(userId).doc(goalId).update({
        'associatedTransactionIds': FieldValue.arrayUnion([transactionId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar transação à meta: $e');
    }
  }

  /// Remove transaction ID from goal's associated transactions
  Future<void> removeTransactionFromGoal(
    String goalId,
    String userId,
    String transactionId,
  ) async {
    try {
      await _goalsCollection(userId).doc(goalId).update({
        'associatedTransactionIds': FieldValue.arrayRemove([transactionId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao remover transação da meta: $e');
    }
  }

  /// Update goal status
  Future<GoalModel> updateGoalStatus(
    String goalId,
    String userId,
    String status,
  ) async {
    try {
      await _goalsCollection(userId).doc(goalId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _goalsCollection(userId).doc(goalId).get();
      return GoalModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao atualizar status da meta: $e');
    }
  }

  /// Calculate goal's current amount from associated transactions
  /// This queries the transactions collection and sums the amounts
  Future<int> calculateGoalCurrentAmount(String goalId, String userId) async {
    try {
      final transactionsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('goalId', isEqualTo: goalId)
          .get();

      int totalAmount = 0;

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String;
        final amount = data['amount'] as int;

        // Income adds to goal, expense subtracts
        if (type == 'income') {
          totalAmount += amount;
        } else if (type == 'expense') {
          totalAmount -= amount;
        }
      }

      return totalAmount;
    } catch (e) {
      throw Exception('Erro ao calcular valor atual da meta: $e');
    }
  }
}
