# 🔄 Guia Rápido de Migração

## Como Converter Telas Existentes para Responsivas

### 🎯 Padrão de Migração em 5 Passos

---

## Passo 1: Adicionar Imports

```dart
// No topo do arquivo
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/adaptive_navigation.dart';
```

---

## Passo 2: Substituir Scaffold

### ❌ Antes
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Título')),
      body: MyContent(),
      bottomNavigationBar: BottomNavigationBar(...),
    );
  }
}
```

### ✅ Depois
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigation(
      currentIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      destinations: [
        AdaptiveNavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        // ... outros destinos
      ],
      title: 'Título',
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return ResponsiveLayout(
      child: MyContent(),
    );
  }
}
```

---

## Passo 3: Tornar Padding Responsivo

### ❌ Antes
```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Widget(),
)
```

### ✅ Depois
```dart
Padding(
  padding: ResponsiveUtils.responsivePadding(context),
  child: Widget(),
)

// Ou use ResponsiveLayout que já aplica padding
ResponsiveLayout(
  child: Widget(),
)
```

---

## Passo 4: Converter Listas/Grids

### ❌ Antes
```dart
GridView.count(
  crossAxisCount: 2,
  children: items.map((item) => ItemCard(item)).toList(),
)
```

### ✅ Depois
```dart
ResponsiveGridView(
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
  children: items.map((item) => ItemCard(item)).toList(),
)
```

---

## Passo 5: Adaptar Componentes

### Cards

#### ❌ Antes
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Conteúdo'),
  ),
)
```

#### ✅ Depois
```dart
AdaptiveCard(
  child: Text('Conteúdo'),
)
```

### Buttons

#### ❌ Antes
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Salvar'),
)
```

#### ✅ Depois
```dart
AdaptiveButton(
  label: 'Salvar',
  icon: Icons.save,
  isPrimary: true,
  onPressed: () {},
)
```

### Text Fields

#### ❌ Antes
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Digite seu email',
  ),
  controller: controller,
)
```

#### ✅ Depois
```dart
AdaptiveTextField(
  label: 'Email',
  hint: 'Digite seu email',
  controller: controller,
  keyboardType: TextInputType.emailAddress,
)
```

---

## 🎨 Padrões de Layout Comuns

### Layout de Formulário

#### ❌ Antes
```dart
Column(
  children: [
    TextField(...),
    TextField(...),
    Row(
      children: [
        ElevatedButton(...),
        TextButton(...),
      ],
    ),
  ],
)
```

#### ✅ Depois
```dart
Column(
  children: [
    // Campos lado a lado em desktop, empilhados em mobile
    ResponsiveFlexLayout(
      children: [
        AdaptiveTextField(...),
        AdaptiveTextField(...),
      ],
    ),

    SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

    // Botões
    ResponsiveFlexLayout(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AdaptiveButton(
          label: 'Cancelar',
          isPrimary: false,
          onPressed: () {},
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context)),
        AdaptiveButton(
          label: 'Salvar',
          isPrimary: true,
          onPressed: () {},
        ),
      ],
    ),
  ],
)
```

### Layout de Dashboard

#### ❌ Antes
```dart
Column(
  children: [
    Row(
      children: [
        Expanded(child: Card1()),
        Expanded(child: Card2()),
      ],
    ),
    Card3(),
  ],
)
```

#### ✅ Depois
```dart
Column(
  children: [
    ResponsiveGridView(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 4,
      children: [
        Card1(),
        Card2(),
        Card3(),
        Card4(),
      ],
    ),
  ],
)
```

---

## 📊 Checklist de Migração por Tela

### Para cada tela, verifique:

- [ ] Imports adicionados
- [ ] Scaffold substituído por AdaptiveNavigation
- [ ] Padding convertido para responsivo
- [ ] Font sizes tornados responsivos
- [ ] Listas/Grids usando ResponsiveGridView
- [ ] Cards usando AdaptiveCard
- [ ] Buttons usando AdaptiveButton
- [ ] TextFields usando AdaptiveTextField
- [ ] Dialogs usando AdaptiveDialog
- [ ] Layout testado em mobile
- [ ] Layout testado em tablet
- [ ] Layout testado em desktop
- [ ] Orientação landscape testada

---

## 🔍 Exemplos de Refatoração Rápida

### Exemplo 1: Tela Simples

#### ❌ Antes (30 linhas)
```dart
class SimpleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Título')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Item 1'),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Item 2'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### ✅ Depois (20 linhas)
```dart
class SimpleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Column(
        children: [
          AdaptiveCard(child: Text('Item 1')),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          AdaptiveCard(child: Text('Item 2')),
        ],
      ),
    );
  }
}
```

### Exemplo 2: Tela com Lista

#### ❌ Antes
```dart
ListView.builder(
  padding: EdgeInsets.all(16),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(items[index].name),
        subtitle: Text(items[index].description),
      ),
    );
  },
)
```

