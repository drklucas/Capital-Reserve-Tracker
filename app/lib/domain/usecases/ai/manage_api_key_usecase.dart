import 'package:dartz/dartz.dart';
import '../../entities/ai_message_entity.dart';
import '../../repositories/ai_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for managing AI provider API keys
class ManageApiKeyUseCase {
  final AIRepository repository;

  ManageApiKeyUseCase(this.repository);

  /// Check if API key is configured
  Future<Either<Failure, bool>> isConfigured({
    required AIProvider provider,
  }) async {
    return await repository.isApiKeyConfigured(provider: provider);
  }

  /// Set API key
  Future<Either<Failure, void>> setApiKey({
    required AIProvider provider,
    required String apiKey,
  }) async {
    // Validate API key
    if (apiKey.trim().isEmpty) {
      return Left(
        ValidationFailure(
          message: 'API key cannot be empty',
          fieldErrors: {'apiKey': 'Required field'},
        ),
      );
    }

    // Basic validation for API key format
    if (apiKey.length < 10) {
      return Left(
        ValidationFailure(
          message: 'Invalid API key format',
          fieldErrors: {'apiKey': 'API key too short'},
        ),
      );
    }

    return await repository.setApiKey(
      provider: provider,
      apiKey: apiKey,
    );
  }

  /// Remove API key
  Future<Either<Failure, void>> removeApiKey({
    required AIProvider provider,
  }) async {
    return await repository.removeApiKey(provider: provider);
  }

  /// Test connection
  Future<Either<Failure, bool>> testConnection({
    required AIProvider provider,
  }) async {
    return await repository.testConnection(provider: provider);
  }
}
