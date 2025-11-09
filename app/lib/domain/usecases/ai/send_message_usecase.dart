import 'package:dartz/dartz.dart';
import '../../entities/ai_message_entity.dart';
import '../../repositories/ai_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for sending a message to AI
class SendMessageUseCase {
  final AIRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, AIMessageEntity>> call({
    required String userId,
    required String message,
    required AIProvider provider,
    required List<AIMessageEntity> conversationHistory,
    Map<String, dynamic>? context,
  }) async {
    // Validate inputs
    if (userId.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'User ID cannot be empty',
          fieldErrors: {'userId': 'Required field'},
        ),
      );
    }

    if (message.trim().isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Message cannot be empty',
          fieldErrors: {'message': 'Required field'},
        ),
      );
    }

    return await repository.sendMessage(
      userId: userId,
      message: message,
      provider: provider,
      conversationHistory: conversationHistory,
      context: context,
    );
  }
}
