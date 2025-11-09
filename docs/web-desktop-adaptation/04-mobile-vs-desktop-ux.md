# Diferenças entre Mobile e Web Desktop UX

## Introdução

Este documento detalha as diferenças fundamentais entre experiência de usuário mobile e web desktop, e como aplicá-las no Capital Reserve Tracker.

---

## Paradigmas de Interação

### Mobile (Touch-First)
```
Interação Principal: Touch
- Tap para selecionar
- Long press para menu contextual
- Swipe para navegar/deletar
- Pinch para zoom
- Pull to refresh

Navegação:
- Bottom navigation bar
- Drawer (hamburger menu)
- Stacked screens (push/pop)
- Swipe back gesture

Feedback:
- Vibration (haptic)
- Toast messages
- Bottom sheets
- Floating action buttons
```

### Desktop (Mouse + Keyboard)
```
Interação Principal: Mouse + Keyboard
- Click para selecionar
- Right-click para menu contextual
- Hover para preview
- Scroll wheel para navegar
- Keyboard shortcuts

Navegação:
- Sidebar/Navigation rail
- Tabs
- Breadcrumbs
- Inline navegation (links)

Feedback:
- Tooltips
- Hover states
- Dialogs/Modals
- Notifications (top-right)
```

---

## Diferenças de Layout

### 1. Densidade de Informação

#### Mobile
- **Princípio**: Uma tarefa por vez
- **Layout**: Vertical scrolling
- **Cards**: Full width
- **Spacing**: Generoso (48px+ tap targets)

```dart
// Mobile card
Container(
  width: double.infinity,  // Full width
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Title(),
      SizedBox(height: 16),
      Content(),
    ],
  ),
)
```

#### Desktop
- **Princípio**: Múltiplas tarefas visíveis
- **Layout**: Grid / Multi-column
- **Cards**: Constrained width (300-400px)
- **Spacing**: Compacto (12-16px targets OK)

```dart
// Desktop card
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 400),
  child: Card(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Row(  // Horizontal quando possível
        children: [
          Icon(),
          SizedBox(width: 12),
          Expanded(child: Content()),
        ],
      ),
    ),
  ),
)
```

**Comparação Visual**

```
MOBILE (360px)                    DESKTOP (1440px)
┌────────────────┐               ┌──────────┬──────────┬──────────┐
│   Card 1       │               │ Card 1   │ Card 2   │ Card 3   │
│   [Full Width] │               │          │          │          │
├────────────────┤               ├──────────┼──────────┼──────────┤
│   Card 2       │               │ Card 4   │ Card 5   │ Card 6   │
│   [Full Width] │               │          │          │          │
├────────────────┤               └──────────┴──────────┴──────────┘
│   Card 3       │
└────────────────┘
```

---

### 2. Navegação Patterns

#### Mobile: Stacked Navigation

```
Screen Stack (push/pop):
┌─────────────┐
│   Home      │ ← User is here
├─────────────┤
│ Transactions│ ← Can go back
├─────────────┤
│   Detail    │ ← Can go back
└─────────────┘

Navigation Bar sempre visível (bottom)
```

#### Desktop: Persistent + Hierarchical

```
┌─Nav Rail─┬─ Breadcrumb ─────────────┐
│ Home     │ Transações > Detalhe     │
│ Trans.   ├──────────────────────────┤
│ Goals    │                          │
│ Dash.    │   Main Content           │
│          │   (sem stack)            │
└──────────┴──────────────────────────┘

Navigation Rail sempre visível (side)
Breadcrumbs mostram hierarquia
Tabs para sub-navegação
```

**Implicações**

| Aspecto | Mobile | Desktop |
|---------|--------|---------|
| AppBar | Volta button | Breadcrumbs |
| Context | Uma tela | Múltiplas views |
| Back | Pop navigation | Breadcrumb click |
| Menu | Drawer (hide) | Sidebar (always) |

---

### 3. Modals e Overlays

#### Mobile: Bottom Sheets

```dart
// Mobile pattern
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    height: MediaQuery.of(context).size.height * 0.7,
    child: DetailView(),
  ),
);

// Características:
- Ocupa parte inferior
- Swipe down para fechar
- Bom para quick actions
- Não obscurece completamente
```

#### Desktop: Dialogs ou Side Panels

