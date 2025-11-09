import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_message_model.dart';
import '../models/ai_insight_model.dart';
import '../../core/errors/exceptions.dart';

/// Firestore data source for AI conversations and insights
class AIFirestoreDataSource {
  final FirebaseFirestore _firestore;

  // Collection names
  static const String _conversationsCollection = 'ai_conversations';
  static const String _insightsCollection = 'ai_insights';

  AIFirestoreDataSource(this._firestore);

  /// Save message to conversation
  Future<void> saveMessage({
    required String userId,
    required String conversationId,
    required AIMessageModel message,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection('messages')
          .doc(message.id)
          .set(message.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to save message: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Get conversation messages
  Future<List<AIMessageModel>> getMessages({
    required String userId,
    required String conversationId,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AIMessageModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get messages: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Create conversation metadata
  Future<void> createConversation({
    required String userId,
    required String conversationId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_conversationsCollection)
          .doc(conversationId)
          .set(metadata);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to create conversation: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Get conversations for user
  Future<List<Map<String, dynamic>>> getConversations({
    required String userId,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection(_conversationsCollection)
          .orderBy('updatedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get conversations: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Update conversation metadata
  Future<void> updateConversation({
    required String userId,
    required String conversationId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update(updates);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update conversation: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Delete conversation
  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  }) async {
    try {
      // Delete all messages in the conversation
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete conversation metadata
      batch.delete(
        _firestore
            .collection('users')
            .doc(userId)
            .collection(_conversationsCollection)
            .doc(conversationId),
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to delete conversation: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Save insight
  Future<void> saveInsight({
    required String userId,
    required AIInsightModel insight,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_insightsCollection)
          .doc(insight.id)
          .set(insight.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to save insight: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Get insights for user
  Future<List<AIInsightModel>> getInsights({
    required String userId,
    int? limit,
    bool? includeRead,
    bool? includeDismissed,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection(_insightsCollection)
          .orderBy('generatedAt', descending: true);

      // Filter by read status
      if (includeRead != null && !includeRead) {
        query = query.where('isRead', isEqualTo: false);
      }

      // Filter by dismissed status
      if (includeDismissed != null && !includeDismissed) {
        query = query.where('isDismissed', isEqualTo: false);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AIInsightModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get insights: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Mark insight as read
  Future<void> markInsightAsRead({
    required String userId,
    required String insightId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_insightsCollection)
          .doc(insightId)
          .update({'isRead': true});
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to mark insight as read: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Dismiss insight
  Future<void> dismissInsight({
    required String userId,
    required String insightId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_insightsCollection)
          .doc(insightId)
          .update({'isDismissed': true});
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to dismiss insight: ${e.message}',
        code: e.code,
      );
    }
  }
}
