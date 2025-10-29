import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../../presentation/providers/widget_data_provider.dart';

/// Serviço para gerenciar widgets da home screen Android
class HomeWidgetService {
  static const String _incomeExpenseWidgetName = 'IncomeExpenseWidgetV2';
  static const String _reserveEvolutionWidgetName = 'ReserveEvolutionWidgetV2';

  /// Inicializa o serviço de widgets
  static Future<void> initialize() async {
    try {
      // Registrar callback de clique
      HomeWidget.registerInteractivityCallback(backgroundCallback);

      debugPrint('HomeWidgetService: Inicializado com sucesso');
    } catch (e) {
      debugPrint('HomeWidgetService: Erro ao inicializar: $e');
    }
  }

  /// Inicializa atualizações periódicas em background
  ///
  /// NOTA: Removemos o WorkManager devido a conflitos de dependências.
  /// Os widgets são atualizados automaticamente pelo Android a cada 1 hora
  /// conforme configurado no XML (updatePeriodMillis="3600000")
  static Future<void> initializeBackgroundUpdates() async {
    debugPrint('HomeWidgetService: Background updates serão gerenciadas pelo Android');
    debugPrint('HomeWidgetService: Widgets atualizam automaticamente a cada 1 hora');
  }

  /// Atualiza o widget de Receitas/Despesas
  static Future<void> updateIncomeExpenseWidget(
    WidgetDataProvider widgetDataProvider,
  ) async {
    try {
      final data = widgetDataProvider.getIncomeExpenseWidgetData();

      // Salvar dados no widget
      await HomeWidget.saveWidgetData('widget_type', 'income_expense');
      await HomeWidget.saveWidgetData('months', jsonEncode(data['months']));
      await HomeWidget.saveWidgetData('income', jsonEncode(data['income']));
      await HomeWidget.saveWidgetData('expense', jsonEncode(data['expense']));
      await HomeWidget.saveWidgetData('last_update', data['lastUpdate']);

      // Atualizar widget
      await HomeWidget.updateWidget(
        name: _incomeExpenseWidgetName,
        androidName: _incomeExpenseWidgetName,
      );

      debugPrint('HomeWidgetService: Widget Receitas/Despesas atualizado');
    } catch (e) {
      debugPrint('HomeWidgetService: Erro ao atualizar widget Receitas/Despesas: $e');
    }
  }

  /// Atualiza o widget de Evolução da Reserva
  static Future<void> updateReserveEvolutionWidget(
    WidgetDataProvider widgetDataProvider,
  ) async {
    try {
      final data = widgetDataProvider.getReserveEvolutionWidgetData();

      debugPrint('HomeWidgetService: Dados de Reserve Evolution:');
      debugPrint('  - months: ${data['months']}');
      debugPrint('  - reserve: ${data['reserve']}');
      debugPrint('  - currentReserve: ${data['currentReserve']}');
      debugPrint('  - lastUpdate: ${data['lastUpdate']}');

      // Salvar dados no widget
      await HomeWidget.saveWidgetData('widget_type', 'reserve_evolution');
      await HomeWidget.saveWidgetData('months', jsonEncode(data['months']));
      await HomeWidget.saveWidgetData('reserve', jsonEncode(data['reserve']));
      await HomeWidget.saveWidgetData('current_reserve', data['currentReserve']);
      await HomeWidget.saveWidgetData('last_update', data['lastUpdate']);

      // Atualizar widget
      await HomeWidget.updateWidget(
        name: _reserveEvolutionWidgetName,
        androidName: _reserveEvolutionWidgetName,
      );

      debugPrint('HomeWidgetService: Widget Evolução da Reserva atualizado');
    } catch (e) {
      debugPrint('HomeWidgetService: Erro ao atualizar widget Evolução da Reserva: $e');
    }
  }

  /// Atualiza todos os widgets
  static Future<void> updateAllWidgets(
    WidgetDataProvider widgetDataProvider,
  ) async {
    await updateIncomeExpenseWidget(widgetDataProvider);
    await updateReserveEvolutionWidget(widgetDataProvider);
    debugPrint('HomeWidgetService: Todos os widgets atualizados');
  }

  /// Callback quando o usuário toca no widget
  @pragma('vm:entry-point')
  static Future<void> backgroundCallback(Uri? uri) async {
    try {
      debugPrint('HomeWidgetService: Widget clicado - URI: $uri');

      // Aqui você pode navegar para uma tela específica
      // baseado na URI ou realizar outras ações

      if (uri != null) {
        if (uri.host == 'income_expense') {
          // Navegar para tela de transações
          await HomeWidget.saveWidgetData('open_screen', 'transactions');
        } else if (uri.host == 'reserve_evolution') {
          // Navegar para tela de metas
          await HomeWidget.saveWidgetData('open_screen', 'goals');
        }
      }
    } catch (e) {
      debugPrint('HomeWidgetService: Erro no backgroundCallback: $e');
    }
  }
}
