# Troubleshooting - Widgets Android

## Problema: "Não foi possível adicionar widget"

### Sintoma
Ao tentar adicionar o widget na home screen, aparece a mensagem "Não foi possível adicionar widget" ou o widget simplesmente não aparece na lista.

### Causas Comuns

#### 1. APK Não Atualizado
**Solução**:
```bash
cd app/
flutter clean
flutter build apk --debug
flutter install
```

Após instalar, **reinicie o dispositivo** para garantir que o Android reconheça os novos widgets.

#### 2. Cache do Android
**Solução**:
1. Desinstale o aplicativo completamente
2. Reinicie o dispositivo
3. Reinstale o APK
4. Tente adicionar o widget novamente

#### 3. Permissões Incorretas
**Verificar**:
- Os receivers no `AndroidManifest.xml` devem ter `android:exported="true"`
- Os arquivos XML em `res/xml/` devem existir
- Os layouts em `res/layout/` devem existir

**Exemplo correto no AndroidManifest.xml**:
```xml
<receiver
    android:name="com.example.app.IncomeExpenseWidget"
    android:exported="true"
    android:label="Receitas e Despesas">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/income_expense_widget_info" />
</receiver>
```

#### 4. Configuração XML Inválida
**Verificar**:
- `android:minWidth` e `android:minHeight` devem ser válidos (ex: 250dp)
- Remover atributos não suportados em versões antigas do Android
- `android:updatePeriodMillis` mínimo é 1800000 (30 min) ou 0

**Exemplo correto**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="180dp"
    android:updatePeriodMillis="3600000"
    android:initialLayout="@layout/income_expense_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:description="@string/income_expense_widget_description"
    android:previewImage="@mipmap/ic_launcher" />
```

**EVITAR** (pode causar erros em versões antigas):
```xml
android:targetCellWidth="4"
android:targetCellHeight="2"
android:previewLayout="@layout/income_expense_widget"
```

#### 5. Nome do Pacote Incorreto
**Verificar**:
- O caminho completo da classe deve estar correto
- Use `com.example.app.IncomeExpenseWidget` e não `.IncomeExpenseWidget`

#### 6. Recursos Faltando
**Verificar**:
```bash
# Verificar se todos os arquivos existem
ls android/app/src/main/res/layout/income_expense_widget.xml
ls android/app/src/main/res/layout/reserve_evolution_widget.xml
ls android/app/src/main/res/xml/income_expense_widget_info.xml
ls android/app/src/main/res/xml/reserve_evolution_widget_info.xml
ls android/app/src/main/res/drawable/widget_background.xml
ls android/app/src/main/res/values/strings.xml
```

**strings.xml deve conter**:
```xml
<string name="income_expense_widget_description">Gráfico de receitas e despesas dos últimos 6 meses</string>
<string name="reserve_evolution_widget_description">Evolução da reserva financeira ao longo do tempo</string>
```

## Problema: Widget Aparece Mas Não Mostra Dados

### Sintoma
O widget é adicionado com sucesso, mas mostra erro ou dados vazios.

### Soluções

#### 1. Dados Não Inicializados
```dart
// No código Flutter, force atualização ao iniciar
import 'core/utils/widget_updater.dart';

@override
void initState() {
  super.initState();
  Future.delayed(Duration(seconds: 2), () {
    if (mounted) {
      WidgetUpdater.updateWidgets(context);
    }
  });
}
```

#### 2. Usuário Não Logado
**Verificar**:
- O usuário deve estar autenticado
- O WidgetDataProvider precisa do userId
- Verificar logs: `adb logcat | grep WidgetUpdater`

#### 3. Sem Transações no Firebase
**Verificar**:
- O usuário deve ter pelo menos algumas transações cadastradas
- Verificar no Firebase Console se os dados existem

#### 4. Erro no SharedPreferences
**Debug**:
```bash
# Ver logs completos
adb logcat | grep -E "HomeWidget|IncomeExpenseWidget|ReserveEvolutionWidget"

# Ver especificamente erros
adb logcat *:E | grep Widget
```

## Problema: Widget Não Atualiza

### Sintoma
O widget mostra dados antigos ou não atualiza mesmo após mudanças.

### Soluções

#### 1. Forçar Atualização Manual
```bash
# Abrir o aplicativo
# Os widgets devem atualizar automaticamente após 2 segundos
```

#### 2. Remover e Adicionar Novamente
1. Pressione e segure o widget
2. Remova o widget
3. Adicione novamente

#### 3. Limpar Cache do App
```bash
# Via ADB
adb shell pm clear com.example.app