```dart
// Desktop pattern - Dialog
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: 800,
      ),
      child: DetailView(),
    ),
  ),
);

// Desktop pattern - Side Panel
Scaffold(
  body: Row(
    children: [
      Expanded(child: MainContent()),
      if (showDetail)
        Container(
          width: 400,
          child: DetailPanel(),
        ),
    ],
  ),
)

// Características:
- Centro ou lado
- Click fora ou X para fechar
- Bom para formulários/detalhes
- Esc key support
```

**Quando Usar Cada Um**

| Tipo | Mobile | Desktop |
|------|--------|---------|
| Quick Action | BottomSheet | Dropdown / Popover |
| Form | BottomSheet | Dialog (center) |
| Detail View | FullScreen | Side Panel |
| Filter | BottomSheet | Persistent Sidebar |
| Settings | FullScreen | Dialog ou Settings page |

---

### 4. Ações Primárias

#### Mobile: Floating Action Button (FAB)

```dart
FloatingActionButton(
  onPressed: () => addTransaction(),
  child: Icon(Icons.add),
)

// Características:
- Sempre visível
- Fácil acesso com polegar
- Destaque visual
- Uma ação principal
```

**Problemas no Desktop**
- ❌ Ocupa espaço desnecessário
- ❌ Não é padrão de desktop
- ❌ Dificulta click acidental
- ❌ Não escala bem

#### Desktop: Toolbar Button

```dart
// AppBar actions
AppBar(
  actions: [
    TextButton.icon(
      icon: Icon(Icons.add),
      label: Text('Nova Transação'),
      onPressed: () => addTransaction(),
    ),
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () => openSettings(),
    ),
  ],
)

// Ou inline button
ElevatedButton.icon(
  icon: Icon(Icons.add),
  label: Text('Adicionar'),
  onPressed: () => addItem(),
)

// Características:
- Toolbar (AppBar actions)
- Inline com conteúdo
- Múltiplas ações visíveis
- Keyboard shortcuts
```

---

### 5. Lists e Tables

#### Mobile: Card List

```dart
ListView.builder(
  itemBuilder: (context, index) {
    return Card(
      child: ListTile(
        leading: Icon(),
        title: Text(),
        subtitle: Text(),
        trailing: Icon(Icons.chevron_right),
        onTap: () => showDetail(),
      ),
    );
  },
)

// Características:
- Um item por linha
- Tap para ver detalhe
- Swipe para delete
- Pull to refresh
```

#### Desktop: Data Table ou Grid

```dart
// Option 1: Data Table
DataTable(
  columns: [
    DataColumn(label: Text('Data')),
    DataColumn(label: Text('Descrição')),
    DataColumn(label: Text('Valor'), numeric: true),
    DataColumn(label: Text('Ações')),
  ],
  rows: transactions.map((t) => DataRow(
    cells: [
      DataCell(Text(t.date)),
      DataCell(Text(t.description)),
      DataCell(Text(t.amount)),
      DataCell(RowActions()),
    ],
  )).toList(),
)

// Option 2: Grid with Cards
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    childAspectRatio: 1.5,
  ),
  itemBuilder: (context, index) => CompactCard(),
)

// Características:
- Múltiplos itens visíveis
- Sorting, filtering inline
- Pagination
- Hover row highlight
- Right-click context menu
```

**Comparison**

| Feature | Mobile List | Desktop Table |
|---------|-------------|---------------|
| Density | Low (1 col) | High (6+ cols) |
| Actions | Tap/Swipe | Click/Right-click |
| Selection | Single | Multi (shift/ctrl) |
| Sorting | Separate UI | Column headers |
| Filtering | Separate UI | Inline search |

---

### 6. Forms

#### Mobile: Stacked Vertical

```dart
Column(
  children: [
    TextField(label: 'Email'),
    SizedBox(height: 16),
    TextField(label: 'Password'),
    SizedBox(height: 16),
    DropdownField(label: 'Category'),
    SizedBox(height: 24),
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text('Enviar'),
        onPressed: submit,
      ),
    ),
  ],
)

// Características:
- Full width inputs
- Vertical spacing (16-24px)
- Full width submit button
- One field per line
```

#### Desktop: Grid Layout

