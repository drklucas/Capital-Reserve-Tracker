import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/widget_data_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../services/home_widget_service.dart';

/// Utilitário para atualizar widgets da home screen
class WidgetUpdater {
  /// Atualiza os dados dos widgets e os widgets nativos
  static Future<void> updateWidgets(BuildContext context) async {
    try {
      final authProvider = context.read<AppAuthProvider>();
      final widgetDataProvider = context.read<WidgetDataProvider>();

      // Verificar se usuário está autenticado
      if (authProvider.user == null) {
        debugPrint('WidgetUpdater: Usuário não autenticado');
        return;
      }

      final userId = authProvider.user!.id;

      // Atualizar dados
      await widgetDataProvider.updateWidgetData(userId);

      // Atualizar widgets nativos
      if (!widgetDataProvider.isLoading && widgetDataProvider.error == null) {
        await HomeWidgetService.updateAllWidgets(widgetDataProvider);
        debugPrint('WidgetUpdater: Widgets atualizados com sucesso');
      } else {
        debugPrint('WidgetUpdater: Erro ao atualizar dados: ${widgetDataProvider.error}');
      }
    } catch (e) {
      debugPrint('WidgetUpdater: Erro ao atualizar widgets: $e');
    }
  }

  /// Atualiza widgets ao iniciar o app
  static Future<void> updateWidgetsOnAppStart(BuildContext context) async {
    // Aguardar um pouco para garantir que os providers estão prontos
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      await updateWidgets(context);
    }
  }

  /// Atualiza widgets quando há mudanças significativas
  static Future<void> updateWidgetsAfterTransaction(BuildContext context) async {
    // Pequeno delay para garantir que Firestore atualizou
    await Future.delayed(const Duration(milliseconds: 500));
    if (context.mounted) {
      await updateWidgets(context);
    }
  }

  /// Mostra snackbar de sucesso/erro
  static void showUpdateStatus(BuildContext context, bool success, {String? error}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
            ? 'Widgets atualizados com sucesso!'
            : 'Erro ao atualizar widgets: ${error ?? "Desconhecido"}',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
