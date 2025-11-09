import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../goals/goal_detail_screen.dart';
import '../../widgets/charts/category_spending_chart.dart';
import '../../widgets/charts/hourly_spending_chart.dart';
import '../../widgets/charts/daily_spending_pattern_chart.dart';
import '../../widgets/charts/value_range_chart.dart';
import '../../../core/utils/responsive_utils.dart';

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

/// Period filter for income/expenses chart
enum IncomeExpensesPeriod {
  lastWeek,
  lastMonth,
  lastMonths,
  lastYear,
}

extension IncomeExpensesPeriodExtension on IncomeExpensesPeriod {
  String get displayName {
    switch (this) {
      case IncomeExpensesPeriod.lastWeek:
        return 'Semana';
      case IncomeExpensesPeriod.lastMonth:
        return 'Mês';
      case IncomeExpensesPeriod.lastMonths:
        return '6 Meses';
      case IncomeExpensesPeriod.lastYear:
        return 'Ano';
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

  ReservePeriod _selectedPeriod = ReservePeriod.lastMonths;
  IncomeExpensesPeriod _selectedIncomeExpensesPeriod = IncomeExpensesPeriod.lastMonths;
  bool _isInitialized = false;

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

      // DashboardProvider now manages its own goals and tasks
      context.read<DashboardProvider>().watchGoals(userId);

      // TransactionProvider still manages transactions
      context.read<TransactionProvider>().watchTransactions(userId: userId);
    }
  }


  /// Get date format based on selected period
  String _getDateFormat() {
    switch (_selectedPeriod) {
      case ReservePeriod.today:
        return 'HH:mm'; // Show hours and minutes for today
      case ReservePeriod.lastWeek:
        return 'dd/MM'; // Show day/month for last week
      case ReservePeriod.lastMonth:
        return 'dd/MM'; // Show day/month for last month
      case ReservePeriod.lastMonths:
        return 'MMM'; // Show month abbreviation for last months
    }
  }

  /// Get interval for bottom titles based on data length and period
  double _getBottomTitlesInterval(int dataLength) {
    if (dataLength <= 1) return 1;

    switch (_selectedPeriod) {
      case ReservePeriod.today:
        // Show every data point if there are few transactions, otherwise show every other one
        return dataLength <= 6 ? 1 : 2;
      case ReservePeriod.lastWeek:
        return 1; // Show all 7 days
      case ReservePeriod.lastMonth:
        // Show every 5th day for 30 days
        return 5;
      case ReservePeriod.lastMonths:
        return 1; // Show all 6 months
    }
  }

  /// Get date format for income/expenses chart
  String _getIncomeExpensesDateFormat() {
    switch (_selectedIncomeExpensesPeriod) {
      case IncomeExpensesPeriod.lastWeek:
        return 'EEE'; // Show day of week abbreviation (Seg, Ter, etc.)
      case IncomeExpensesPeriod.lastMonth:
        return 'dd/MM'; // Show day/month
      case IncomeExpensesPeriod.lastMonths:
        return 'MMM'; // Show month abbreviation
      case IncomeExpensesPeriod.lastYear:
        return 'MMM'; // Show month abbreviation
    }
  }

  /// Get interval for income/expenses chart bottom titles
  double _getIncomeExpensesInterval(int dataLength) {
    if (dataLength <= 1) return 1;

    switch (_selectedIncomeExpensesPeriod) {
      case IncomeExpensesPeriod.lastWeek:
        return 1; // Show all 7 days
      case IncomeExpensesPeriod.lastMonth:
        return 1; // Check every index, but filter in getTitlesWidget to show only days divisible by 5
      case IncomeExpensesPeriod.lastMonths:
        return 1; // Show all 6 months
      case IncomeExpensesPeriod.lastYear:
        return 1; // Show all 12 months
    }
  }

  /// Get dynamic bar width based on data length
  double _getDynamicBarWidth(int dataLength) {
    if (dataLength <= 3) return 24; // Wide bars for very few data points
    if (dataLength <= 7) return 18; // Medium-wide bars for weekly view
    if (dataLength <= 12) return 14; // Smaller bars for monthly/6-months view
    return 12; // Standard bar width for year view
  }

  /// Get chart alignment based on data length
  BarChartAlignment _getChartAlignment(int dataLength) {
    if (dataLength <= 5) return BarChartAlignment.center; // Center when few bars
    return BarChartAlignment.spaceAround; // Space around for more bars
  }

