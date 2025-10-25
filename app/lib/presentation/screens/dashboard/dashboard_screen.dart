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
import '../goals/goal_detail_screen.dart';

/// Period filter for reserve evolution chart
enum ReservePeriod {
  today,
  lastWeek,
  lastMonth,
  lastMonths,
}

extension ReservePeriodExtension on ReservePeriod {
  String get displayName {
    switch (this) {
      case ReservePeriod.today:
        return 'Hoje';
      case ReservePeriod.lastWeek:
        return 'Última Semana';
      case ReservePeriod.lastMonth:
        return 'Último Mês';
      case ReservePeriod.lastMonths:
        return 'Últimos Meses';
    }
  }

  int get monthsCount {
    switch (this) {
      case ReservePeriod.today:
        return 0;
      case ReservePeriod.lastWeek:
        return 0;
      case ReservePeriod.lastMonth:
        return 1;
      case ReservePeriod.lastMonths:
        return 6;
    }
  }
}

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

  bool _tasksWatchInitialized = false;
  ReservePeriod _selectedPeriod = ReservePeriod.lastMonths;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();

      // Listen to changes in GoalProvider and TaskProvider
      context.read<GoalProvider>().addListener(_onGoalsChanged);
      context.read<TaskProvider>().addListener(_updateDashboardProviders);
    });
  }

  @override
  void dispose() {
    // Remove listeners
    context.read<GoalProvider>().removeListener(_onGoalsChanged);
    context.read<TaskProvider>().removeListener(_updateDashboardProviders);
    super.dispose();
  }

  void _onGoalsChanged() {
    if (!mounted) return;

    final authProvider = context.read<AppAuthProvider>();
    final goalProvider = context.read<GoalProvider>();
    final taskProvider = context.read<TaskProvider>();

    debugPrint('Dashboard: _onGoalsChanged called, goals count: ${goalProvider.goals.length}');

    // Watch tasks for all goals when goals are loaded
    if (!_tasksWatchInitialized && goalProvider.goals.isNotEmpty && authProvider.user != null) {
      _tasksWatchInitialized = true;
      final userId = authProvider.user!.id;

      debugPrint('Dashboard: Initializing task watch for ${goalProvider.goals.length} goals');

      for (var goal in goalProvider.goals) {
        debugPrint('Dashboard: Watching tasks for goal "${goal.title}" (${goal.id})');
        taskProvider.watchTasksByGoal(
          userId: userId,
          goalId: goal.id,
        );
      }
    }

    _updateDashboardProviders();
  }

  void _loadDashboardData() {
    final authProvider = context.read<AppAuthProvider>();
    if (authProvider.user != null) {
      final userId = authProvider.user!.id;

      // Watch goals (real-time updates) - this will trigger _onGoalsChanged
      context.read<GoalProvider>().watchGoals(userId);

      // Watch transactions (real-time updates)
      context.read<TransactionProvider>().watchTransactions(userId: userId);

      // Update dashboard with current data
      _updateDashboardProviders();
    }
  }

  void _updateDashboardProviders() {
    if (!mounted) return;

    final goalProvider = context.read<GoalProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final taskProvider = context.read<TaskProvider>();
    final dashboardProvider = context.read<DashboardProvider>();

    dashboardProvider.updateGoals(goalProvider.goals);
    dashboardProvider.updateTransactions(transactionProvider.transactions);

    // Build tasks map by goal
    final tasksByGoal = <String, List<TaskEntity>>{};
    for (var goal in goalProvider.goals) {
      final tasksForGoal = taskProvider.tasks
          .where((task) => task.goalId == goal.id)
          .toList();
      tasksByGoal[goal.id] = tasksForGoal;

      // Debug log
      debugPrint('Dashboard: Goal "${goal.title}" (${goal.id}) has ${tasksForGoal.length} tasks');
    }

    debugPrint('Dashboard: Total tasks in TaskProvider: ${taskProvider.tasks.length}');
    debugPrint('Dashboard: Total goals: ${goalProvider.goals.length}');

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
          child: Consumer<DashboardProvider>(
            builder: (context, dashboardProvider, _) {
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
                      _buildSectionTitleWithFilter(
                        'Evolução da Reserva',
                        _selectedPeriod,
                        (ReservePeriod? newPeriod) {
                          if (newPeriod != null) {
                            setState(() {
                              _selectedPeriod = newPeriod;
                            });
                          }
                        },
                      ),
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

  Widget _buildSectionTitleWithFilter(
    String title,
    ReservePeriod selectedPeriod,
    ValueChanged<ReservePeriod?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: DropdownButton<ReservePeriod>(
              value: selectedPeriod,
              onChanged: onChanged,
              underline: const SizedBox(),
              dropdownColor: const Color(0xFF2d3561),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              items: ReservePeriod.values.map((ReservePeriod period) {
                return DropdownMenuItem<ReservePeriod>(
                  value: period,
                  child: Text(period.displayName),
                );
              }).toList(),
            ),
          ),
        ],
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
    // Get data based on selected period
    final List<MonthlyDataPoint> data;

    switch (_selectedPeriod) {
      case ReservePeriod.today:
        // For today, show just today's data
        data = provider.getReserveEvolution(0);
        break;
      case ReservePeriod.lastWeek:
        // For last week, show weekly data (convert to appropriate format)
        data = provider.getReserveEvolution(0);
        break;
      case ReservePeriod.lastMonth:
        // For last month, show just one month
        data = provider.getReserveEvolution(1);
        break;
      case ReservePeriod.lastMonths:
        // For last months, show 6 months (default)
        data = provider.getReserveEvolution(6);
        break;
    }

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
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoalDetailScreen(goalId: goal.goalId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
