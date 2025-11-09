import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onNewTransaction;
  final VoidCallback? onNewGoal;
  final VoidCallback? onSearch;

  const AppShortcuts({
    super.key,
    required this.child,
    this.onNewTransaction,
    this.onNewGoal,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        // Ctrl/Cmd + N: Nova transação
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            const NewTransactionIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN):
            const NewTransactionIntent(),

        // Ctrl/Cmd + G: Nova meta
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyG):
            const NewGoalIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyG):
            const NewGoalIntent(),

        // Ctrl/Cmd + K: Search
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            const SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            const SearchIntent(),
      },
      child: Actions(
        actions: {
          NewTransactionIntent: CallbackAction<NewTransactionIntent>(
            onInvoke: (_) {
              onNewTransaction?.call();
              return null;
            },
          ),
          NewGoalIntent: CallbackAction<NewGoalIntent>(
            onInvoke: (_) {
              onNewGoal?.call();
              return null;
            },
          ),
          SearchIntent: CallbackAction<SearchIntent>(
            onInvoke: (_) {
              onSearch?.call();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

// Intents
class NewTransactionIntent extends Intent {
  const NewTransactionIntent();
}

class NewGoalIntent extends Intent {
  const NewGoalIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}