  /// Get bar spacing based on data length
  double _getBarSpacing(int dataLength) {
    // Barras sempre próximas, independente da quantidade de dados
    return 4; // Espaçamento mínimo fixo entre as barras do mesmo grupo
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
          child: Consumer2<DashboardProvider, TransactionProvider>(
            builder: (context, dashboardProvider, transactionProvider, _) {
              // Initialize transactions only once
              if (!_isInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _isInitialized = true;
                    });
                    dashboardProvider.updateTransactions(transactionProvider.transactions);
                  }
                });
              }

              final summary = dashboardProvider.summary;

              return RefreshIndicator(
                onRefresh: () async {
                  _loadDashboardData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ResponsiveLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),

                        // Summary Cards (Responsive Grid)
                        _buildSummaryCards(summary, context),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),

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
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                        RepaintBoundary(
                          child: _buildReserveEvolutionChart(dashboardProvider, context),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),

                        // Income vs Expenses Chart
                        _buildSectionTitleWithIncomeExpensesFilter(
                          'Receitas vs Despesas',
                          _selectedIncomeExpensesPeriod,
                          (IncomeExpensesPeriod? newPeriod) {
                            if (newPeriod != null) {
                              setState(() {
                                _selectedIncomeExpensesPeriod = newPeriod;
                              });
                            }
                          },
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                        RepaintBoundary(
                          child: _buildIncomeExpensesChart(dashboardProvider, context),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),

                        // Goals Progress
                        _buildSectionTitle('Progresso das Metas', context),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                        RepaintBoundary(
                          child: _buildGoalsProgress(dashboardProvider),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),

                        // Insights
                        _buildSectionTitle('Insights', context),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                        RepaintBoundary(
                          child: _buildInsights(dashboardProvider),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),

                        // Spending Analysis Section
                        _buildSectionTitle('Análise de Gastos', context),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

                        // Category Spending Chart
                        RepaintBoundary(
                          child: _buildCategorySpendingChart(dashboardProvider),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

                        // Hourly Spending Chart
                        RepaintBoundary(
                          child: _buildHourlySpendingChart(dashboardProvider),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

                        // Daily Pattern Chart
                        RepaintBoundary(
                          child: _buildDailyPatternChart(dashboardProvider),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

                        // Value Range Chart
                        RepaintBoundary(
                          child: _buildValueRangeChart(dashboardProvider),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: ResponsiveUtils.getSpacing(context, multiplier: 0.5)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(
            context,
            mobile: 20,
            tablet: 22,
            desktop: 24,
          ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Clean horizontal pill buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: ReservePeriod.values.map((period) {
                final isSelected = period == selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onChanged(period),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF5A67D8), Color(0xFF6B46C1)],
                              )
                            : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        period.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitleWithIncomeExpensesFilter(
    String title,
    IncomeExpensesPeriod selectedPeriod,
    ValueChanged<IncomeExpensesPeriod?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Clean horizontal pill buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: IncomeExpensesPeriod.values.map((period) {
                final isSelected = period == selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onChanged(period),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF48BB78), Color(0xFF2F855A)],
                              )
                            : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        period.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(DashboardSummary summary, BuildContext context) {
    final columns = ResponsiveUtils.valueByScreen(
      context: context,
      mobile: 2,
      tablet: 2,
      desktop: 4,
    );

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: ResponsiveUtils.getSpacing(context, multiplier: 1.5),
      mainAxisSpacing: ResponsiveUtils.getSpacing(context, multiplier: 1.5),
      childAspectRatio: ResponsiveUtils.valueByScreen(
        context: context,
        mobile: 1.3,
        tablet: 1.2,
        desktop: 1.1,
      ),
      children: [
        _buildSummaryCard(
          title: 'Reserva Total',
          value: _currencyFormat.format(summary.totalReserve),
          icon: Icons.account_balance_wallet,
          color: const Color(0xFF5A67D8),
          context: context,
        ),
        _buildSummaryCard(
          title: 'Meta Total',
          value: _currencyFormat.format(summary.totalGoalAmount),
          icon: Icons.flag,
          color: const Color(0xFF6B46C1),
          context: context,
        ),
        _buildSummaryCard(
          title: 'Progresso Geral',
          value: '${summary.progressPercentage.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: const Color(0xFF48BB78),
          context: context,
        ),
        _buildSummaryCard(
          title: 'Saldo Mensal',
          value: _currencyFormat.format(summary.monthlyBalance),
          icon: Icons.calendar_today,
          color: summary.monthlyBalance >= 0
              ? const Color(0xFF48BB78)
              : const Color(0xFFE53E3E),
          context: context,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: ResponsiveUtils.getCardPadding(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
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
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    mobile: 11,
                    tablet: 12,
                    desktop: 13,
                  ),
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Icon(
                icon,
                color: color,
                size: ResponsiveUtils.valueByScreen(
                  context: context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReserveEvolutionChart(DashboardProvider provider, BuildContext context) {
    // Get data based on selected period
    final List<MonthlyDataPoint> data;

    switch (_selectedPeriod) {
      case ReservePeriod.today:
        // For today, show hourly granularity
        data = provider.getReserveEvolutionToday();
        break;
      case ReservePeriod.lastWeek:
        // For last week, show daily data
        data = provider.getReserveEvolutionLastWeek();
        break;
      case ReservePeriod.lastMonth:
        // For last month, show daily data
        data = provider.getReserveEvolutionLastMonth();
        break;
      case ReservePeriod.lastMonths:
        // For last months, show 6 months (monthly aggregation)
        data = provider.getReserveEvolution(6);
        break;
    }

    if (data.isEmpty) {
      return _buildEmptyChart('Nenhum dado disponível', context);
    }

    return Container(
      height: ResponsiveUtils.getChartHeight(context),
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
                    interval: _getBottomTitlesInterval(data.length),
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        final dateTime = data[value.toInt()].month;
                        final format = _getDateFormat();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat(format, 'pt_BR').format(dateTime),
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

  Widget _buildIncomeExpensesChart(DashboardProvider provider, BuildContext context) {
    // Get data based on selected period
    final List<MonthlyDataPoint> data;

    switch (_selectedIncomeExpensesPeriod) {
      case IncomeExpensesPeriod.lastWeek:
        data = provider.getIncomeExpensesLastWeek();
        break;
      case IncomeExpensesPeriod.lastMonth:
        data = provider.getIncomeExpensesLastMonth();
        break;
      case IncomeExpensesPeriod.lastMonths:
        data = provider.getMonthlyData(6);
        break;
      case IncomeExpensesPeriod.lastYear:
        data = provider.getIncomeExpensesLastYear();
        break;
    }

    if (data.isEmpty) {
      return _buildEmptyChart('Nenhum dado disponível', context);
    }

    final barWidth = _getDynamicBarWidth(data.length);
    final alignment = _getChartAlignment(data.length);
    final spacing = _getBarSpacing(data.length);

    return Container(
      key: ValueKey('income_expenses_${_selectedIncomeExpensesPeriod.name}_${data.length}'),
      height: ResponsiveUtils.getChartHeight(context),
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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            BarChartData(
              backgroundColor: Colors.transparent,
              alignment: alignment,
              maxY:
                  data
                      .map((e) => e.income > e.expenses ? e.income : e.expenses)
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => const Color(0xFF2d3561),
                  tooltipBorderRadius: BorderRadius.circular(8),
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final dataPoint = data[group.x.toInt()];
                    final isIncome = rodIndex == 0;
                    final value = isIncome ? dataPoint.income : dataPoint.expenses;
                    return BarTooltipItem(
                      '${isIncome ? 'Receita' : 'Despesa'}\n${_currencyFormat.format(value)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
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
                    interval: _getIncomeExpensesInterval(data.length),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      // Quando há poucos dados, mostrar todos os labels
                      if (data.length <= 7) {
                        if (index >= 0 && index < data.length) {
                          final dateTime = data[index].month;
                          final format = _getIncomeExpensesDateFormat();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat(format, 'pt_BR').format(dateTime),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                      } else {
                        // Para períodos com muitos dados, aplicar filtro
                        if (_selectedIncomeExpensesPeriod == IncomeExpensesPeriod.lastMonth) {
                          // Mostrar labels nos dias 5, 10, 15, 20, 25, 30 (índices 4, 9, 14, 19, 24, 29)
                          if (!((index + 1) % 5 == 0)) {
                            return const SizedBox.shrink();
                          }
                        }

                        if (index >= 0 && index < data.length) {
                          final dateTime = data[index].month;
                          final format = _getIncomeExpensesDateFormat();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat(format, 'pt_BR').format(dateTime),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
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
                  barsSpace: spacing,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.income,
                      color: const Color(0xFF48BB78),
                      width: barWidth,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: entry.value.expenses,
                      color: const Color(0xFFE53E3E),
                      width: barWidth,
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

  Widget _buildEmptyChart(String message, BuildContext context) {
    return Container(
      height: ResponsiveUtils.getChartHeight(context),
      padding: ResponsiveUtils.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 13,
              tablet: 14,
              desktop: 15,
            ),
          ),
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

  // ==================== NEW SPENDING ANALYSIS CHARTS ====================

  Widget _buildCategorySpendingChart(DashboardProvider provider) {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    final data = provider.getCategorySpending(
      startDate: last30Days,
      endDate: now,
    );

    return CategorySpendingChart(
      data: data,
      period: 'Últimos 30 dias',
    );
  }

  Widget _buildHourlySpendingChart(DashboardProvider provider) {
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final data = provider.getHourlySpending(
      startDate: last7Days,
      endDate: now,
    );

    return HourlySpendingChart(
      data: data,
      period: 'Últimos 7 dias',
    );
  }

  Widget _buildDailyPatternChart(DashboardProvider provider) {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    final data = provider.getDailySpendingPattern(
      startDate: last30Days,
      endDate: now,
    );

    return DailySpendingPatternChart(
      data: data,
      period: 'Últimos 30 dias',
    );
  }

  Widget _buildValueRangeChart(DashboardProvider provider) {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    final data = provider.getValueRangeDistribution(
      startDate: last30Days,
      endDate: now,
    );

    return ValueRangeChart(
      data: data,
      period: 'Últimos 30 dias',
    );
  }
}
