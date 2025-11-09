# Sistema de Cores Personalizáveis para Metas

## Implementações Concluídas

### 1. Entidade GoalEntity ✅
- Adicionado campo `colorIndex` (tipo `int`, padrão `-1`)
- Atualizado `copyWith()` para incluir `colorIndex`
- Atualizado `props` do Equatable para incluir `colorIndex`

**Arquivo**: `app/lib/domain/entities/goal_entity.dart`

### 2. Modelo GoalModel ✅
- Adicionado campo `colorIndex` em todos os métodos:
  - `toFirestore()` - salva no Firebase
  - `fromFirestore()` - lê do Firebase
  - `fromMap()` - lê de map
  - `toJson()` / `fromJson()` - serialização JSON
  - `toEntity()` / `fromEntity()` - conversão com entidade
  - `copyWith()` - cópia com modificações

**Arquivo**: `app/lib/data/models/goal_model.dart`

### 3. Paleta de Cores ✅
Criado arquivo `GoalColors` com:
- 10 gradientes pré-definidos
- Nomes das cores em português
- Métodos utilitários:
  - `getGradient(colorIndex, {fallbackIndex})` - retorna LinearGradient
  - `getGradientColors(colorIndex)` - retorna lista de cores
  - `getPrimaryColor(colorIndex)` - primeira cor do gradiente
  - `getSecondaryColor(colorIndex)` - segunda cor do gradiente
  - `getColorName(index)` - nome da cor
  - `colorCount` - total de cores disponíveis

**Arquivo**: `app/lib/core/constants/goal_colors.dart`

**Cores disponíveis**:
1. Rosa (EC4899 → 8B5CF6)
2. Roxo (8B5CF6 → 3B82F6)
3. Laranja (F59E0B → EF4444)
4. Verde (10B981 → 059669)
5. Azul Claro (06B6D4 → 3B82F6)
6. Índigo (6366F1 → 8B5CF6)
7. Verde Água (14B8A6 → 10B981)
8. Vermelho (F43F5E → EC4899)
9. Amarelo (FBBF24 → F59E0B)
10. Violeta (7C3AED → 6B46C1)

### 4. GoalCard Atualizado ✅
- Importado `GoalColors`
- Substituído array de gradientes fixo por `GoalColors.getGradient()`
- Usa `goal.colorIndex` se definido, senão usa `index` como fallback

**Arquivo**: `app/lib/presentation/widgets/goal_card.dart`

## Implementações Pendentes

### 5. Tela de Detalhes da Meta (goal_detail_screen.dart)

A tela de detalhes precisa usar o tema personalizado da meta. Aqui está como fazer:

```dart
// No início do build(), dentro do Consumer<GoalProvider>:
@override
Widget build(BuildContext context) {
  return Consumer<GoalProvider>(
    builder: (context, goalProvider, _) {
      final goal = goalProvider.selectedGoal;

      // Obter gradient e cor primária da meta
      final gradient = goal != null
          ? GoalColors.getGradient(goal.colorIndex, fallbackIndex: 0)
          : GoalColors.getGradient(-1, fallbackIndex: 0);
      final primaryColor = goal != null
          ? GoalColors.getPrimaryColor(goal.colorIndex, fallbackIndex: 0)
          : GoalColors.getPrimaryColor(-1, fallbackIndex: 0);

      return Scaffold(
        // ... resto do código
```

**Mudanças necessárias**:

1. **Fundo da tela** (linha ~378):
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        gradient.colors[0].withOpacity(0.3),  // Usar cor da meta
        gradient.colors[1].withOpacity(0.2),  // Usar cor da meta
        const Color(0xFF0f3460),
      ],
      stops: const [0.0, 0.5, 1.0],
    ),
  ),
),
```

2. **Loading indicator** (linha ~398):
```dart
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),  // Usar cor da meta
),
```

3. **Botão de erro** (linha ~422):
```dart
backgroundColor: primaryColor,  // Usar cor da meta
```

4. **RefreshIndicator** (linha ~443):
```dart
color: primaryColor,  // Usar cor da meta
```

5. **_buildHeaderCard** - adicionar parâmetro gradient:
```dart
Widget _buildHeaderCard(GoalEntity goal, LinearGradient gradient) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,  // Usar gradient da meta
      // ...
    ),
  );
}

