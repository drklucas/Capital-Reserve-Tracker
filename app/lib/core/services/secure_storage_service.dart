import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/ai_message_entity.dart';

/// Service for secure storage of sensitive data (API keys, tokens, etc.)
class SecureStorageService {
  final FlutterSecureStorage _storage;

  // Keys for storage
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _claudeApiKeyKey = 'claude_api_key';

  SecureStorageService(this._storage);

  /// Get API key for a provider
  Future<String?> getApiKey(AIProvider provider) async {
    final key = _getStorageKey(provider);
    return await _storage.read(key: key);
  }

  /// Set API key for a provider
  Future<void> setApiKey(AIProvider provider, String apiKey) async {
    final key = _getStorageKey(provider);
    await _storage.write(key: key, value: apiKey);
  }

  /// Remove API key for a provider
  Future<void> removeApiKey(AIProvider provider) async {
    final key = _getStorageKey(provider);
    await _storage.delete(key: key);
  }

  /// Check if API key exists for a provider
  Future<bool> hasApiKey(AIProvider provider) async {
    final apiKey = await getApiKey(provider);
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Clear all API keys
  Future<void> clearAllApiKeys() async {
    await _storage.deleteAll();
  }

  /// Get storage key for a provider
  String _getStorageKey(AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return _geminiApiKeyKey;
      case AIProvider.claude:
        return _claudeApiKeyKey;
    }
  }
}
