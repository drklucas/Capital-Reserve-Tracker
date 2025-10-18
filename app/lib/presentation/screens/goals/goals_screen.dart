import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/goal_entity.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

/// Goals screen displaying list of user's financial goals
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AppAuthProvider>();
      final goalProvider = context.read<GoalProvider>();

      if (authProvider.user != null) {
        goalProvider.watchGoals(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Metas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddGoal(context),
            tooltip: 'Adicionar Meta',
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (goalProvider.status == GoalProviderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (goalProvider.status == GoalProviderStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    goalProvider.errorMessage ?? 'Erro ao carregar metas',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final authProvider = context.read<AppAuthProvider>();
                      if (authProvider.user != null) {
                        goalProvider.loadGoals(authProvider.user!.id);
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (goalProvider.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'Nenhuma meta cadastrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie sua primeira meta financeira!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddGoal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Meta'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = context.read<AppAuthProvider>();
              if (authProvider.user != null) {
                await goalProvider.loadGoals(authProvider.user!.id);
              }
            },
            child: Column(
              children: [
                // Summary Card
                _buildSummaryCard(goalProvider),

                // Goals List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: goalProvider.goals.length,
                    itemBuilder: (context, index) {
                      final goal = goalProvider.goals[index];
                      return _buildGoalCard(context, goal);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddGoal(context),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Meta',
      ),
    );
  }

  Widget _buildSummaryCard(GoalProvider goalProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo Geral',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Metas Ativas',
                  goalProvider.activeGoals.length.toString(),
                  Colors.blue,
                  Icons.flag,
                ),
                _buildSummaryItem(
                  'Concluídas',
                  goalProvider.completedGoals.length.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildSummaryItem(
                  'Progresso',
                  '${goalProvider.overallProgress.toStringAsFixed(1)}%',
                  Colors.orange,
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(BuildContext context, GoalEntity goal) {
    final progress = goal.progressPercentage;
    final isOverdue = goal.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToGoalDetail(context, goal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(goal.status),
                ],
              ),
              if (goal.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  goal.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(goal.currentAmount / 100),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${progress.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: progress >= 100 ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 100 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Meta: ${currencyFormat.format(goal.targetAmount / 100)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date and days info
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: isOverdue ? Colors.red : Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    isOverdue
                        ? 'Prazo expirado'
                        : '${goal.daysRemaining} dias restantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (goal.hasTransactions)
                    Row(
                      children: [
                        Icon(Icons.receipt_long,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${goal.transactionCount} transações',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(GoalStatus status) {
    Color color;
    String label;

    switch (status) {
      case GoalStatus.active:
        color = Colors.blue;
        label = 'Ativa';
        break;
      case GoalStatus.completed:
        color = Colors.green;
        label = 'Concluída';
        break;
      case GoalStatus.paused:
        color = Colors.orange;
        label = 'Pausada';
        break;
      case GoalStatus.cancelled:
        color = Colors.red;
        label = 'Cancelada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _navigateToAddGoal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );
  }

  void _navigateToGoalDetail(BuildContext context, GoalEntity goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goalId: goal.id),
      ),
    );
  }
}
