# AI Assistant Setup Guide

This guide covers the complete setup and integration of the AI Assistant feature in Capital Reserve Tracker.

## Overview

The AI Assistant provides intelligent financial insights, spending analysis, and personalized recommendations using Google Gemini or Anthropic Claude APIs.

## Features

- 💬 **Intelligent Chat**: Converse with AI about your finances
- 📊 **Automatic Insights**: Personalized spending and savings analysis
- 🎯 **Goal Recommendations**: Specific help to achieve your financial objectives
- 🔒 **Secure**: API keys encrypted with Flutter Secure Storage
- 🏗️ **Clean Architecture**: Organized and testable code

## Quick Start

### 1. Install Dependencies

```bash
cd app
flutter pub get
```

### 2. Get API Key

**Option A: Google Gemini (Recommended - Free)**
1. Visit [https://ai.google.dev](https://ai.google.dev)
2. Sign in and create an API key
3. Copy the key

**Option B: Anthropic Claude (Paid)**
1. Visit [https://console.anthropic.com](https://console.anthropic.com)
2. Create account and add payment method
3. Generate an API key

### 3. Configure in App

1. Open the app
2. Navigate to **AI Assistant** → **Settings**
3. Paste your API key
4. Click **Save**

### 4. Use the Assistant

- **Chat**: Ask anything about your finances
- **Insights**: Generate automatic analysis
- **Spending Analysis**: See where you're spending most
- **Recommendations**: Get tips for your goals

## Architecture

### File Structure

```
app/lib/
├── domain/entities/
│   ├── ai_message_entity.dart          # Chat messages
│   ├── ai_conversation_entity.dart     # Conversations
│   └── ai_insight_entity.dart          # Generated insights
├── domain/repositories/
│   └── ai_repository.dart              # Repository interface
├── domain/usecases/ai/
│   ├── send_message_usecase.dart
│   ├── generate_insights_usecase.dart
│   ├── analyze_spending_usecase.dart
│   ├── get_goal_recommendations_usecase.dart
│   └── manage_api_key_usecase.dart
├── data/models/
│   ├── ai_message_model.dart
│   └── ai_insight_model.dart
├── data/datasources/
│   ├── ai_remote_datasource.dart       # Gemini/Claude APIs
│   └── ai_firestore_datasource.dart    # Firestore
├── data/repositories/
│   └── ai_repository_impl.dart
├── core/services/
│   └── secure_storage_service.dart     # Secure API keys
├── presentation/providers/
│   └── ai_assistant_provider.dart      # State management
└── presentation/screens/ai/
    ├── ai_assistant_screen.dart        # Chat screen
    ├── ai_insights_screen.dart         # Insights screen
    └── ai_settings_screen.dart         # Settings screen
```

## Setup in main.dart

### Add Imports

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// AI imports
import 'domain/usecases/ai/send_message_usecase.dart';
import 'domain/usecases/ai/generate_insights_usecase.dart';
import 'domain/usecases/ai/manage_api_key_usecase.dart';
import 'domain/usecases/ai/analyze_spending_usecase.dart';
import 'domain/usecases/ai/get_goal_recommendations_usecase.dart';
import 'data/datasources/ai_firestore_datasource.dart';
import 'data/repositories/ai_repository_impl.dart';
import 'core/services/secure_storage_service.dart';
import 'presentation/providers/ai_assistant_provider.dart';
```

### Initialize Services

```dart
// Inside main(), after creating firestore:

// Dio
final dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ),
);

// Secure Storage
const secureStorage = FlutterSecureStorage();
final secureStorageService = SecureStorageService(secureStorage);

// AI Firestore
final aiFirestoreDataSource = AIFirestoreDataSource(firestore);

// AI Repository
final aiRepository = AIRepositoryImpl(
  secureStorage: secureStorageService,
  firestoreDataSource: aiFirestoreDataSource,
  transactionRepository: transactionRepository,
  goalRepository: goalRepository,
  dio: dio,
);

