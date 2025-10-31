import 'package:flutter/material.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../core/constants/goal_colors.dart';
import '../screens/goals/goal_detail_screen.dart';

/// Shared GoalCard widget used across the app
///
/// This widget displays goal information with:
/// - Title and description
/// - Status chip
/// - Days remaining
/// - Transaction count (if any)
/// - Dual-layer progress (days + tasks)
/// - Tasks completed count
class GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final int index;
  final List<TaskEntity> tasks;

  const GoalCard({
    Key? key,
    required this.goal,
    required this.index,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOverdue = goal.isOverdue;

    // Get gradient from goal's color index, use index as fallback
    final gradient = GoalColors.getGradient(goal.colorIndex, fallbackIndex: index);

    // Calculate task progress
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final daysProgress = (goal.daysElapsed / goal.totalDays).clamp(0.0, 1.0);
    final tasksProgress = totalTasks > 0 ? (completedTasks / totalTasks).clamp(0.0, 1.0) : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalDetailScreen(goalId: goal.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(goal.status),
                        ],
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          goal.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Date info and transaction count
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: isOverdue ? Colors.red[200] : Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isOverdue
                                  ? 'Prazo expirado há ${DateTime.now().difference(goal.targetDate).inDays} dias'
                                  : '${goal.daysRemaining} dias restantes',
                              style: TextStyle(
                                fontSize: 13,
                                color: isOverdue ? Colors.red[100] : Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (goal.hasTransactions)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 12,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${goal.transactionCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Progress bar (dual layer: days elapsed + tasks completed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progresso',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                children: [
                                  if (totalTasks > 0) ...[
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$completedTasks/$totalTasks',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Icon(
                                    Icons.event,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(daysProgress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Dual-layer progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 8,
                              child: Stack(
                                children: [
                                  // Background
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  // Days progress (bottom layer)
                                  FractionallySizedBox(
                                    widthFactor: daysProgress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.5),
                                            Colors.white.withOpacity(0.3),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  // Tasks progress (top layer)
                                  if (totalTasks > 0)
                                    FractionallySizedBox(
                                      widthFactor: tasksProgress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(GoalStatus status) {
    Color chipColor;
    String chipLabel;

    switch (status) {
      case GoalStatus.active:
        chipColor = Colors.green;
        chipLabel = 'Ativa';
        break;
      case GoalStatus.completed:
        chipColor = Colors.blue;
        chipLabel = 'Concluída';
        break;
      case GoalStatus.paused:
        chipColor = Colors.orange;
        chipLabel = 'Pausada';
        break;
      case GoalStatus.cancelled:
        chipColor = Colors.red;
        chipLabel = 'Cancelada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        chipLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.95),
        ),
      ),
    );
  }
}
