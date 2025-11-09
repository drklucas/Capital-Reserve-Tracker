import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';

/// Daily Spending Pattern Chart Widget
/// Displays spending patterns by day of week
/// Helps identify which days of the week have more spending
class DailySpendingPatternChart extends StatelessWidget {
  final List<DailySpendingPatternData> data;
  final String period; // e.g., "Últimos 30 dias"

  const DailySpendingPatternChart({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 0,
    );

    if (data.isEmpty) {
      return _buildEmptyState();
    }

    // Find max amount for scaling
    final maxAmount = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    // Find peak day
    final peakDay = data.reduce((a, b) => a.amount > b.amount ? a : b);

    // Calculate weekend vs weekday
    final weekdayAmount = data
        .where((d) => d.dayOfWeek >= 1 && d.dayOfWeek <= 5)
        .fold(0.0, (sum, d) => sum + d.amount);
    final weekendAmount = data
        .where((d) => d.dayOfWeek == 6 || d.dayOfWeek == 7)
        .fold(0.0, (sum, d) => sum + d.amount);

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Padrão de Gastos por Dia',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              period,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            // Peak day info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF48BB78).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF48BB78).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF48BB78),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dia com mais gastos: ${_getDayName(peakDay.dayOfWeek)} (${currencyFormat.format(peakDay.amount)})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => const Color(0xFF2d3561),
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dayData = data[group.x.toInt()];
                        return BarTooltipItem(
                          '${_getDayName(dayData.dayOfWeek)}\n${currencyFormat.format(dayData.amount)}\n${dayData.transactionCount} transações',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getDayAbbreviation(data[index].dayOfWeek),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
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
                    final isPeak = entry.value.dayOfWeek == peakDay.dayOfWeek;
                    final isWeekend = entry.value.dayOfWeek == 6 || entry.value.dayOfWeek == 7;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.amount,
                          color: isPeak
                              ? const Color(0xFF48BB78)
                              : isWeekend
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFF3B82F6),
                          width: 16,
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
            const SizedBox(height: 16),
            // Weekend vs Weekday comparison
            _buildWeekendComparison(weekdayAmount, weekendAmount, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekendComparison(
    double weekdayAmount,
    double weekendAmount,
    NumberFormat format,
  ) {
    final totalAmount = weekdayAmount + weekendAmount;
    final weekdayPercentage = totalAmount > 0 ? (weekdayAmount / totalAmount) * 100 : 0.0;
    final weekendPercentage = totalAmount > 0 ? (weekendAmount / totalAmount) * 100 : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                'Dias Úteis',
                const Color(0xFF3B82F6),
                format.format(weekdayAmount),
                weekdayPercentage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonCard(
                'Fim de Semana',
                const Color(0xFF8B5CF6),
                format.format(weekendAmount),
                weekendPercentage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard(String label, Color color, String amount, double percentage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}% do total',
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  String _getDayAbbreviation(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Seg';
      case 2:
        return 'Ter';
      case 3:
        return 'Qua';
      case 4:
        return 'Qui';
      case 5:
        return 'Sex';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }

  Widget _buildEmptyState() {
    return Container(
      height: 350,
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
          'Nenhum dado disponível',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
