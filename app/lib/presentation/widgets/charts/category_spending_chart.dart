import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../providers/dashboard_provider.dart';

/// Category Spending Chart Widget
/// Displays spending distribution across categories using a pie chart
class CategorySpendingChart extends StatefulWidget {
  final List<CategorySpendingData> data;
  final String period; // e.g., "Últimos 7 dias", "Este mês"

  const CategorySpendingChart({
    Key? key,
    required this.data,
    required this.period,
  }) : super(key: key);

  @override
  State<CategorySpendingChart> createState() => _CategorySpendingChartState();
}

class _CategorySpendingChartState extends State<CategorySpendingChart> {
  int touchedIndex = -1;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    // Take top 5 categories, group rest as "Outros"
    final topCategories = widget.data.take(5).toList();
    final hasOthers = widget.data.length > 5;

    double othersAmount = 0.0;
    int othersCount = 0;
    if (hasOthers) {
      for (var i = 5; i < widget.data.length; i++) {
        othersAmount += widget.data[i].amount;
        othersCount += widget.data[i].transactionCount;
      }
    }

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
            color: Colors.black.withValues(alpha: 0.3),
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
              'Gastos por Categoria',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.period,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 1,
                        centerSpaceRadius: 60,
                        sections: _getSections(topCategories, othersAmount, othersCount, hasOthers),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  flex: 2,
                  child: _buildLegend(topCategories, othersAmount, hasOthers),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections(
    List<CategorySpendingData> topCategories,
    double othersAmount,
    int othersCount,
    bool hasOthers,
  ) {
    final sections = <PieChartSectionData>[];

    for (int i = 0; i < topCategories.length; i++) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 50.0 : 45.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      sections.add(
        PieChartSectionData(
          color: _getCategoryColor(topCategories[i].category, i),
          value: topCategories[i].amount,
          title: '${topCategories[i].percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Add "Outros" section if needed
    if (hasOthers) {
      final totalAmount = widget.data.fold(0.0, (sum, d) => sum + d.amount);
      final othersPercentage = (othersAmount / totalAmount) * 100;
      final isTouched = topCategories.length == touchedIndex;
      final radius = isTouched ? 50.0 : 45.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      sections.add(
        PieChartSectionData(
          color: Colors.grey.shade600,
          value: othersAmount,
          title: '${othersPercentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend(
    List<CategorySpendingData> topCategories,
    double othersAmount,
    bool hasOthers,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...topCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLegendItem(
                color: _getCategoryColor(data.category, index),
                label: data.category.displayName,
                value: _currencyFormat.format(data.amount),
                count: data.transactionCount,
              ),
            );
          }),
          if (hasOthers)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLegendItem(
                color: Colors.grey.shade600,
                label: 'Outros',
                value: _currencyFormat.format(othersAmount),
                count: null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
    required int? count,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (count != null)
                Text(
                  '$count transações',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(TransactionCategory category, int index) {
    // Modern vibrant gradient-inspired colors
    final colors = [
      const Color(0xFFFF6B9D), // Vibrant Pink
      const Color(0xFF4ECDC4), // Turquoise
      const Color(0xFFFFA07A), // Light Coral
      const Color(0xFF95E1D3), // Mint Green
      const Color(0xFFFFD93D), // Golden Yellow
      const Color(0xFFC98BDB), // Lavender
      const Color(0xFF6BCB77), // Fresh Green
      const Color(0xFFFF8787), // Soft Red
    ];

    return colors[index % colors.length];
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
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Nenhum gasto registrado',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
