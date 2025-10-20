import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

/// Remote data source for task operations with Firestore
class TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSource({required this.firestore});

  /// Get tasks collection reference for a user
  CollectionReference _getTasksCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('tasks');
  }

  /// Create a new task in Firestore
  Future<TaskModel> createTask(TaskModel task) async {
    final docRef = await _getTasksCollection(task.userId).add(
      task.toFirestore(),
    );

    final doc = await docRef.get();
    return TaskModel.fromFirestore(doc);
  }

  /// Update an existing task in Firestore
  Future<TaskModel> updateTask(TaskModel task) async {
    await _getTasksCollection(task.userId).doc(task.id).update(
          task.toFirestore(),
        );

    final doc = await _getTasksCollection(task.userId).doc(task.id).get();
    return TaskModel.fromFirestore(doc);
  }

  /// Delete a task from Firestore
  Future<void> deleteTask(String taskId, String userId) async {
    await _getTasksCollection(userId).doc(taskId).delete();
  }

  /// Get a task by ID
  Future<TaskModel> getTaskById(String taskId, String userId) async {
    final doc = await _getTasksCollection(userId).doc(taskId).get();

    if (!doc.exists) {
      throw Exception('Task not found');
    }

    return TaskModel.fromFirestore(doc);
  }

  /// Get all tasks for a specific goal
  Future<List<TaskModel>> getTasksByGoal(String goalId, String userId) async {
    final querySnapshot = await _getTasksCollection(userId)
        .where('goalId', isEqualTo: goalId)
        .orderBy('createdAt', descending: false)
        .get();

    // Sort by order field in memory if available
    final tasks = querySnapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();

    tasks.sort((a, b) => a.order.compareTo(b.order));
    return tasks;
  }

  /// Get all tasks for a user
  Future<List<TaskModel>> getTasks(String userId) async {
    final querySnapshot = await _getTasksCollection(userId)
        .orderBy('createdAt', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();
  }

  /// Watch tasks for a specific goal (real-time)
  Stream<List<TaskModel>> watchTasksByGoal(String goalId, String userId) {
    return _getTasksCollection(userId)
        .where('goalId', isEqualTo: goalId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc))
              .toList();

          // Sort by order field in memory
          tasks.sort((a, b) => a.order.compareTo(b.order));
          return tasks;
        });
  }

  /// Watch all tasks for a user (real-time)
  Stream<List<TaskModel>> watchTasks(String userId) {
    return _getTasksCollection(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Toggle task completion status
  Future<TaskModel> toggleTaskCompletion(String taskId, String userId) async {
    final doc = await _getTasksCollection(userId).doc(taskId).get();

    if (!doc.exists) {
      throw Exception('Task not found');
    }

    final task = TaskModel.fromFirestore(doc);
    final newCompletionStatus = !task.isCompleted;

    await _getTasksCollection(userId).doc(taskId).update({
      'isCompleted': newCompletionStatus,
      'completedAt': newCompletionStatus ? Timestamp.now() : null,
      'updatedAt': Timestamp.now(),
    });

    final updatedDoc = await _getTasksCollection(userId).doc(taskId).get();
    return TaskModel.fromFirestore(updatedDoc);
  }

  /// Get completed tasks for a goal
  Future<List<TaskModel>> getCompletedTasksByGoal(
    String goalId,
    String userId,
  ) async {
    final querySnapshot = await _getTasksCollection(userId)
        .where('goalId', isEqualTo: goalId)
        .where('isCompleted', isEqualTo: true)
        .orderBy('completedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();
  }

  /// Get pending tasks for a goal
  Future<List<TaskModel>> getPendingTasksByGoal(
    String goalId,
    String userId,
  ) async {
    final querySnapshot = await _getTasksCollection(userId)
        .where('goalId', isEqualTo: goalId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();
  }

  /// Batch update task orders
  /// Used when reordering tasks to update multiple tasks at once
  Future<void> batchUpdateTaskOrders(
    String userId,
    Map<String, int> taskOrderUpdates,
  ) async {
    final batch = firestore.batch();

    taskOrderUpdates.forEach((taskId, newOrder) {
      final taskRef = _getTasksCollection(userId).doc(taskId);
      batch.update(taskRef, {
        'order': newOrder,
        'updatedAt': Timestamp.now(),
      });
    });

    await batch.commit();
  }

  /// Get tasks for multiple goals
  Future<List<TaskModel>> getTasksByGoalIds(
    List<String> goalIds,
    String userId,
  ) async {
    if (goalIds.isEmpty) {
      return [];
    }

    // Firestore 'in' query supports up to 10 items
    // If more than 10 goals, split into multiple queries
    final List<TaskModel> allTasks = [];

    for (int i = 0; i < goalIds.length; i += 10) {
      final batchGoalIds = goalIds.skip(i).take(10).toList();

      final querySnapshot = await _getTasksCollection(userId)
          .where('goalId', whereIn: batchGoalIds)
          .orderBy('createdAt', descending: false)
          .get();

      final tasks = querySnapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      allTasks.addAll(tasks);
    }

    return allTasks;
  }
}
