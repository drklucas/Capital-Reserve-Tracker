import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final String goalId;

  const GoalDetailScreen({
    Key? key,
    required this.goalId,
  }) : super(key: key);

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGoalDetails();
    });
  }

  Future<void> _loadGoalDetails() async {
    final authProvider = context.read<AppAuthProvider>();
    final goalProvider = context.read<GoalProvider>();

    if (authProvider.currentUser != null) {
      await goalProvider.loadGoalById(widget.goalId, authProvider.currentUser!.id);
    }
  }

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta meta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AppAuthProvider>();
      final goalProvider = context.read<GoalProvider>();

      final success = await goalProvider.deleteGoal(
        widget.goalId,
        authProvider.currentUser!.id,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta excluída com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(goalProvider.errorMessage ?? 'Erro ao excluir meta'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _changeStatus() async {
    final goal = context.read<GoalProvider>().selectedGoal;
    if (goal == null) return;

    final newStatus = await showDialog<GoalStatus>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(GoalStatus.active),
            _buildStatusOption(GoalStatus.paused),
            _buildStatusOption(GoalStatus.completed),
            _buildStatusOption(GoalStatus.cancelled),
          ],
        ),
      ),
    );

    if (newStatus != null && mounted) {
      final authProvider = context.read<AppAuthProvider>();
      final goalProvider = context.read<GoalProvider>();

      final success = await goalProvider.updateGoalEntityStatus(
        widget.goalId,
        authProvider.currentUser!.id,
        newStatus,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status atualizado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _loadGoalDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(goalProvider.errorMessage ?? 'Erro ao atualizar status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildStatusOption(GoalStatus status) {
    return ListTile(
      title: Text(status.displayName),
      onTap: () => Navigator.pop(context, status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Meta'),
        actions: [
          Consumer<GoalProvider>(
            builder: (context, goalProvider, _) {
              final goal = goalProvider.selectedGoal;
              if (goal == null) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddGoalScreen(goal: goal),
                        ),
                      ).then((_) => _loadGoalDetails());
                      break;
                    case 'status':
                      _changeStatus();
                      break;
                    case 'delete':
                      _deleteGoal();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'status',
                    child: Row(
                      children: [
                        Icon(Icons.change_circle),
                        SizedBox(width: 8),
                        Text('Alterar Status'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Excluir', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, _) {
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
                    goalProvider.errorMessage ?? 'Erro ao carregar meta',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadGoalDetails,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final goal = goalProvider.selectedGoal;
          if (goal == null) {
            return const Center(child: Text('Meta não encontrada'));
          }

          return RefreshIndicator(
            onRefresh: _loadGoalDetails,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title and Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 24,
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
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progresso',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _currencyFormat.format(goal.currentAmount / 100),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              '${goal.progressPercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: goal.progressPercentage / 100,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goal.isCompleted ? Colors.green : Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Meta: ${_currencyFormat.format(goal.targetAmount / 100)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estatísticas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          'Faltam',
                          _currencyFormat.format(goal.remainingAmount / 100),
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Período',
                          '${_dateFormat.format(goal.startDate)} - ${_dateFormat.format(goal.targetDate)}',
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          goal.isOverdue ? 'Prazo expirado' : 'Dias restantes',
                          goal.isOverdue
                              ? 'há ${DateTime.now().difference(goal.targetDate).inDays} dias'
                              : '${goal.daysRemaining} dias',
                          isWarning: goal.isOverdue,
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Dias decorridos',
                          '${goal.daysElapsed} de ${goal.totalDays} dias',
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Economia diária necessária',
                          _currencyFormat.format(goal.requiredDailySavings / 100),
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Economia diária média',
                          _currencyFormat.format(goal.averageDailySavings / 100),
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Status',
                          goal.isOnTrack ? 'No prazo ✓' : 'Atrasado ⚠',
                          isWarning: !goal.isOnTrack,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Transactions Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transações Associadas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        goal.hasTransactions
                            ? Text(
                                '${goal.transactionCount} transações associadas',
                                style: TextStyle(color: Colors.grey[600]),
                              )
                            : Text(
                                'Nenhuma transação associada',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(GoalStatus status) {
    Color color;
    switch (status) {
      case GoalStatus.active:
        color = Colors.blue;
        break;
      case GoalStatus.completed:
        color = Colors.green;
        break;
      case GoalStatus.paused:
        color = Colors.orange;
        break;
      case GoalStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isWarning = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isWarning ? Colors.red : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isWarning ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}
