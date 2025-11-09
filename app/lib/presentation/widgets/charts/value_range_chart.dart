import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';

/// Value Range Chart Widget
/// Displays distribution of transactions by value ranges
/// Helps identify spending patterns by transaction size
class ValueRangeChart extends StatelessWidget {
  final List<ValueRangeData> data;
  final String period; // e.g., "Últimos 30 dias"

  const ValueRangeChart({
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

    // Calculate total transactions
    final totalTransactions = data.fold(0, (sum, d) => sum + d.transactionCount);

    // Find most common range
    final mostCommonRange = data.reduce((a, b) =>
      a.transactionCount > b.transactionCount ? a : b
    );

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
              'Distribuição por Valor',
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
            // Most common range info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6B46C1).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: Color(0xFF6B46C1),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Faixa mais comum: ${mostCommonRange.range} (${mostCommonRange.transactionCount} transações)',
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
            // Horizontal bar chart
            SizedBox(
              height: data.length * 60.0,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final rangeData = data[index];
                  final percentage = (rangeData.transactionCount / totalTransactions) * 100;
                  final isMostCommon = rangeData.range == mostCommonRange.range;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rangeData.range,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${rangeData.transactionCount} (${percentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          children: [
                            // Background bar
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Filled bar
                            FractionallySizedBox(
                              widthFactor: percentage / 100,
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isMostCommon
                                        ? [const Color(0xFF6B46C1), const Color(0xFF8B5CF6)]
                                        : [const Color(0xFF3B82F6), const Color(0xFF5A67D8)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isMostCommon
                                              ? const Color(0xFF6B46C1)
                                              : const Color(0xFF3B82F6))
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    currencyFormat.format(rangeData.totalAmount),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Summary stats
            _buildSummaryStats(totalTransactions, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(int totalTransactions, NumberFormat format) {
    final totalAmount = data.fold(0.0, (sum, d) => sum + d.totalAmount);
    final averageTransaction = totalTransactions > 0 ? totalAmount / totalTransactions : 0.0;

    // Find highest value range
    final highestRange = data.reduce((a, b) => a.maxValue > b.maxValue ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.receipt_long,
              label: 'Total',
              value: '$totalTransactions',
              color: const Color(0xFF48BB78),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.1),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.attach_money,
              label: 'Média',
              value: format.format(averageTransaction),
              color: const Color(0xFF3B82F6),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.1),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.trending_up,
              label: 'Maior',
              value: format.format(highestRange.maxValue),
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
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