```dart
Form(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Linha 1: 2 campos
      Row(
        children: [
          Expanded(child: TextField(label: 'First Name')),
          SizedBox(width: 16),
          Expanded(child: TextField(label: 'Last Name')),
        ],
      ),
      SizedBox(height: 16),

      // Linha 2: 2 campos
      Row(
        children: [
          Expanded(child: TextField(label: 'Email')),
          SizedBox(width: 16),
          Expanded(child: DatePicker(label: 'Date')),
        ],
      ),
      SizedBox(height: 24),

      // Actions (não full width)
      Row(
        children: [
          ElevatedButton(
            child: Text('Salvar'),
            onPressed: submit,
          ),
          SizedBox(width: 8),
          TextButton(
            child: Text('Cancelar'),
            onPressed: cancel,
          ),
        ],
      ),
    ],
  ),
)

// Características:
- 2-3 campos por linha
- Compact spacing (12-16px)
- Actions agrupados (não full width)
- Labels ao lado (opcional)
```

---

### 7. Visual Feedback

#### Mobile

```dart
// Tap feedback
InkWell(
  onTap: () {},
  child: Container(
    padding: EdgeInsets.all(16),  // Large tap target
    child: Text('Action'),
  ),
)

// Loading
CircularProgressIndicator()  // Center screen

// Messages
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Saved!')),
)

// Haptic
HapticFeedback.mediumImpact();
```

#### Desktop

```dart
// Hover feedback
MouseRegion(
  cursor: SystemMouseCursors.click,
  onEnter: (_) => setState(() => isHovered = true),
  onExit: (_) => setState(() => isHovered = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: isHovered
        ? Colors.grey[200]
        : Colors.transparent,
    ),
    child: Padding(
      padding: EdgeInsets.all(12),  // Smaller padding OK
      child: Text('Action'),
    ),
  ),
)

// Loading
LinearProgressIndicator()  // Top of page

// Messages
// Top-right notification
OverlayEntry notification = OverlayEntry(
  builder: (context) => Positioned(
    top: 16,
    right: 16,
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Saved!'),
      ),
    ),
  ),
);

// Tooltip
Tooltip(
  message: 'Click to edit',
  child: IconButton(...),
)
```

---

### 8. Gestures

#### Mobile Gestures

```dart
// Swipe to delete
Dismissible(
  key: Key(item.id),
  direction: DismissDirection.endToStart,
  onDismissed: (_) => deleteItem(),
  background: Container(color: Colors.red),
  child: ListTile(...),
)

// Pull to refresh
RefreshIndicator(
  onRefresh: () async => loadData(),
  child: ListView(...),
)

// Swipe between pages
PageView(
  children: [Page1(), Page2(), Page3()],
)

// Long press
GestureDetector(
  onLongPress: () => showContextMenu(),
  child: Widget(),
)
```

#### Desktop Alternatives

```dart
// Delete: Icon button ou right-click
ListTile(
  trailing: IconButton(
    icon: Icon(Icons.delete),
    onPressed: () => confirmDelete(),
  ),
  onSecondaryTap: () => showContextMenu(),  // Right-click
)

// Refresh: Button ou auto-refresh
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: () => loadData(),
)

// Between pages: Tabs ou Navigation
TabBar(
  tabs: [Tab(text: 'Page 1'), Tab(text: 'Page 2')],
)

// Context menu: Right-click
GestureDetector(
  onSecondaryTapDown: (details) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        0, 0,
      ),
      items: [
        PopupMenuItem(child: Text('Edit')),
        PopupMenuItem(child: Text('Delete')),
      ],
    );
  },
  child: Widget(),
)
```

---

### 9. Typography

#### Mobile
```dart
// Larger base size (legibilidade)
headline1: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
headline2: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
body1: TextStyle(fontSize: 16)
body2: TextStyle(fontSize: 14)
caption: TextStyle(fontSize: 12)

// Line height maior
height: 1.5
```

#### Desktop
```dart
// Menor base size (mais conteúdo)
headline1: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)
headline2: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
body1: TextStyle(fontSize: 14)
body2: TextStyle(fontSize: 13)
caption: TextStyle(fontSize: 11)

// Line height menor
height: 1.3
```

---

### 10. Spacing e Densidade

#### Mobile: Generoso

```dart
// Targets de toque: 48x48dp mínimo
const minTouchTarget = 48.0;

// Padding cards
padding: EdgeInsets.all(16)

// Spacing entre elementos
SizedBox(height: 16)

// Margins
margin: EdgeInsets.all(16)
```

#### Desktop: Compacto

