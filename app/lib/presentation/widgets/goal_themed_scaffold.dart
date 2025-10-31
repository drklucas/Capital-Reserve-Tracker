import 'package:flutter/material.dart';
import '../../domain/entities/goal_entity.dart';
import '../../core/constants/goal_colors.dart';

/// A scaffold wrapper that applies goal-specific theming
class GoalThemedScaffold extends StatelessWidget {
  final GoalEntity? goal;
  final int fallbackIndex;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  const GoalThemedScaffold({
    Key? key,
    this.goal,
    this.fallbackIndex = 0,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get goal colors for theming
    final gradient = goal != null
        ? GoalColors.getGradient(goal!.colorIndex, fallbackIndex: fallbackIndex)
        : GoalColors.getGradient(-1, fallbackIndex: fallbackIndex);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Stack(
        children: [
          // Gradient Background with goal's color
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradient.colors[0].withOpacity(0.3),
                  gradient.colors[1].withOpacity(0.2),
                  const Color(0xFF0f3460),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Content
          body,
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  /// Get the primary color for this goal
  static Color getPrimaryColor(GoalEntity? goal, {int fallbackIndex = 0}) {
    return goal != null
        ? GoalColors.getPrimaryColor(goal.colorIndex, fallbackIndex: fallbackIndex)
        : GoalColors.getPrimaryColor(-1, fallbackIndex: fallbackIndex);
  }

  /// Get the gradient for this goal
  static LinearGradient getGradient(GoalEntity? goal, {int fallbackIndex = 0}) {
    return goal != null
        ? GoalColors.getGradient(goal.colorIndex, fallbackIndex: fallbackIndex)
        : GoalColors.getGradient(-1, fallbackIndex: fallbackIndex);
  }
}
