import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/transaction/get_transactions_usecase.dart';
import '../../domain/usecases/goal/get_goals_usecase.dart';
import '../../domain/entities/goal_entity.dart';

/// Dados mensais para os widgets
class MonthlyData {
  final String month; // "Jan", "Fev", etc.
  final double income;
  final double expense;
  final double reserve;

  MonthlyData({
    required this.month,
    required this.income,
    required this.expense,
    required this.reserve,
  });

  Map<String, dynamic> toJson() => {
        'month': month,
        'income': income,
        'expense': expense,
        'reserve': reserve,
      };

  factory MonthlyData.fromJson(Map<String, dynamic> json) => MonthlyData(
        month: json['month'] as String,
        income: (json['income'] as num).toDouble(),
        expense: (json['expense'] as num).toDouble(),
        reserve: (json['reserve'] as num).toDouble(),
      );
}

/// Provider para gerenciar dados dos widgets da home screen
class WidgetDataProvider extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final GetGoalsUseCase _getGoalsUseCase;

  List<MonthlyData> _last6MonthsData = [];
  bool _isLoading = false;
  String? _error;
  DateTime _lastUpdate = DateTime.now();

  WidgetDataProvider({
    required GetTransactionsUseCase getTransactionsUseCase,
    required GetGoalsUseCase getGoalsUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase,
        _getGoalsUseCase = getGoalsUseCase;

  // Getters
  List<MonthlyData> get last6MonthsData => _last6MonthsData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get lastUpdate => _lastUpdate;

  /// Atualiza os dados dos widgets
  Future<void> updateWidgetData(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Buscar transações dos últimos 6 meses
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

      final transactionsResult = await _getTransactionsUseCase(
        userId: userId,
        startDate: sixMonthsAgo,
        endDate: now,
      );

      await transactionsResult.fold(
        (failure) {
          _error = failure.message;
          _isLoading = false;
          notifyListeners();
        },
        (transactions) async {
          // Calcular dados mensais
          _last6MonthsData = _calculateMonthlyData(transactions, sixMonthsAgo);

          // Buscar metas para calcular reserva total
          final goalsResult = await _getGoalsUseCase(userId);

          goalsResult.fold(
            (failure) {
              debugPrint('Erro ao buscar metas: ${failure.message}');
            },
            (goals) {
              // Calcular reserva total (soma de currentAmount das metas ativas)
              final totalReserve = goals
                  .where((goal) => goal.status == GoalStatus.active)
                  .fold(0.0, (sum, goal) => sum + goal.currentAmount);

              // Atualizar reserva no último mês
              if (_last6MonthsData.isNotEmpty) {
                final lastMonth = _last6MonthsData.last;
                _last6MonthsData[_last6MonthsData.length - 1] = MonthlyData(
                  month: lastMonth.month,
                  income: lastMonth.income,
                  expense: lastMonth.expense,
                  reserve: totalReserve,
                );
              }
            },
          );

          _lastUpdate = DateTime.now();
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erro ao atualizar dados: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calcula dados mensais a partir das transações
  List<MonthlyData> _calculateMonthlyData(
    List<TransactionEntity> transactions,
    DateTime startDate,
  ) {
    final monthlyData = <String, MonthlyData>{};
    final dateFormat = DateFormat('MMM', 'pt_BR');

    // Inicializar os últimos 6 meses
    final now = DateTime.now();
    double cumulativeReserve = 0.0;

    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('yyyy-MM').format(monthDate);
      final monthLabel = dateFormat.format(monthDate);

      monthlyData[monthKey] = MonthlyData(
        month: _capitalizeFirst(monthLabel),
        income: 0.0,
        expense: 0.0,
        reserve: 0.0,
      );
    }

    // Agrupar transações por mês
    for (final transaction in transactions) {
      final monthKey = DateFormat('yyyy-MM').format(transaction.date);

      if (monthlyData.containsKey(monthKey)) {
        final current = monthlyData[monthKey]!;

        if (transaction.isIncome) {
          monthlyData[monthKey] = MonthlyData(
            month: current.month,
            income: current.income + transaction.amount,
            expense: current.expense,
            reserve: current.reserve,
          );
        } else {
          monthlyData[monthKey] = MonthlyData(
            month: current.month,
            income: current.income,
            expense: current.expense + transaction.amount,
            reserve: current.reserve,
          );
        }
      }
    }

    // Calcular reserva acumulativa
    final sortedKeys = monthlyData.keys.toList()..sort();
    for (final key in sortedKeys) {
      final data = monthlyData[key]!;
      cumulativeReserve += data.income - data.expense;

      monthlyData[key] = MonthlyData(
        month: data.month,
        income: data.income,
        expense: data.expense,
        reserve: cumulativeReserve,
      );
    }

    return sortedKeys.map((key) => monthlyData[key]!).toList();
  }

  /// Capitaliza primeira letra
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Converte dados para JSON (para enviar ao widget nativo)
  Map<String, dynamic> toJson() {
    return {
      'last6MonthsData': _last6MonthsData.map((e) => e.toJson()).toList(),
      'lastUpdate': _lastUpdate.toIso8601String(),
    };
  }

  /// Obtém dados formatados para o widget de Receitas/Despesas
  Map<String, dynamic> getIncomeExpenseWidgetData() {
    if (_last6MonthsData.isEmpty) {
      return {
        'months': [],
        'income': [],
        'expense': [],
        'lastUpdate': _lastUpdate.toIso8601String(),
      };
    }

    return {
      'months': _last6MonthsData.map((e) => e.month).toList(),
      'income': _last6MonthsData.map((e) => e.income).toList(),
      'expense': _last6MonthsData.map((e) => e.expense).toList(),
      'lastUpdate': _lastUpdate.toIso8601String(),
    };
  }

  /// Obtém dados formatados para o widget de Evolução da Reserva
  Map<String, dynamic> getReserveEvolutionWidgetData() {
    if (_last6MonthsData.isEmpty) {
      return {
        'months': [],
        'reserve': [],
        'currentReserve': 0.0,
        'lastUpdate': _lastUpdate.toIso8601String(),
      };
    }

    final currentReserve = _last6MonthsData.isNotEmpty
        ? _last6MonthsData.last.reserve
        : 0.0;

    return {
      'months': _last6MonthsData.map((e) => e.month).toList(),
      'reserve': _last6MonthsData.map((e) => e.reserve).toList(),
      'currentReserve': currentReserve,
      'lastUpdate': _lastUpdate.toIso8601String(),
    };
  }
}
