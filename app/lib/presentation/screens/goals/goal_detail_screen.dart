import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_goal_screen.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final String goalId;

  const GoalDetailScreen({
    super.key,
    required this.goalId,
  });

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGoalDetails();
  }

  Future<void> _loadGoalDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = ref.read(appAuthProvider);
      if (authState.user == null) {
        setState(() {
          _errorMessage = 'Usuário não autenticado';
          _isLoading = false;
        });
        return;
      }

      await ref.read(goalProvider.notifier).loadGoalById(
        widget.goalId,
        authState.user!.uid,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar detalhes da meta: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return Colors.green;
      case GoalStatus.completed:
        return Colors.blue;
      case GoalStatus.paused:
        return Colors.orange;
      case GoalStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return 'Ativa';
      case GoalStatus.completed:
        return 'Concluída';
      case GoalStatus.paused:
        return 'Pausada';
      case GoalStatus.cancelled:
        return 'Cancelada';
    }
  }

  Widget _buildStatusChip(GoalStatus status) {
    return Chip(
      label: Text(
        _getStatusText(status),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildProgressSection(GoalEntity goal) {
    final progress = goal.progress;
    final progressPercentage = goal.progressPercentage;
    final remaining = goal.targetAmount - goal.currentAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currencyFormat.format(goal.currentAmount),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  _currencyFormat.format(goal.targetAmount),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Faltam ${_currencyFormat.format(remaining)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(GoalEntity goal) {
    final now = DateTime.now();
    final daysRemaining = goal.targetDate?.difference(now).inDays ?? 0;
    final daysElapsed = now.difference(goal.startDate).inDays;
    final isOverdue = daysRemaining < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Tempo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data de Início',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _dateFormat.format(goal.startDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (goal.targetDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Data Alvo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _dateFormat.format(goal.targetDate!),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (goal.targetDate != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    'Dias Decorridos',
                    '$daysElapsed',
                    Colors.blue,
                  ),
                  _buildInfoItem(
                    isOverdue ? 'Prazo Expirado' : 'Dias Restantes',
                    isOverdue ? '${-daysRemaining} dias' : '$daysRemaining',
                    isOverdue ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsSection(GoalEntity goal) {
    final now = DateTime.now();
    final daysRemaining = goal.targetDate?.difference(now).inDays ?? 0;
    final daysElapsed = now.difference(goal.startDate).inDays;
    final remaining = goal.targetAmount - goal.currentAmount;

    final requiredDailySavings = daysRemaining > 0
        ? remaining / daysRemaining
        : 0.0;

    final averageDailySavings = daysElapsed > 0
        ? goal.currentAmount / daysElapsed
        : 0.0;

    final isOnTrack = averageDailySavings >= requiredDailySavings;

    // Calculate estimated completion date
    DateTime? estimatedCompletion;
    if (averageDailySavings > 0 && goal.currentAmount < goal.targetAmount) {
      final daysToComplete = remaining / averageDailySavings;
      estimatedCompletion = now.add(Duration(days: daysToComplete.ceil()));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análise de Poupança',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  'Poupança Diária Necessária',
                  _currencyFormat.format(requiredDailySavings),
                  Theme.of(context).colorScheme.primary,
                ),
                _buildInfoItem(
                  'Média Diária Atual',
                  _currencyFormat.format(averageDailySavings),
                  isOnTrack ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOnTrack
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isOnTrack ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnTrack ? Icons.trending_up : Icons.trending_down,
                    color: isOnTrack ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOnTrack ? 'No prazo' : 'Atrasado',
                    style: TextStyle(
                      color: isOnTrack ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (estimatedCompletion != null && goal.status == GoalStatus.active) ...[
              const SizedBox(height: 16),
              Text(
                'Data Estimada de Conclusão',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                _dateFormat.format(estimatedCompletion),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: estimatedCompletion.isBefore(goal.targetDate ?? now)
                          ? Colors.green
                          : Colors.orange,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(List<String> transactionIds) {
    if (transactionIds.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transações Associadas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Nenhuma transação associada',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transações Associadas (${transactionIds.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...transactionIds.map((id) => ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: Text('Transação: $id'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(GoalEntity goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Meta'),
        content: Text(
          'Tem certeza que deseja excluir a meta "${goal.name}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteGoal();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal() async {
    try {
      await ref.read(goalProvider.notifier).deleteGoal(widget.goalId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir meta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatusChangeDialog(GoalEntity goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GoalStatus.values.map((status) {
            return RadioListTile<GoalStatus>(
              title: Text(_getStatusText(status)),
              value: status,
              groupValue: goal.status,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.of(context).pop();
                  await _updateStatus(value);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(GoalStatus newStatus) async {
    try {
      final goal = ref.read(goalProvider).selectedGoal;
      if (goal != null) {
        final updatedGoal = goal.copyWith(status: newStatus);
        await ref.read(goalProvider.notifier).updateGoal(updatedGoal);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status alterado para ${_getStatusText(newStatus)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(goalProvider);
    final goal = goalState.selectedGoal;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal?.name ?? 'Detalhes da Meta'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          if (goal != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddGoalScreen(goal: goal),
                  ),
                );
                if (result == true) {
                  await _loadGoalDetails();
                }
              },
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(goal),
              tooltip: 'Excluir',
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGoalDetails,
        child: _buildBody(goal),
      ),
    );
  }

  Widget _buildBody(GoalEntity? goal) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadGoalDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (goal == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Meta não encontrada',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      _buildStatusChip(goal.status),
                    ],
                  ),
                  if (goal.description != null && goal.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      goal.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress Section
          _buildProgressSection(goal),
          const SizedBox(height: 16),

          // Time Section
          _buildTimeSection(goal),
          const SizedBox(height: 16),

          // Savings Analysis Section
          if (goal.targetDate != null)
            _buildSavingsSection(goal),
          const SizedBox(height: 16),

          // Transactions Section
          _buildTransactionsList(goal.associatedTransactionIds ?? []),
          const SizedBox(height: 16),

          // Action Buttons
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ações',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showStatusChangeDialog(goal),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Alterar Status'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}