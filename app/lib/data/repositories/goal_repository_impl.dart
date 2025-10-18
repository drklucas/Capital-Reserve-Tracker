import 'package:dartz/dartz.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/goal_remote_datasource.dart';
import '../models/goal_model.dart';

/// Implementation of GoalRepository using Firebase Firestore
///
/// This class implements all goal repository methods and handles
/// error conversion from exceptions to Failure objects.
class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource remoteDataSource;

  GoalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, GoalEntity>> createGoal(GoalEntity goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      final createdModel = await remoteDataSource.createGoal(model);
      return Right(createdModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GoalEntity>> updateGoal(GoalEntity goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      final updatedModel = await remoteDataSource.updateGoal(model);
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String goalId, String userId) async {
    try {
      await remoteDataSource.deleteGoal(goalId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GoalEntity>> getGoalById(
    String goalId,
    String userId,
  ) async {
    try {
      final model = await remoteDataSource.getGoalById(goalId, userId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GoalEntity>>> getGoals(String userId) async {
    try {
      final models = await remoteDataSource.getGoals(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GoalEntity>>> getActiveGoals(
    String userId,
  ) async {
    try {
      final models = await remoteDataSource.getActiveGoals(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GoalEntity>>> getCompletedGoals(
    String userId,
  ) async {
    try {
      final models = await remoteDataSource.getCompletedGoals(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<GoalEntity>>> watchGoals(String userId) {
    try {
      return remoteDataSource.watchGoals(userId).map(
            (models) => Right<Failure, List<GoalEntity>>(
              models.map((model) => model.toEntity()).toList(),
            ),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Stream<Either<Failure, GoalEntity>> watchGoalById(
    String goalId,
    String userId,
  ) {
    try {
      return remoteDataSource.watchGoalById(goalId, userId).map(
            (model) => Right<Failure, GoalEntity>(model.toEntity()),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, GoalEntity>> updateGoalAmount(
    String goalId,
    String userId,
    int newAmount,
  ) async {
    try {
      final model = await remoteDataSource.updateGoalAmount(
        goalId,
        userId,
        newAmount,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransactionToGoal(
    String goalId,
    String userId,
    String transactionId,
  ) async {
    try {
      await remoteDataSource.addTransactionToGoal(
        goalId,
        userId,
        transactionId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeTransactionFromGoal(
    String goalId,
    String userId,
    String transactionId,
  ) async {
    try {
      await remoteDataSource.removeTransactionFromGoal(
        goalId,
        userId,
        transactionId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> calculateGoalCurrentAmount(
    String goalId,
    String userId,
  ) async {
    try {
      final amount = await remoteDataSource.calculateGoalCurrentAmount(
        goalId,
        userId,
      );
      return Right(amount);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GoalEntity>> updateGoalStatus(
    String goalId,
    String userId,
    GoalStatus status,
  ) async {
    try {
      final model = await remoteDataSource.updateGoalStatus(
        goalId,
        userId,
        status.name,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
