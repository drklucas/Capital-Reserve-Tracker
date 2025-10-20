import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final authProvider = context.read<AppAuthProvider>();
    if (authProvider.user != null) {
      final userId = authProvider.user!.id;

      // Watch goals (real-time updates)
      context.read<GoalProvider>().watchGoals(userId);

      // Watch transactions (real-time updates)
      context.read<TransactionProvider>().watchTransactions(userId: userId);

      // Update dashboard with current data (will watch tasks automatically)
      _updateDashboardProviders();
    }
  }

  void _updateDashboardProviders() {
    final authProvider = context.read<AppAuthProvider>();
    final goalProvider = context.read<GoalProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final taskProvider = context.read<TaskProvider>();
    final dashboardProvider = context.read<DashboardProvider>();

    dashboardProvider.updateGoals(goalProvider.goals);
    dashboardProvider.updateTransactions(transactionProvider.transactions);

    // Watch tasks for goals that don't have tasks loaded yet
    if (authProvider.user != null) {
      for (var goal in goalProvider.goals) {
        final hasTasksForGoal = taskProvider.tasks.any((t) => t.goalId == goal.id);
        if (!hasTasksForGoal) {
          taskProvider.watchTasksByGoal(
            userId: authProvider.user!.id,
            goalId: goal.id,
          );
        }
      }
    }

    // Build tasks map by goal
    final tasksByGoal = <String, List<TaskEntity>>{};
    for (var goal in goalProvider.goals) {
      tasksByGoal[goal.id] = taskProvider.tasks
          .where((task) => task.goalId == goal.id)
          .toList();
    }
    dashboardProvider.updateTasksByGoal(tasksByGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer3<DashboardProvider, GoalProvider, TaskProvider>(
            builder: (context, dashboardProvider, goalProvider, taskProvider, _) {
              // Update dashboard providers when goals/tasks change
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateDashboardProviders();
              });

              final summary = dashboardProvider.summary;

              return RefreshIndicator(
                onRefresh: () async {
                  _loadDashboardData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Summary Cards (2x2 Grid)
                      _buildSummaryCards(summary),
                      const SizedBox(height: 32),

                      // Reserve Evolution Chart
                      _buildSectionTitle('Evolução da Reserva'),
                      const SizedBox(height: 16),
                      _buildReserveEvolutionChart(dashboardProvider),
                      const SizedBox(height: 32),

                      // Income vs Expenses Chart
                      _buildSectionTitle('Receitas vs Despesas'),
                      const SizedBox(height: 16),
                      _buildIncomeExpensesChart(dashboardProvider),
                      const SizedBox(height: 32),

                      // Goals Progress
                      _buildSectionTitle('Progresso das Metas'),
                      const SizedBox(height: 16),
                      _buildGoalsProgress(dashboardProvider),
                      const SizedBox(height: 32),

                      // Insights
                      _buildSectionTitle('Insights'),
                      const SizedBox(height: 16),
                      _buildInsights(dashboardProvider),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DashboardSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildSummaryCard(
          title: 'Reserva Total',
          value: _currencyFormat.format(summary.totalReserve),
          icon: Icons.account_balance_wallet,
          color: const Color(0xFF5A67D8),
        ),
        _buildSummaryCard(
          title: 'Meta Total',
          value: _currencyFormat.format(summary.totalGoalAmount),
          icon: Icons.flag,
          color: const Color(0xFF6B46C1),
        ),
        _buildSummaryCard(
          title: 'Progresso Geral',
          value: '${summary.progressPercentage.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: const Color(0xFF48BB78),
        ),
        _buildSummaryCard(
          title: 'Saldo Mensal',
          value: _currencyFormat.format(summary.monthlyBalance),
          icon: Icons.calendar_today,
          color: summary.monthlyBalance >= 0
              ? const Color(0xFF48BB78)
              : const Color(0xFFE53E3E),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReserveEvolutionChart(DashboardProvider provider) {
    final data = provider.getReserveEvolution(6);

    if (data.isEmpty) {
      return _buildEmptyChart('Nenhum dado disponível');
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              backgroundColor: Colors.transparent,
              gridData: FlGridData(
                drawHorizontalLine: false,
                horizontalInterval: 1,
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        final month = data[value.toInt()].month;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM', 'pt_BR').format(month),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        NumberFormat.compact(locale: 'pt_BR').format(value),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              maxY:
                  data.map((e) => e.balance).reduce((a, b) => a > b ? a : b) *
                  1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.balance);
                  }).toList(),
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5A67D8), Color(0xFF6B46C1)],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF5A67D8).withOpacity(0.3),
                        const Color(0xFF6B46C1).withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpensesChart(DashboardProvider provider) {
    final data = provider.getMonthlyData(6);

    if (data.isEmpty) {
      return _buildEmptyChart('Nenhum dado disponível');
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              backgroundColor: Colors.transparent,
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  data
                      .map((e) => e.income > e.expenses ? e.income : e.expenses)
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        final month = data[value.toInt()].month;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM', 'pt_BR').format(month),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        NumberFormat.compact(locale: 'pt_BR').format(value),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: data.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.income,
                      color: const Color(0xFF48BB78),
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: entry.value.expenses,
                      color: const Color(0xFFE53E3E),
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsProgress(DashboardProvider provider) {
    final goalsProgress = provider.goalsProgress;

    if (goalsProgress.isEmpty) {
      return _buildEmptyCard('Nenhuma meta ativa');
    }

    return Column(
      children: goalsProgress.take(5).map((goal) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.goalTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        goal.isOnTrack ? Icons.check_circle : Icons.warning,
                        size: 16,
                        color: goal.isOnTrack
                            ? const Color(0xFF48BB78)
                            : const Color(0xFFFBD38D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${goal.progressPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isOnTrack
                        ? const Color(0xFF48BB78)
                        : const Color(0xFFFBD38D),
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${goal.completedTasks}/${goal.totalTasks} tarefas completas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsights(DashboardProvider provider) {
    return Column(
      children: [
        // Risky Goals Card
        if (provider.riskyGoals.isNotEmpty) ...[
          _buildInsightCard(
            icon: Icons.warning_amber,
            iconColor: const Color(0xFFFBD38D),
            title: 'Metas em Risco',
            description:
                '${provider.riskyGoals.length} meta(s) com prazo próximo e baixo progresso',
            onTap: () {
              // Navigate to goals screen
            },
          ),
          const SizedBox(height: 12),
        ],

        // Savings Velocity Card
        _buildInsightCard(
          icon: Icons.speed,
          iconColor: const Color(0xFF5A67D8),
          title: 'Velocidade de Economia',
          description:
              '${_currencyFormat.format(provider.savingsVelocityPerWeek)}/semana',
          onTap: () {},
        ),
        const SizedBox(height: 12),

        // Monthly Average Card
        _buildInsightCard(
          icon: Icons.trending_up,
          iconColor: const Color(0xFF48BB78),
          title: 'Média Mensal',
          description:
              '${_currencyFormat.format(provider.averageMonthlySavings)} de economia',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
      ),
    );
  }
}
