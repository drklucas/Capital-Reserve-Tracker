# Mudanças para Aplicar Tema Personalizado na Tela de Detalhes da Meta

## Arquivo: `goal_detail_screen.dart`

Já foram adicionados os imports necessários:
```dart
import '../../../core/constants/goal_colors.dart';
import '../../widgets/goal_themed_scaffold.dart';
```

## Mudanças Necessárias:

### 1. Modificar o método `build()` (linha ~277)

**Antes:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
```

**Depois:**
```dart
@override
Widget build(BuildContext context) {
  return Consumer<GoalProvider>(
    builder: (context, goalProvider, _) {
      final goal = goalProvider.selectedGoal;
      final gradient = GoalThemedScaffold.getGradient(goal, fallbackIndex: 0);
      final primaryColor = GoalThemedScaffold.getPrimaryColor(goal, fallbackIndex: 0);

      return Scaffold(
```

### 2. Modificar o fundo do Stack (linha ~364-378)

**Antes:**
```dart
body: Stack(
  children: [
    // Gradient Background
    Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    ),
```

**Depois:**
```dart
body: Stack(
  children: [
    // Gradient Background with goal's color
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient.colors[0].withOpacity(0.3),
            gradient.colors[1].withOpacity(0.2),
            const Color(0xFF0f3460),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    ),
```

### 3. Atualizar Loading Indicator (linha ~386)

**Antes:**
```dart
return const Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  ),
);
```

**Depois:**
```dart
return Center(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
  ),
);
```

### 4. Atualizar botão de erro (linha ~410)

**Antes:**
```dart
style: ElevatedButton.styleFrom(
  backgroundColor: Colors.white.withOpacity(0.2),
  foregroundColor: Colors.white,
),
```

**Depois:**
```dart
style: ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
),
```

### 5. Atualizar RefreshIndicator (linha ~431)

**Antes:**
```dart
return RefreshIndicator(
  onRefresh: _loadGoalDetails,
  color: const Color(0xFF3B82F6),
```

**Depois:**
```dart
return RefreshIndicator(
  onRefresh: _loadGoalDetails,
  color: primaryColor,
```

### 6. Atualizar chamada de _buildHeaderCard (linha ~442)

**Antes:**
```dart
_buildHeaderCard(goal),
```

**Depois:**
```dart
_buildHeaderCard(goal, gradient),
```

### 7. Atualizar chamada de _buildProgressCard (linha ~447)

**Antes:**
```dart
_buildProgressCard(),
```

**Depois:**
```dart
_buildProgressCard(primaryColor),
```

### 8. Modificar assinatura de _buildHeaderCard (linha ~504)

**Antes:**
```dart
Widget _buildHeaderCard(GoalEntity goal) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5A67D8),
          Color(0xFF6B46C1),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF5A67D8).withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
```

**Depois:**
```dart
Widget _buildHeaderCard(GoalEntity goal, LinearGradient gradient) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
```

### 9. Modificar assinatura de _buildProgressCard (linha ~558)

**Antes:**
```dart
Widget _buildProgressCard() {
  return Consumer<TaskProvider>(
    builder: (context, taskProvider, _) {
      final totalTasks = taskProvider.taskCount;
      final completedTasks = taskProvider.completedCount;
      final progress = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;
```

**Depois:**
```dart
Widget _buildProgressCard(Color primaryColor) {
  return Consumer<TaskProvider>(
    builder: (context, taskProvider, _) {
      final totalTasks = taskProvider.taskCount;
      final completedTasks = taskProvider.completedCount;
      final progress = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;
```

### 10. Atualizar cor do texto de progresso (linha ~600)

**Antes:**
```dart
Text(
  '$completedTasks de $totalTasks tarefas',
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF3B82F6),
  ),
),
```

**Depois:**
```dart
Text(
  '$completedTasks de $totalTasks tarefas',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  ),
),
```

### 11. Atualizar cor da barra de progresso (linha ~621-626)

**Antes:**
```dart
valueColor: AlwaysStoppedAnimation<Color>(
  progress >= 100 ? Colors.green : const Color(0xFF3B82F6),
),
```

**Depois:**
```dart
valueColor: AlwaysStoppedAnimation<Color>(
  progress >= 100 ? Colors.green : primaryColor,
),
```

### 12. Atualizar FloatingActionButton (linha ~471-499)

**Antes:**
```dart
floatingActionButton: Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF10B981).withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  ),
```

**Depois:**
```dart
floatingActionButton: Container(
  decoration: BoxDecoration(
    gradient: gradient,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  ),
```

### 13. Fechar o Consumer no final do build (antes do último `)` do método build)

Adicionar antes do último `);` do método `build`:
```dart
        );
      },
    );  // <- Fecha o Consumer
```

## Resumo

Estas mudanças fazem com que:
1. ✅ O fundo use as cores da meta
2. ✅ O card de header use o gradiente da meta
3. ✅ As barras de progresso usem a cor primária da meta
4. ✅ O FAB use o gradiente da meta
5. ✅ Indicadores de loading e botões usem a cor da meta

O tema completo da tela se adaptará à cor configurada para cada meta!
