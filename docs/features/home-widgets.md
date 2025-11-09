# Widgets da Home Screen Android

## Visão Geral

O Capital Reserve Tracker oferece **2 widgets nativos** para a home screen do Android que permitem visualizar suas estatísticas financeiras sem abrir o aplicativo:

1. **Widget de Receitas e Despesas** - Gráfico de barras dos últimos 6 meses
2. **Widget de Evolução da Reserva** - Gráfico de linha mostrando o crescimento da reserva

## Recursos dos Widgets

### Widget de Receitas e Despesas

**Características:**
- Gráfico de barras duplas (receitas em verde, despesas em vermelho)
- Mostra os últimos 6 meses de dados
- Labels com nomes dos meses em português
- Legenda de cores
- Data da última atualização
- Tamanho: 4x2 células (320dp x 180dp)
- Atualização automática a cada 1 hora

**Dados Exibidos:**
- Receitas mensais totalizadas
- Despesas mensais totalizadas
- Comparação visual mês a mês

### Widget de Evolução da Reserva

**Características:**
- Valor atual da reserva em destaque
- Gráfico de evolução dos últimos 6 meses
- Cálculo de crescimento percentual
- Média mensal de crescimento
- Labels dos meses
- Data da última atualização
- Tamanho: 4x3 células (320dp x 200dp)
- Atualização automática a cada 1 hora

**Dados Exibidos:**
- Reserva atual total (soma de todas as metas ativas)
- Linha de evolução da reserva ao longo do tempo
- % de crescimento desde o primeiro mês
- Média mensal de crescimento/economia

## Como Adicionar os Widgets

### Passo 1: Abrir a Tela de Widgets
1. Pressione e segure em um espaço vazio na sua home screen
2. Toque em "Widgets" ou arraste de baixo para cima
3. Procure por "Capital Reserve Tracker" ou "MyGoals"

### Passo 2: Selecionar o Widget
1. Você verá dois widgets disponíveis:
   - **Receitas & Despesas** (4x2)
   - **Evolução da Reserva** (4x3)
2. Toque e segure o widget desejado
3. Arraste para a home screen

### Passo 3: Posicionar o Widget
1. Posicione o widget onde desejar
2. Solte o dedo para fixar
3. O widget será atualizado automaticamente com seus dados

## Como Atualizar os Widgets

### Atualização Automática

Os widgets são atualizados automaticamente:
- **A cada 1 hora** (quando o dispositivo está desbloqueado)
- **A cada 4 horas** em segundo plano (via WorkManager)
- **Ao abrir o aplicativo** (atualização manual via código)

### Atualização Manual

Para forçar uma atualização imediata:
1. Abra o aplicativo Capital Reserve Tracker
2. Navegue até a tela principal
3. Os widgets serão atualizados automaticamente após 2 segundos
4. Você pode adicionar transações ou metas - os widgets atualizarão após 500ms

### Atualização via Código

Os desenvolvedores podem forçar atualização usando:

```dart
import 'package:provider/provider.dart';
import 'core/utils/widget_updater.dart';

// Em qualquer tela
await WidgetUpdater.updateWidgets(context);

// Ou após uma transação
await WidgetUpdater.updateWidgetsAfterTransaction(context);
```

## Arquitetura dos Widgets

### Fluxo de Dados

```
Flutter App (Dart)
    ↓
WidgetDataProvider
    ↓ (calcula dados dos últimos 6 meses)
HomeWidgetService
    ↓ (salva no SharedPreferences)
Android SharedPreferences
    ↓ (lê os dados)
Widget Provider (Kotlin)
    ↓ (renderiza)
Home Screen Widget
```

### Componentes Criados

#### Flutter (Dart)
1. **WidgetDataProvider** (`lib/presentation/providers/widget_data_provider.dart`)
   - Busca transações dos últimos 6 meses
   - Calcula receitas, despesas e reserva por mês
   - Formata dados para JSON

2. **HomeWidgetService** (`lib/core/services/home_widget_service.dart`)
   - Inicializa o serviço de widgets
   - Salva dados no SharedPreferences
   - Atualiza widgets nativos
   - Configura atualizações periódicas

3. **WidgetUpdater** (`lib/core/utils/widget_updater.dart`)
   - Utilitário para facilitar atualização
   - Métodos convenientes para diferentes cenários

#### Android (Kotlin)
1. **IncomeExpenseWidget** (`android/.../IncomeExpenseWidget.kt`)
   - Provider do widget de receitas/despesas
   - Lê dados do SharedPreferences
   - Renderiza barras com alturas proporcionais

2. **ReserveEvolutionWidget** (`android/.../ReserveEvolutionWidget.kt`)
   - Provider do widget de evolução
   - Calcula estatísticas (crescimento, média)
   - Formata valores em Real (R$)

#### XML Layouts
1. **income_expense_widget.xml** - Layout do widget de barras
2. **reserve_evolution_widget.xml** - Layout do widget de linha
3. **widget_background.xml** - Background escuro dos widgets
4. **current_value_background.xml** - Background do card de valor

## Personalização

### Cores dos Widgets

Os widgets usam o tema escuro do app:
- **Background**: `#1a1a2e` (azul escuro)
- **Receitas**: `#4CAF50` (verde)
- **Despesas**: `#F44336` (vermelho)
- **Reserva**: `#4CAF50` (verde)
- **Texto**: `#FFFFFF` (branco)
- **Texto secundário**: `#B0B0B0` (cinza claro)