# Ou nas configurações do Android:
Configurações → Apps → Capital Reserve Tracker → Armazenamento → Limpar cache
```

#### 4. Verificar UpdatePeriodMillis
O Android só atualiza widgets automaticamente no mínimo a cada 30 minutos. Para forçar:
```xml
<!-- Em *_widget_info.xml -->
android:updatePeriodMillis="1800000"  <!-- 30 minutos -->
```

## Problema: Widget Com Layout Quebrado

### Sintoma
O widget aparece mas o layout está bagunçado ou elementos não aparecem.

### Soluções

#### 1. Verificar Recursos Drawable
```bash
# Verificar se existem
ls android/app/src/main/res/drawable/widget_background.xml
ls android/app/src/main/res/drawable/current_value_background.xml
```

#### 2. IDs Corretos nos Layouts
**Verificar** que todos os IDs no XML existem e são referenciados corretamente no Kotlin:
- `R.id.month_label_1` até `R.id.month_label_6`
- `R.id.bar_income_1` até `R.id.bar_income_6`
- `R.id.bar_expense_1` até `R.id.bar_expense_6`
- `R.id.last_update`
- `R.id.current_reserve_value`
- etc.

#### 3. Testar Layout Isoladamente
Use o Android Studio Layout Inspector para visualizar o widget.

## Comandos Úteis para Debug

### Verificar Se Widget Está Registrado
```bash
adb shell dumpsys activity widgets | grep IncomeExpenseWidget
adb shell dumpsys activity widgets | grep ReserveEvolutionWidget
```

### Ver Todos os Widgets Disponíveis
```bash
adb shell dumpsys activity widgets
```

### Logs em Tempo Real
```bash
# Ver todos os logs relevantes
adb logcat | grep -E "Widget|HomeWidget|WidgetUpdater|WidgetData"

# Apenas erros
adb logcat *:E | grep Widget

# Limpar e ver logs novos
adb logcat -c && adb logcat | grep Widget
```

### Forçar Atualização via ADB
```bash
# Enviar broadcast de atualização
adb shell am broadcast -a android.appwidget.action.APPWIDGET_UPDATE
```

### Reinstalar Aplicativo
```bash
cd app/
flutter clean
flutter build apk --debug
flutter install
# Reiniciar dispositivo
adb reboot
```

## Checklist de Verificação

Quando um widget não funciona, siga esta ordem:

- [ ] 1. Desinstalar app completamente
- [ ] 2. Executar `flutter clean`
- [ ] 3. Recompilar: `flutter build apk --debug`
- [ ] 4. Reinstalar no dispositivo
- [ ] 5. **Reiniciar o dispositivo** (importante!)
- [ ] 6. Tentar adicionar widget novamente
- [ ] 7. Abrir o app e fazer login
- [ ] 8. Adicionar pelo menos uma transação
- [ ] 9. Aguardar 2 segundos
- [ ] 10. Verificar se widget atualizou

## Configurações Testadas e Funcionando

### AndroidManifest.xml
```xml
<receiver
    android:name="com.example.app.IncomeExpenseWidget"
    android:exported="true"
    android:label="Receitas e Despesas">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/income_expense_widget_info" />
</receiver>
```

### Widget Info XML
```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="180dp"
    android:updatePeriodMillis="3600000"
    android:initialLayout="@layout/income_expense_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:description="@string/income_expense_widget_description"
    android:previewImage="@mipmap/ic_launcher" />
```

## Versões Testadas

- ✅ Android 11 (API 30)
- ✅ Android 12 (API 31)
- ✅ Android 13 (API 33)
- ⚠️ Android 6-10 (API 23-29) - Pode ter limitações

## Suporte

Se o problema persistir:
1. Capture logs: `adb logcat > widget_log.txt`
2. Tire screenshots do erro
3. Abra uma issue no GitHub com:
   - Versão do Android
   - Logs relevantes
   - Passos para reproduzir

## Referências

- [Android App Widgets](https://developer.android.com/develop/ui/views/appwidgets)
- [home_widget package](https://pub.dev/packages/home_widget)
- [RemoteViews API](https://developer.android.com/reference/android/widget/RemoteViews)
