import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
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
    final taskProvider = context.read<TaskProvider>();

    if (authProvider.user != null) {
      await goalProvider.loadGoalById(widget.goalId, authProvider.user!.id);
      // Watch tasks in real-time for this goal
      taskProvider.watchTasksByGoal(
        goalId: widget.goalId,
        userId: authProvider.user!.id,
      );
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
        authProvider.user!.id,
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
        authProvider.user!.id,
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

  /// Show dialog to add a new task
  Future<void> _showAddTaskDialog() async {
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => _AddTaskDialog(),
    );

    if (result != null && mounted) {
      final authProvider = context.read<AppAuthProvider>();
      final taskProvider = context.read<TaskProvider>();

      final success = await taskProvider.createTask(
        userId: authProvider.user!.id,
        goalId: widget.goalId,
        title: result['title']!,
        description: result['description']!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Tarefa criada com sucesso'
                  : taskProvider.errorMessage ?? 'Erro ao criar tarefa',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  /// Toggle task completion status
  Future<void> _toggleTask(TaskEntity task) async {
    final authProvider = context.read<AppAuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    await taskProvider.toggleTask(task.id, authProvider.user!.id);
  }

  /// Delete a task
  Future<void> _deleteTask(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tarefa'),
        content: Text('Deseja realmente excluir "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AppAuthProvider>();
      final taskProvider = context.read<TaskProvider>();

      final success = await taskProvider.deleteTask(
        task.id,
        authProvider.user!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Tarefa excluída'
                  : taskProvider.errorMessage ?? 'Erro ao excluir tarefa',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  /// Reorder tasks
  Future<void> _reorderTasks(int oldIndex, int newIndex) async {
    final authProvider = context.read<AppAuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    // Adjust newIndex if needed (Flutter's ReorderableListView quirk)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    await taskProvider.reorderTasks(
      userId: authProvider.user!.id,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
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

                // Progress Card - Based on Tasks
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) {
                    final totalTasks = taskProvider.taskCount;
                    final completedTasks = taskProvider.completedCount;
                    final progress = totalTasks > 0
                        ? (completedTasks / totalTasks * 100)
                        : 0.0;

                    return Card(
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
                                  '$completedTasks de $totalTasks tarefas',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  '${progress.toStringAsFixed(1)}%',
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
                                value: progress / 100,
                                minHeight: 12,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress >= 100 ? Colors.green : Colors.blue,
                                ),
                              ),
                            ),
                            if (totalTasks == 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Adicione tarefas para acompanhar o progresso',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
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
                        // Comentado temporariamente - Status sempre aparece como "Atrasado"
                        // const Divider(height: 24),
                        // _buildStatRow(
                        //   'Status',
                        //   goal.isOnTrack ? 'No prazo ✓' : 'Atrasado ⚠',
                        //   isWarning: !goal.isOnTrack,
                        // ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tasks Card
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) {
                    final tasks = taskProvider.tasks;
                    final completedCount = taskProvider.completedCount;
                    final totalCount = taskProvider.taskCount;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tarefas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '$completedCount/$totalCount',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _showAddTaskDialog(),
                                      tooltip: 'Adicionar Tarefa',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (tasks.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.task_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Nenhuma tarefa criada',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: () => _showAddTaskDialog(),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Criar primeira tarefa'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tasks.length,
                                onReorder: (oldIndex, newIndex) {
                                  _reorderTasks(oldIndex, newIndex);
                                },
                                itemBuilder: (context, index) {
                                  final task = tasks[index];
                                  return Column(
                                    key: ValueKey(task.id),
                                    children: [
                                      if (index > 0) const Divider(height: 1),
                                      _TaskListItem(
                                        task: task,
                                        onToggle: () => _toggleTask(task),
                                        onDelete: () => _deleteTask(task),
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                /* OLD CODE - Transactions linked to goals
                Consumer<TransactionProvider>(
                  builder: (context, transactionProvider, _) {
                    final goalTransactions = [];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transações Associadas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${goalTransactions.length}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (goalTransactions.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Nenhuma transação associada',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: goalTransactions.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final transaction = goalTransactions[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: transaction.isIncome
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      child: Icon(
                                        transaction.category.icon,
                                        color: transaction.isIncome
                                            ? Colors.green
                                            : Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      transaction.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _dateFormat.format(transaction.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    trailing: Text(
                                      _currencyFormat.format(
                                        transaction.signedAmount,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: transaction.isIncome
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                */
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

/// Task list item widget
class _TaskListItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskListItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration:
              task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          color: task.isCompleted ? Colors.grey : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: task.description.isNotEmpty
          ? Text(
              task.description,
              style: TextStyle(
                fontSize: 12,
                color: task.isCompleted ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.priority >= 4)
            Icon(
              Icons.flag,
              size: 16,
              color: task.priority == 5 ? Colors.red : Colors.orange,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
            color: Colors.red[300],
          ),
        ],
      ),
    );
  }
}

/// Dialog for adding a new task
class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Tarefa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ex: Guardar R\$ 1.000',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'title': _titleController.text.trim(),
                'description': _descriptionController.text.trim(),
              });
            }
          },
          child: const Text('Criar'),
        ),
      ],
    );
  }
}
