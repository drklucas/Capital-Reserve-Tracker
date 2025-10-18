import 'package:dartz/dartz.dart';
import '../entities/goal_entity.dart';
import '../../core/errors/failures.dart';

/// Goal repository interface defining the contract for goal data operations
///
/// This interface follows the Repository pattern and defines all operations
/// related to goal management. Implementations should handle data persistence
/// (e.g., Firestore) and return Either<Failure, Success> for error handling.
abstract class GoalRepository {
  /// Create a new goal
  ///
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> createGoal(GoalEntity goal);

  /// Update an existing goal
  ///
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> updateGoal(GoalEntity goal);

  /// Delete a goal by ID
  ///
  /// Returns [Right(void)] on success or [Left(Failure)] on error
  Future<Either<Failure, void>> deleteGoal(String goalId, String userId);

  /// Get a single goal by ID
  ///
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> getGoalById(
    String goalId,
    String userId,
  );

  /// Get all goals for a user
  ///
  /// Returns [Right(List<GoalEntity>)] on success or [Left(Failure)] on error
  Future<Either<Failure, List<GoalEntity>>> getGoals(String userId);

  /// Get active goals for a user
  ///
  /// Returns [Right(List<GoalEntity>)] on success or [Left(Failure)] on error
  Future<Either<Failure, List<GoalEntity>>> getActiveGoals(String userId);

  /// Get completed goals for a user
  ///
  /// Returns [Right(List<GoalEntity>)] on success or [Left(Failure)] on error
  Future<Either<Failure, List<GoalEntity>>> getCompletedGoals(String userId);

  /// Watch goals in real-time (stream)
  ///
  /// Returns a stream that emits [Right(List<GoalEntity>)] on success
  /// or [Left(Failure)] on error
  Stream<Either<Failure, List<GoalEntity>>> watchGoals(String userId);

  /// Watch a single goal in real-time (stream)
  ///
  /// Returns a stream that emits [Right(GoalEntity)] on success
  /// or [Left(Failure)] on error
  Stream<Either<Failure, GoalEntity>> watchGoalById(
    String goalId,
    String userId,
  );

  /// Update goal's current amount (recalculated from transactions)
  ///
  /// This should be called when transactions are added/updated/deleted
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> updateGoalAmount(
    String goalId,
    String userId,
    int newAmount,
  );

  /// Add transaction ID to goal's associated transactions
  ///
  /// Returns [Right(void)] on success or [Left(Failure)] on error
  Future<Either<Failure, void>> addTransactionToGoal(
    String goalId,
    String userId,
    String transactionId,
  );

  /// Remove transaction ID from goal's associated transactions
  ///
  /// Returns [Right(void)] on success or [Left(Failure)] on error
  Future<Either<Failure, void>> removeTransactionFromGoal(
    String goalId,
    String userId,
    String transactionId,
  );

  /// Calculate and update current amount based on associated transactions
  ///
  /// This aggregates all transaction amounts linked to this goal
  /// Returns [Right(int)] (new current amount) on success or [Left(Failure)] on error
  Future<Either<Failure, int>> calculateGoalCurrentAmount(
    String goalId,
    String userId,
  );

  /// Update goal status (e.g., complete, pause, cancel)
  ///
  /// Returns [Right(GoalEntity)] on success or [Left(Failure)] on error
  Future<Either<Failure, GoalEntity>> updateGoalStatus(
    String goalId,
    String userId,
    GoalStatus status,
  );
}