Para alterar as cores, edite:
```xml
<!-- android/.../res/drawable/widget_background.xml -->
<solid android:color="#1a1a2e" />

<!-- Ou diretamente nos layouts -->
<View android:background="#4CAF50" />
```

### Tamanhos dos Widgets

Para alterar o tamanho mínimo:
```xml
<!-- android/.../res/xml/income_expense_widget_info.xml -->
<appwidget-provider
    android:minWidth="320dp"
    android:minHeight="180dp"
    android:targetCellWidth="4"
    android:targetCellHeight="2"
    ...
/>
```

### Frequência de Atualização

Para mudar a frequência de atualização automática:
```xml
<!-- Em *_widget_info.xml -->
android:updatePeriodMillis="3600000"  <!-- 1 hora = 3600000ms -->
```

Para atualização em segundo plano:
```dart
// Em home_widget_service.dart
await Workmanager().registerPeriodicTask(
  _updateTaskName,
  _updateTaskName,
  frequency: const Duration(hours: 4), // Mudar aqui
);
```

## Solução de Problemas

### Widget Não Aparece

**Problema**: Widget não aparece na lista de widgets disponíveis

**Solução**:
1. Verifique se o app foi compilado corretamente
2. Reinstale o aplicativo
3. Reinicie o dispositivo
4. Verifique logs: `adb logcat | grep Widget`

### Widget Não Atualiza

**Problema**: Widget mostra dados desatualizados

**Solução**:
1. Abra o aplicativo (força atualização)
2. Remova e adicione o widget novamente
3. Verifique se há conexão com internet
4. Verifique logs do WorkManager

### Widget Mostra Erro

**Problema**: Widget exibe "Erro ao carregar dados"

**Solução**:
1. Verifique se usuário está logado no app
2. Certifique-se de que há dados de transações
3. Verifique permissões de acesso ao Firebase
4. Veja logs: `adb logcat | grep WidgetUpdater`

### Dados Incorretos

**Problema**: Widget mostra valores errados

**Solução**:
1. Force atualização abrindo o app
2. Verifique se as transações estão corretas no Firebase
3. Limpe cache do app: Configurações → Apps → Capital Reserve Tracker → Limpar cache
4. Recompile o app em modo debug e verifique logs

## Logs e Debug

### Habilitar Logs Detalhados

Os widgets já incluem logs extensivos:

```dart
// Flutter
debugPrint('WidgetUpdater: ...');
debugPrint('HomeWidgetService: ...');

// Android Kotlin
e.printStackTrace()
```

### Ver Logs no Android Studio / Terminal

```bash
# Todos os logs dos widgets
adb logcat | grep -E "Widget|HomeWidget|WidgetUpdater"

# Apenas erros
adb logcat | grep -E "Widget.*Error"

# WorkManager
adb logcat | grep WorkManager
```

## Limitações Conhecidas

1. **Gráfico de Linha Simples**: O widget de evolução não desenha uma linha conectando os pontos (limitação do RemoteViews do Android)
2. **Sem Interatividade**: Clicar no widget abre o app, mas não navega para telas específicas ainda
3. **Atualização em Background**: Android pode limitar atualizações em segundo plano para economizar bateria
4. **Apenas Android**: Widgets nativos não estão disponíveis para iOS, Web ou Desktop

## Roadmap Futuro

### Melhorias Planejadas
- [ ] Adicionar gráfico de linha real no widget de evolução
- [ ] Suporte para clique em áreas específicas (navegar para transações/metas)
- [ ] Widget de tarefas pendentes
- [ ] Widget de meta específica selecionável
- [ ] Configuração de período (3, 6 ou 12 meses)
- [ ] Tema claro/escuro configurável
- [ ] Widget compacto 2x1 com resumo rápido

## Referências Técnicas

### Documentação Oficial
- [home_widget package](https://pub.dev/packages/home_widget)
- [Android App Widgets](https://developer.android.com/develop/ui/views/appwidgets)
- [WorkManager](https://developer.android.com/topic/libraries/architecture/workmanager)

### Arquivos do Projeto
- Flutter Provider: `lib/presentation/providers/widget_data_provider.dart`
- Serviço de Widget: `lib/core/services/home_widget_service.dart`
- Widget Kotlin (Receitas): `android/app/src/main/kotlin/.../IncomeExpenseWidget.kt`
- Widget Kotlin (Reserva): `android/app/src/main/kotlin/.../ReserveEvolutionWidget.kt`
- Layouts XML: `android/app/src/main/res/layout/`
- Configurações: `android/app/src/main/res/xml/`

## Contribuindo

Para adicionar novos widgets ou melhorar os existentes:

1. **Criar Provider Flutter**: Adicionar lógica de cálculo de dados
2. **Criar Layout XML**: Definir interface do widget
3. **Criar Provider Kotlin**: Implementar renderização
4. **Registrar no Manifest**: Adicionar receiver no AndroidManifest.xml
5. **Testar**: Verificar em diferentes tamanhos de tela e versões do Android
6. **Documentar**: Atualizar esta documentação

---

**Última Atualização**: Outubro 2025
**Versão do App**: 1.0.0
**Versão Mínima do Android**: Android 6.0 (API 23)