#### ✅ Depois
```dart
ListView.separated(
  padding: ResponsiveUtils.responsivePadding(context),
  itemCount: items.length,
  separatorBuilder: (_, __) => SizedBox(
    height: ResponsiveUtils.getSpacing(context),
  ),
  itemBuilder: (context, index) {
    return AdaptiveCard(
      child: AdaptiveListTile(
        title: Text(items[index].name),
        subtitle: Text(items[index].description),
      ),
    );
  },
)
```

---

## 🎯 Priorização de Telas

### Alta Prioridade (fazer primeiro)
1. **HomeScreen** - Ponto de entrada principal
2. **DashboardScreen** - Tela mais complexa
3. **TransactionsScreen** - Muito usada

### Média Prioridade
4. **GoalsScreen**
5. **AddTransactionScreen**
6. **AddGoalScreen**

### Baixa Prioridade
7. Telas de configurações
8. Telas de ajuda/sobre
9. Telas secundárias

---

## ⚡ Atalhos para Migração Rápida

### 1. Find & Replace Global

```
Find:    Padding(padding: EdgeInsets.all(16)
Replace: Padding(padding: ResponsiveUtils.responsivePadding(context)

Find:    Card(child:
Replace: AdaptiveCard(child:

Find:    ElevatedButton(
Replace: AdaptiveButton(label: '???', isPrimary: true,
```

### 2. Snippet para VSCode

```json
{
  "Adaptive Card": {
    "prefix": "acard",
    "body": [
      "AdaptiveCard(",
      "  child: ${1:Widget()},",
      "  onTap: ${2:() {}},",
      ")"
    ]
  },
  "Adaptive Button": {
    "prefix": "abtn",
    "body": [
      "AdaptiveButton(",
      "  label: '${1:Label}',",
      "  icon: Icons.${2:save},",
      "  isPrimary: ${3:true},",
      "  onPressed: ${4:() {}},",
      ")"
    ]
  },
  "Responsive Grid": {
    "prefix": "rgrid",
    "body": [
      "ResponsiveGridView(",
      "  mobileColumns: ${1:1},",
      "  tabletColumns: ${2:2},",
      "  desktopColumns: ${3:3},",
      "  children: [",
      "    $4",
      "  ],",
      ")"
    ]
  }
}
```

---

## 📝 Template de Tela Responsiva

Use este template como base para novas telas:

```dart
import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/adaptive_navigation.dart';

class NewResponsiveScreen extends StatefulWidget {
  const NewResponsiveScreen({super.key});

  @override
  State<NewResponsiveScreen> createState() => _NewResponsiveScreenState();
}

class _NewResponsiveScreenState extends State<NewResponsiveScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigation(
      currentIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        // Navigate based on index
      },
      destinations: _buildDestinations(),
      title: 'Screen Title',
      child: _buildContent(),
    );
  }

  List<AdaptiveNavigationDestination> _buildDestinations() {
    return [
      AdaptiveNavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      // Add more destinations
    ];
  }

  Widget _buildContent() {
    return ResponsiveLayout(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveFlexLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Header Title',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        AdaptiveButton(
          label: 'Action',
          icon: Icons.add,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    return ResponsiveGridView(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      children: [
        // Add your content widgets
      ],
    );
  }
}
```

---

## 🚀 Começando a Migração

### Dia 1: Setup e Primeira Tela
1. Testar utilities em uma tela simples
2. Migrar HomeScreen
3. Testar em 3 tamanhos diferentes

### Dia 2: Telas Principais
4. Migrar DashboardScreen
5. Migrar TransactionsScreen
6. Revisar consistência

### Dia 3: Telas Secundárias
7. Migrar GoalsScreen
8. Migrar telas de adicionar/editar
9. Testes finais

### Dia 4: Polimento
10. Ajustar espaçamentos
11. Otimizar performance
12. Documentar mudanças

---

## ✅ Validação Pós-Migração

Para cada tela migrada, verifique:

1. **Funcionalidade**
   - [ ] Todas as funcionalidades mantidas
   - [ ] Navegação funcionando
   - [ ] Forms validando corretamente

2. **Visual**
   - [ ] Layout correto em mobile (< 600px)
   - [ ] Layout correto em tablet (600-900px)
   - [ ] Layout correto em desktop (> 900px)
   - [ ] Orientação landscape OK
   - [ ] Sem overflow de texto
   - [ ] Imagens carregando

3. **Performance**
   - [ ] Sem lag ao redimensionar
   - [ ] Animações suaves
   - [ ] Scroll performático
   - [ ] Sem memory leaks

4. **Acessibilidade**
   - [ ] Touch targets adequados
   - [ ] Contraste de cores OK
   - [ ] Navegação por teclado
   - [ ] Screen reader compatível

---

Boa migração! 🎉