// AI Use Cases
final sendMessageUseCase = SendMessageUseCase(aiRepository);
final generateInsightsUseCase = GenerateInsightsUseCase(aiRepository);
final manageApiKeyUseCase = ManageApiKeyUseCase(aiRepository);
final analyzeSpendingUseCase = AnalyzeSpendingUseCase(aiRepository);
final getGoalRecommendationsUseCase = GetGoalRecommendationsUseCase(aiRepository);
```

### Add Provider

```dart
// Inside MultiProvider, add:

ChangeNotifierProvider(
  create: (_) => AIAssistantProvider(
    sendMessageUseCase: sendMessageUseCase,
    generateInsightsUseCase: generateInsightsUseCase,
    manageApiKeyUseCase: manageApiKeyUseCase,
    analyzeSpendingUseCase: analyzeSpendingUseCase,
    getGoalRecommendationsUseCase: getGoalRecommendationsUseCase,
    aiRepository: aiRepository,
  ),
),
```

## Home Screen Integration

### Add Navigation Card

```dart
// In HomeScreen's quick actions grid:

_buildQuickActionCard(
  context,
  title: 'AI Assistant',
  subtitle: 'Financial insights',
  icon: Icons.psychology,
  gradient: const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
  ),
  onTap: () => Navigator.pushNamed(context, '/ai-assistant'),
),
```

### Add Route

```dart
// In main.dart MaterialApp routes:

'/ai-assistant': (context) => const AIAssistantScreen(),
'/ai-insights': (context) => const AIInsightsScreen(),
'/ai-settings': (context) => const AISettingsScreen(),
```

## Usage Examples

### Sending a Message

```dart
final provider = Provider.of<AIAssistantProvider>(context, listen: false);
await provider.sendMessage('How can I save more money?');
```

### Generating Insights

```dart
await provider.generateInsights(userId);
```

### Analyzing Spending

```dart
final analysis = await provider.analyzeSpending(
  userId,
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);
```

### Getting Goal Recommendations

```dart
final recommendations = await provider.getGoalRecommendations(
  userId,
  goalId,
);
```

## Security Considerations

1. **API Keys**: Stored encrypted in Flutter Secure Storage
2. **User Data**: All user data stays in Firestore
3. **API Calls**: Only necessary data sent to AI APIs
4. **No Storage**: Chat history not stored on AI provider servers

## Troubleshooting

### API Key Not Working

1. Check if key is valid in provider console
2. Verify API key format (should start with specific prefix)
3. Check API quotas and limits

### Connection Errors

1. Verify internet connection
2. Check Dio timeout settings
3. Ensure API endpoint is accessible

### No Insights Generated

1. Verify user has transactions in database
2. Check Firebase security rules
3. Review error messages in console

## Dependencies

```yaml
dependencies:
  dio: ^5.3.3              # HTTP client
  flutter_secure_storage: ^9.0.0  # Secure storage
  # Other existing dependencies...
```

## API Providers

### Google Gemini

- **Free Tier**: 60 requests/minute
- **Model**: gemini-pro
- **Best For**: General use, cost-effective
- **Docs**: [https://ai.google.dev/docs](https://ai.google.dev/docs)

### Anthropic Claude

- **Pricing**: Pay per token
- **Model**: claude-3-sonnet
- **Best For**: Advanced analysis, longer context
- **Docs**: [https://docs.anthropic.com](https://docs.anthropic.com)

## Future Enhancements

- [ ] Multi-language support
- [ ] Voice input/output
- [ ] Budget forecasting
- [ ] Investment recommendations
- [ ] Expense categorization suggestions

## Related Documentation

- [Architecture Overview](../architecture.md)
- [Security Guidelines](../security.md)
- [Main Setup Guide](main-setup.md)

---

**Last Updated:** 2025-11-09
