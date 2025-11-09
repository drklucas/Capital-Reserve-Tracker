import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../core/constants/goal_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/goal_themed_scaffold.dart';
import '../../widgets/responsive/max_width_container.dart';
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
        backgroundColor: const Color(0xFF2d3561),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja excluir esta meta?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
        backgroundColor: const Color(0xFF2d3561),
        title: const Text(
          'Alterar Status',
          style: TextStyle(color: Colors.white),
        ),
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

  Future<void> _showAddTaskDialog() async {
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => const _AddTaskDialog(),
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

  Future<void> _toggleTask(TaskEntity task) async {
    final authProvider = context.read<AppAuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    await taskProvider.toggleTask(task.id, authProvider.user!.id);
  }

  Future<void> _deleteTask(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d3561),
        title: const Text('Excluir Tarefa', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja realmente excluir "${task.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  Future<void> _reorderTasks(int oldIndex, int newIndex) async {
    final authProvider = context.read<AppAuthProvider>();
    final taskProvider = context.read<TaskProvider>();

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
      title: Text(
        status.displayName,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () => Navigator.pop(context, status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, _) {
        final goal = goalProvider.selectedGoal;
        final gradient = GoalThemedScaffold.getGradient(goal, fallbackIndex: 0);
        final primaryColor = GoalThemedScaffold.getPrimaryColor(goal, fallbackIndex: 0);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Detalhes da Meta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 22,
              tablet: 24,
              desktop: 26,
            ),
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<GoalProvider>(
            builder: (context, goalProvider, _) {
              final goal = goalProvider.selectedGoal;
              if (goal == null) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, size: 20, color: Colors.white),
                ),
                color: const Color(0xFF2d3561),
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
                        Icon(Icons.edit, color: Colors.white70),
                        SizedBox(width: 8),
                        Text('Editar', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'status',
                    child: Row(
                      children: [
                        Icon(Icons.change_circle, color: Colors.white70),
                        SizedBox(width: 8),
                        Text('Alterar Status', style: TextStyle(color: Colors.white)),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f3460),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Consumer<GoalProvider>(
              builder: (context, goalProvider, _) {
                if (goalProvider.status == GoalProviderStatus.loading) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }

                if (goalProvider.status == GoalProviderStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.white70),
                        const SizedBox(height: 16),
                        Text(
                          goalProvider.errorMessage ?? 'Erro ao carregar meta',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadGoalDetails,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final goal = goalProvider.selectedGoal;
                if (goal == null) {
                  return const Center(
                    child: Text(
                      'Meta não encontrada',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadGoalDetails,
                  color: primaryColor,
                  child: MaxWidthContainer(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(
                        ResponsiveUtils.valueByScreen(
                          context: context,
                          mobile: 16.0,
                          tablet: 20.0,
                          desktop: 24.0,
                        ),
                      ),
                      children: [
                        SizedBox(
                          height: ResponsiveUtils.valueByScreen(
                            context: context,
                            mobile: 16.0,
                            tablet: 20.0,
                            desktop: 24.0,
                          ),
                        ),

                        // Title and Status Card
                        _buildHeaderCard(context, goal, gradient),

                        SizedBox(
                          height: ResponsiveUtils.getSpacing(
                            context,
                            multiplier: 2,
                          ),
                        ),

                        // Progress Card
                        _buildProgressCard(context, primaryColor),

                        SizedBox(
                          height: ResponsiveUtils.getSpacing(
                            context,
                            multiplier: 2,
                          ),
                        ),

                        // Stats Card
                        _buildStatsCard(context, goal, primaryColor),

                        SizedBox(
                          height: ResponsiveUtils.getSpacing(
                            context,
                            multiplier: 2,
                          ),
                        ),

                        // Tasks Card
                        _buildTasksCard(context),

                        SizedBox(
                          height: ResponsiveUtils.getSpacing(
                            context,
                            multiplier: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddTaskDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_task, color: Colors.white),
          label: const Text(
            'Nova Tarefa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    GoalEntity goal,
    LinearGradient gradient,
  ) {
    final padding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context);
    final titleFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final descriptionFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildStatusChip(goal.status),
            ],
          ),
          if (goal.description.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 1.5)),
            Text(
              goal.description,
              style: TextStyle(
                fontSize: descriptionFontSize,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, Color primaryColor) {
    return Consumer<TaskProvider>(
      builder: (_, taskProvider, __) {
        final totalTasks = taskProvider.taskCount;
        final completedTasks = taskProvider.completedCount;
        final progress = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

        final padding = ResponsiveUtils.getCardPadding(context);
        final borderRadius = ResponsiveUtils.getBorderRadius(context);
        final titleFontSize = ResponsiveUtils.responsiveFontSize(
          context,
          mobile: 18.0,
          tablet: 20.0,
          desktop: 22.0,
        );
        final textFontSize = ResponsiveUtils.responsiveFontSize(
          context,
          mobile: 16.0,
          tablet: 18.0,
          desktop: 20.0,
        );
        final percentFontSize = ResponsiveUtils.responsiveFontSize(
          context,
          mobile: 22.0,
          tablet: 24.0,
          desktop: 26.0,
        );

        return Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2d3561),
                Color(0xFF1f2544),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progresso das Tarefas',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedTasks de $totalTasks tarefas',
                    style: TextStyle(
                      fontSize: textFontSize,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: percentFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 1.5)),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 100 ? Colors.green : primaryColor,
                  ),
                ),
              ),
              if (totalTasks == 0) ...[
                const SizedBox(height: 12),
                Text(
                  'Adicione tarefas para acompanhar o progresso',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    GoalEntity goal,
    Color primaryColor,
  ) {
    final padding = ResponsiveUtils.getCardPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context);
    final titleFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 22.0,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2d3561),
            Color(0xFF1f2544),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2.5)),
          _buildStatRow(
            context,
            'Período',
            '${_dateFormat.format(goal.startDate)} - ${_dateFormat.format(goal.targetDate)}',
            Icons.date_range,
            primaryColor,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
          _buildStatRow(
            context,
            goal.isOverdue ? 'Prazo expirado' : 'Dias restantes',
            goal.isOverdue
                ? 'há ${DateTime.now().difference(goal.targetDate).inDays} dias'
                : '${goal.daysRemaining} dias',
            Icons.calendar_today,
            primaryColor,
            isWarning: goal.isOverdue,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
          _buildStatRow(
            context,
            'Dias decorridos',
            '${goal.daysElapsed} de ${goal.totalDays} dias',
            Icons.access_time,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color primaryColor, {
    bool isWarning = false,
  }) {
    final labelFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      mobile: 13.0,
      tablet: 14.0,
      desktop: 15.0,
    );
    final valueFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      mobile: 15.0,
      tablet: 16.0,
      desktop: 17.0,
    );

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.valueByScreen(
          context: context,
          mobile: 14.0,
          tablet: 16.0,
          desktop: 18.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isWarning ? Colors.red : primaryColor).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isWarning ? Colors.red : primaryColor).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isWarning ? Colors.red : primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.valueByScreen(
                    context: context,
                    mobile: 4.0,
                    tablet: 5.0,
                    desktop: 6.0,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w600,
                    color: isWarning ? Colors.red : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksCard(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (_, taskProvider, child) {
        final tasks = taskProvider.tasks;
        final completedCount = taskProvider.completedCount;
        final totalCount = taskProvider.taskCount;

        final padding = ResponsiveUtils.getCardPadding(context);
        final borderRadius = ResponsiveUtils.getBorderRadius(context);
        final titleFontSize = ResponsiveUtils.responsiveFontSize(
          context,
          mobile: 18.0,
          tablet: 20.0,
          desktop: 22.0,
        );

        return Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2d3561),
                Color(0xFF1f2544),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tarefas',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$completedCount/$totalCount',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
              if (tasks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma tarefa criada',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toque no botão para criar sua primeira tarefa',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Material(
                          color: Colors.transparent,
                          child: Opacity(
                            opacity: 0.8,
                            child: child,
                          ),
                        );
                      },
                      child: child,
                    );
                  },
                  itemCount: tasks.length,
                  onReorder: (oldIndex, newIndex) {
                    _reorderTasks(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ReorderableDragStartListener(
                      key: ValueKey(task.id),
                      index: index,
                      child: _TaskListItem(
                        task: task,
                        onToggle: () => _toggleTask(task),
                        onDelete: () => _deleteTask(task),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(GoalStatus status) {
    Color color;
    switch (status) {
      case GoalStatus.active:
        color = Colors.white;
        break;
      case GoalStatus.completed:
        color = Colors.greenAccent;
        break;
      case GoalStatus.paused:
        color = Colors.orangeAccent;
        break;
      case GoalStatus.cancelled:
        color = Colors.redAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Task list item widget
class _TaskListItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskListItem({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? Colors.green.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Drag Handle
          Icon(
            Icons.drag_indicator,
            color: Colors.white.withOpacity(0.3),
            size: 20,
          ),
          const SizedBox(width: 8),
          // Checkbox
          Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: Colors.green,
            checkColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(width: 12),
          // Task Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: task.isCompleted
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Priority Flag
          if (task.priority >= 4)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (task.priority == 5 ? Colors.red : Colors.orange)
                    .withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag,
                size: 16,
                color: task.priority == 5 ? Colors.red : Colors.orange,
              ),
            ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
            color: Colors.red.withOpacity(0.7),
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
      backgroundColor: const Color(0xFF2d3561),
      title: const Text(
        'Nova Tarefa',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                hintText: 'Ex: Guardar R\$ 1.000',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3B82F6)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3B82F6)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
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
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Criar'),
        ),
      ],
    );
  }
}