```dart
// Targets de click: 32x32px OK
const minClickTarget = 32.0;

// Padding cards
padding: EdgeInsets.all(20)

// Spacing entre elementos
SizedBox(height: 12)

// Margins
margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12)
```

---

## Aplicação no Capital Reserve Tracker

### Matriz de Adaptação

| Componente | Mobile Pattern | Desktop Pattern | Implementação |
|------------|----------------|-----------------|---------------|
| **Navegação** | BottomNavigationBar | NavigationRail | ResponsiveNavigation |
| **Home Cards** | Stack vertical | Grid 2-3 cols | ResponsiveGridView |
| **Transactions** | Lista + FAB | Table + Toolbar | Conditional layout |
| **Goal Detail** | FullScreen | Side Panel | ResponsiveSidebar |
| **Filters** | BottomSheet | Persistent Sidebar | Conditional render |
| **Add Action** | FAB | Toolbar Button | Conditional button |
| **Charts** | Full width | Grid 2x2 | ResponsiveChart |
| **Forms** | Stacked | Grid 2 cols | ResponsiveForm |

---

### Exemplos Práticos

#### 1. Transaction Actions

```dart
// Mobile: FAB
if (ResponsiveUtils.isMobile(context)) {
  return Scaffold(
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => addTransaction(),
    ),
  );
}

// Desktop: Toolbar button
return Scaffold(
  appBar: AppBar(
    actions: [
      ElevatedButton.icon(
        icon: Icon(Icons.add),
        label: Text('Nova Transação'),
        onPressed: () => addTransaction(),
      ),
    ],
  ),
);
```

#### 2. Transaction Detail

```dart
// Mobile: Navigate to full screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => TransactionDetailScreen(transaction),
  ),
);

// Desktop: Show dialog or side panel
if (ResponsiveUtils.isDesktop(context)) {
  showDialog(
    context: context,
    builder: (_) => TransactionDetailDialog(transaction),
  );
} else {
  // OR side panel
  setState(() {
    selectedTransaction = transaction;
    showDetailPanel = true;
  });
}
```

#### 3. Filters

```dart
// Mobile: Bottom sheet
void showFilters() {
  showModalBottomSheet(
    context: context,
    builder: (_) => FilterSheet(),
  );
}

// Desktop: Persistent sidebar
Widget build(BuildContext context) {
  if (ResponsiveUtils.isDesktop(context)) {
    return Row(
      children: [
        SizedBox(
          width: 280,
          child: FilterSidebar(),
        ),
        Expanded(child: ContentArea()),
      ],
    );
  }

  return Scaffold(
    body: ContentArea(),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.filter_list),
      onPressed: showFilters,
    ),
  );
}
```

---

## Checklist de Adaptação

### Por Screen

- [ ] Navegação adaptada (bottom bar / rail)
- [ ] Layout responsivo (vertical / horizontal)
- [ ] Actions adaptados (FAB / toolbar)
- [ ] Modals adaptados (bottom sheet / dialog)
- [ ] Spacing apropriado (mobile / desktop)
- [ ] Typography ajustada
- [ ] Touch targets vs click targets
- [ ] Gestures com alternativas (swipe / buttons)
- [ ] Hover states (desktop only)
- [ ] Keyboard shortcuts (desktop only)

### Por Componente

- [ ] Responsive sizing
- [ ] Density apropriada
- [ ] Interactive states (hover, focus, active)
- [ ] Cursor styles (desktop)
- [ ] Tooltips informativos (desktop)
- [ ] Context menus (desktop)
- [ ] Mobile gestures OK
- [ ] Desktop mouse/keyboard OK

---

## Conclusão

As principais diferenças entre Mobile e Desktop UX são:

1. **Densidade**: Mobile = espaçoso, Desktop = compacto
2. **Layout**: Mobile = vertical, Desktop = grid/horizontal
3. **Navegação**: Mobile = stacked, Desktop = persistent
4. **Interação**: Mobile = touch, Desktop = mouse+keyboard
5. **Modals**: Mobile = bottom sheets, Desktop = dialogs/panels
6. **Actions**: Mobile = FAB, Desktop = toolbar
7. **Lists**: Mobile = cards, Desktop = tables/grids
8. **Forms**: Mobile = stacked, Desktop = grid

**Key Takeaway**: Não é apenas "fazer maior", mas adaptar padrões de interação e layout para cada plataforma.
