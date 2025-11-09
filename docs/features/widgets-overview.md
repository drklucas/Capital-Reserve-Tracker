# 📊 Widgets da Home Screen - Guia Rápido

## ✅ Widgets Implementados

### 1. Widget de Receitas e Despesas (4x2)
- Gráfico de barras dos últimos 6 meses
- Receitas (verde) vs Despesas (vermelho)
- Atualização automática a cada hora

### 2. Widget de Evolução da Reserva (4x3)
- Valor atual da reserva em destaque
- Evolução dos últimos 6 meses
- Crescimento % e média mensal

## 🚀 Como Usar

### Para Usuários

1. **Adicionar Widget**:
   - Pressione e segure na home screen
   - Toque em "Widgets"
   - Procure "Capital Reserve Tracker"
   - Arraste o widget desejado para a home

2. **Atualizar Dados**:
   - Abra o app (atualiza automaticamente)
   - Aguarde ~2 segundos
   - Widgets sincronizam com Firebase

### Para Desenvolvedores

```dart
// Forçar atualização manual
import 'core/utils/widget_updater.dart';

await WidgetUpdater.updateWidgets(context);

// Atualizar após transação
await WidgetUpdater.updateWidgetsAfterTransaction(context);
```

## 📁 Arquivos Criados

### Flutter (Dart)
- `lib/presentation/providers/widget_data_provider.dart` - Gerencia dados
- `lib/core/services/home_widget_service.dart` - Serviço de widgets
- `lib/core/utils/widget_updater.dart` - Utilitário de atualização

### Android (Kotlin)
- `android/app/src/main/kotlin/com/example/app/IncomeExpenseWidget.kt`
- `android/app/src/main/kotlin/com/example/app/ReserveEvolutionWidget.kt`

### Android (XML)
- `android/app/src/main/res/layout/income_expense_widget.xml`
- `android/app/src/main/res/layout/reserve_evolution_widget.xml`
- `android/app/src/main/res/drawable/widget_background.xml`
- `android/app/src/main/res/drawable/current_value_background.xml`
- `android/app/src/main/res/xml/income_expense_widget_info.xml`
- `android/app/src/main/res/xml/reserve_evolution_widget_info.xml`
- `android/app/src/main/res/values/strings.xml`

### Configuração
- `android/app/src/main/AndroidManifest.xml` - Receivers registrados
- `app/pubspec.yaml` - Dependências: `home_widget: ^0.6.0`, `workmanager: ^0.5.2`

## 🔧 Configuração Necessária

### Dependências Adicionadas
```yaml
dependencies:
  home_widget: ^0.6.0
  workmanager: ^0.5.2
```

### Integração no main.dart
```dart
// Inicialização
await HomeWidgetService.initialize();

// Provider
ChangeNotifierProvider<WidgetDataProvider>(
  create: (_) => WidgetDataProvider(
    getTransactionsUseCase: getTransactionsUseCase,
    getGoalsUseCase: getGoalsUseCase,
  ),
),
```

## 🎨 Customização

### Cores
Edite: `android/app/src/main/res/drawable/widget_background.xml`
```xml
<solid android:color="#1a1a2e" /> <!-- Background -->
```

Nos layouts:
- Verde (Receitas/Reserva): `#4CAF50`
- Vermelho (Despesas): `#F44336`

### Frequência de Atualização
Edite: `android/app/src/main/res/xml/*_widget_info.xml`
```xml
android:updatePeriodMillis="3600000" <!-- 1 hora -->
```

Background: `lib/core/services/home_widget_service.dart`
```dart
frequency: const Duration(hours: 4)
```

## 🐛 Debug

### Ver Logs
```bash
# Logs dos widgets
adb logcat | grep -E "Widget|HomeWidget|WidgetUpdater"

# Erros
adb logcat | grep -E "Widget.*Error"
```

### Problemas Comuns

**Widget não aparece:**
- Recompile: `flutter clean && flutter build apk`
- Reinstale o app
- Reinicie o dispositivo

**Dados não atualizam:**
- Abra o app para forçar atualização
- Verifique conexão com internet
- Remova e adicione o widget novamente

**Erro ao carregar:**
- Certifique-se de estar logado
- Verifique se há transações/metas no Firebase
- Veja logs: `adb logcat | grep WidgetUpdater`

## 📖 Documentação Completa

Consulte: [`docs/home-widgets.md`](docs/home-widgets.md)

## 🏗️ Arquitetura

```
Flutter App
    ↓
WidgetDataProvider (calcula últimos 6 meses)
    ↓
HomeWidgetService (salva SharedPreferences)
    ↓
Android SharedPreferences
    ↓
Kotlin Widget Provider (lê e renderiza)
    ↓
Home Screen Widget
```

## ✨ Features

- ✅ 2 widgets nativos Android
- ✅ Gráficos de barras (receitas/despesas)
- ✅ Evolução da reserva
- ✅ Últimos 6 meses de dados
- ✅ Atualização automática (1h + 4h background)
- ✅ Tema escuro
- ✅ Formatação monetária (R$)
- ✅ Labels em português
- ✅ Timestamps de atualização

## 🔮 Próximos Passos

- [ ] Gráfico de linha real (atualmente simulado com pontos)
- [ ] Navegação para telas específicas ao clicar
- [ ] Widget de tarefas pendentes
- [ ] Configuração de período (3/6/12 meses)
- [ ] Tema claro/escuro configurável
- [ ] Widget compacto 2x1

## 📝 Notas Importantes

1. **Apenas Android**: Widgets nativos não funcionam em iOS/Web/Desktop
2. **Requer autenticação**: Usuário deve estar logado
3. **Requer dados**: Necessita transações no Firebase
4. **Battery Optimization**: Android pode limitar atualizações em background
5. **Versão mínima**: Android 6.0 (API 23)

## 🚀 Build e Deploy

```bash
# Instalar dependências
cd app/
flutter pub get

# Build APK
flutter build apk

# Instalar no dispositivo
flutter install
```

## 📞 Suporte

Para problemas ou dúvidas:
1. Consulte logs: `adb logcat | grep Widget`
2. Veja documentação completa: `docs/home-widgets.md`
3. Abra issue no GitHub com logs e screenshots

---

**Implementado em**: Outubro 2025
**Testado em**: Android 11+
**Status**: ✅ Funcional e pronto para uso
