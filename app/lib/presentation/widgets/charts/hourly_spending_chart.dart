import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';

/// Hourly Spending Chart Widget
/// Displays spending patterns by hour of day using a bar chart
/// Helps identify when most spending occurs
class HourlySpendingChart extends StatelessWidget {
  final List<HourlySpendingData> data;
  final String period; // e.g., "Últimos 7 dias", "Este mês"

  const HourlySpendingChart({
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

    // Find peak hour
    final peakHour = data.reduce((a, b) => a.amount > b.amount ? a : b);

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
              'Gastos por Horário',
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
            // Peak hour info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFFF59E0B),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pico de gastos: ${_formatHour(peakHour.hour)} (${currencyFormat.format(peakHour.amount)})',
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
                        final hour = data[group.x.toInt()].hour;
                        final amount = data[group.x.toInt()].amount;
                        final count = data[group.x.toInt()].transactionCount;
                        return BarTooltipItem(
                          '${_formatHour(hour)}\n${currencyFormat.format(amount)}\n$count transações',
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
                            // Show every 3 hours
                            if (data[index].hour % 3 == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${data[index].hour}h',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
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
                    final isPeak = entry.value.hour == peakHour.hour;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.amount,
                          color: isPeak
                              ? const Color(0xFFF59E0B)
                              : _getBarColor(entry.value.hour),
                          width: 8,
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
            // Time period indicators
            _buildTimePeriodIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPeriodIndicator('Manhã', const Color(0xFFFBD38D), '6h-12h'),
        _buildPeriodIndicator('Tarde', const Color(0xFFF59E0B), '12h-18h'),
        _buildPeriodIndicator('Noite', const Color(0xFF6B46C1), '18h-24h'),
        _buildPeriodIndicator('Madrugada', const Color(0xFF3B82F6), '0h-6h'),
      ],
    );
  }

  Widget _buildPeriodIndicator(String label, Color color, String hours) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          hours,
          style: TextStyle(
            fontSize: 8,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Color _getBarColor(int hour) {
    if (hour >= 6 && hour < 12) {
      return const Color(0xFFFBD38D); // Morning - yellow
    } else if (hour >= 12 && hour < 18) {
      return const Color(0xFFF59E0B); // Afternoon - orange
    } else if (hour >= 18 && hour < 24) {
      return const Color(0xFF6B46C1); // Evening - purple
    } else {
      return const Color(0xFF3B82F6); // Night - blue
    }
  }

  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
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