// Chamada: _buildHeaderCard(goal, gradient),
```

6. **_buildProgressCard** - adicionar parâmetro primaryColor:
```dart
Widget _buildProgressCard(Color primaryColor) {
  // Usar primaryColor nas linhas 607 e 628
}

// Chamada: _buildProgressCard(primaryColor),
```

7. **FloatingActionButton** (linha ~484):
```dart
decoration: BoxDecoration(
  gradient: gradient,  // Usar gradient da meta
  // ...
  boxShadow: [
    BoxShadow(
      color: primaryColor.withOpacity(0.4),  // Usar cor da meta
      // ...
    ),
  ],
),
```

### 6. Adicionar Seletor de Cor (add_goal_screen.dart)

Adicionar um seletor de cores visual na tela de criar/editar meta:

```dart
// Adicionar variável de estado no _AddGoalScreenState:
int _selectedColorIndex = -1;  // -1 = auto

// No initState(), se editando meta existente:
if (widget.goal != null) {
  // ... código existente ...
  _selectedColorIndex = widget.goal!.colorIndex;
}

// Adicionar widget de seleção de cor no formulário:
Widget _buildColorPicker() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Cor da Meta',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          GoalColors.colorCount,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedColorIndex = index;
              });
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: GoalColors.getGradient(index),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedColorIndex == index
                      ? Colors.white
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: _selectedColorIndex == index
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: _selectedColorIndex == index
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      if (_selectedColorIndex >= 0)
        Text(
          GoalColors.getColorName(_selectedColorIndex),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
    ],
  );
}

// Adicionar no formulário, após os campos de data:
const SizedBox(height: 24),
_buildColorPicker(),
```

### 7. Atualizar Providers e Use Cases

**GoalProvider** (`app/lib/presentation/providers/goal_provider.dart`):

Ao criar meta, incluir `colorIndex`:
```dart
Future<bool> createGoal(
  // ... parâmetros existentes ...
  int colorIndex = -1,  // Adicionar parâmetro
) async {
  // ...
  final goal = GoalEntity(
    // ... campos existentes ...
    colorIndex: colorIndex,  // Incluir
  );
  // ...
}
```

**CreateGoalUseCase** (`app/lib/domain/usecases/goal/create_goal_usecase.dart`):

Adicionar `colorIndex` aos parâmetros se necessário.

### 8. Atualizar Chamadas de Criação de Meta

Em `add_goal_screen.dart`, ao chamar `createGoal`:

```dart
final success = widget.goal == null
    ? await goalProvider.createGoal(
        // ... parâmetros existentes ...
        colorIndex: _selectedColorIndex,  // Adicionar
      )
    : await goalProvider.updateGoal(
        // ... parâmetros existentes ...
        colorIndex: _selectedColorIndex,  // Adicionar
      );
```

## Migração de Dados Existentes

Metas existentes no Firebase terão `colorIndex = -1` (valor padrão). Elas continuarão funcionando normalmente, usando o índice baseado na posição como fallback.

## Teste

Após implementar:

1. Criar nova meta e escolher uma cor
2. Verificar que o card mostra a cor escolhida
3. Abrir detalhes da meta e verificar que o tema é aplicado
4. Editar meta e mudar a cor
5. Verificar que metas antigas (sem cor definida) ainda funcionam

## Próximos Passos

1. ✅ CONCLUÍDO: Estrutura de dados (Entity + Model)
2. ✅ CONCLUÍDO: Paleta de cores
3. ✅ CONCLUÍDO: GoalCard atualizado
4. 🔄 PENDENTE: Atualizar goal_detail_screen.dart
5. 🔄 PENDENTE: Adicionar seletor de cor em add_goal_screen.dart
6. 🔄 PENDENTE: Atualizar providers e use cases
7. 🔄 PENDENTE: Testar funcionalidade completa
