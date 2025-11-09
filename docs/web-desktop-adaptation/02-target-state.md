# Estado Desejado para Web Desktop (TO-BE)

## Visão Geral

Transformar o aplicativo de **mobile-first** para **web-desktop optimized**, mantendo compatibilidade total com mobile através de design responsivo.

## Princípios de Design Desktop

### 1. Aproveitamento de Espaço Horizontal
- Layouts em grid multi-coluna
- Sidebars e panels laterais
- Master-detail views
- Dashboards com widgets organizados

### 2. Navegação Desktop-First
- Navegação lateral persistente
- Breadcrumbs para hierarquia
- Tabs para organização
- Atalhos de teclado

### 3. Interações Mouse-Friendly
- Hover states informativos
- Context menus (right-click)
- Drag-and-drop onde apropriado
- Tooltips descritivos

### 4. Performance Otimizada
- Lazy loading de components
- Virtual scrolling em listas longas
- Animações GPU-accelerated
- Code splitting por rota

---

## Arquitetura Visual Alvo

### Layout Responsivo Global

```
Mobile (< 600px)          Tablet (600-1200px)        Desktop (> 1200px)
─────────────────         ────────────────────       ──────────────────────────
┌─────────────┐          ┌──────────────────┐       ┌──┬────────────────────┐
│   AppBar    │          │     AppBar       │       │  │    AppBar          │
├─────────────┤          ├──────────────────┤       │  ├────────────────────┤
│             │          │                  │       │N │                    │
│             │          │                  │       │a │                    │
│   Content   │          │     Content      │       │v │      Content       │
│   (Scroll)  │          │     (Scroll)     │       │  │      (Grid/        │
│             │          │                  │       │R │       Panels)      │
│             │          │                  │       │a │                    │
│             │          │                  │       │i │                    │
├─────────────┤          ├──────────────────┤       │l │                    │
│  BottomNav  │          │    BottomNav     │       │  │                    │
└─────────────┘          └──────────────────┘       └──┴────────────────────┘
```

### Breakpoints Strategy

```dart
// Responsivo em 4 níveis
Mobile:        < 600px   (1 coluna, BottomNav)
Tablet:   600-1200px    (2 colunas, BottomNav)
Desktop: 1200-1600px    (3 colunas, NavRail)
XL:          > 1600px   (3-4 colunas, NavRail Extended)
```

---

## Transformações por Screen

### 1. Navigation System

#### Implementação Alvo

**Mobile/Tablet**
```dart
BottomNavigationBar com 5 itens:
- Home (Dashboard principal)
- Transações
- Metas
- Dashboard (Analytics)
- IA
```

**Desktop**
```dart
NavigationRail (lateral esquerda):
- Extended quando > 1200px
- Collapsed quando 900-1200px
- Ícones + labels
- Drawer toggle para navegação secundária

+ Opcional:
  - Secondary sidebar (filtros, configurações)
  - Top tabs para sub-navegação
```

**Hierarquia Visual**
```
┌─ NavRail ─┬─ Breadcrumb ─────────────┐
│ Home      │ Home > Metas > Viagem    │
│ >Metas    ├──────────────────────────┤
│ Trans.    │                          │
│ Dashb.    │      Main Content        │
│ IA        │                          │
└───────────┴──────────────────────────┘
```

---

### 2. Home Screen Transformation

#### Layout Desktop (> 1200px)

```
┌──────────────────────────────────────────────┐
│  Capital Reserve Tracker          [🔔] [👤] │
├──────────────────────────────────────────────┤
│ N │  ┌───────────────┬───────────────┐      │
│ a │  │ Capital Card  │  Goals Card   │      │
│ v │  │               │               │      │
│   │  └───────────────┴───────────────┘      │
│ R │                                          │
│ a │  Quick Actions (4 colunas)               │
│ i │  ┌────┬────┬────┬────┬────┐             │
│ l │  │ 📊 │ 💰 │ 📝 │ 📈 │ 🤖 │             │
│   │  └────┴────┴────┴────┴────┘             │
│   │                                          │
│   │  Stats Overview (chips horizontais)      │
│   │  [Hoje] [Semana] [Mês]                  │
│   │  ┌─────┬─────┬─────┬─────┐              │
│   │  │Rec. │Desp.│Saldo│Trans│              │
│   │  └─────┴─────┴─────┴─────┘              │
│   │                                          │
│   │  Active Goals (Grid 2-3 cols)           │
│   │  ┌──────────┬──────────┬──────────┐     │
│   │  │ Goal 1   │ Goal 2   │ Goal 3   │     │
│   │  └──────────┴──────────┴──────────┘     │
└───┴──────────────────────────────────────────┘
```

**Mudanças Principais**
1. ✅ Max-width: 1400px (centralizado)
2. ✅ Capital + Goals: Row (2 cols) em vez de Column
3. ✅ Quick Actions: 4-5 colunas em vez de 2
4. ✅ Stats Overview: Row com 4 cards lado a lado
5. ✅ Active Goals: Grid 2-3 colunas
6. ✅ Background: Mantém gradiente animado (visual atraente)
7. ✅ FAB → Toolbar button

**Responsividade**
```dart
// Pseudo-código
Column(
  maxWidth: ResponsiveUtils.getMaxContentWidth(context),
  children: [
    ResponsiveFlexLayout( // Row em desktop, Column em mobile
      children: [
        CapitalCard(),
        GoalsCard(),
      ],
    ),
    ResponsiveGridView(
      mobileColumns: 2,
      desktopColumns: 5,
      children: quickActionCards,
    ),
    ResponsiveFlexLayout(
      children: statsCards,
    ),
    ResponsiveGridView(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      children: goalCards,
    ),
  ],
)
```

---

### 3. Dashboard Screen Transformation

#### Layout Desktop (> 1200px)

```
┌──────────────────────────────────────────────┐
│  Dashboard                        [⚙️] [📅] │
├──────────────────────────────────────────────┤
│ N │ Summary (4 cards horizontal)            │
│ a │ ┌──────┬──────┬──────┬──────┐           │
│ v │ │Total │Meta  │Prog. │Saldo │           │
│   │ └──────┴──────┴──────┴──────┘           │
│ R │                                          │
│ a │ Charts Section (2x2 Grid)               │
│ i │ ┌───────────────┬───────────────┐       │
│ l │ │ Reserve       │ Income vs     │       │
│   │ │ Evolution     │ Expenses      │       │
│   │ │ [Filters]     │ [Filters]     │       │
│   │ ├───────────────┼───────────────┤       │
│   │ │ Category      │ Hourly        │       │
│   │ │ Spending      │ Spending      │       │
│   │ └───────────────┴───────────────┘       │
│   │                                          │
│   │ Goals Progress + Insights (Sidebar)     │
│   │ ┌─────────────────┬──────────────┐      │
│   │ │ Goals (60%)     │ Insights     │      │
│   │ │ [List]          │ (40%)        │      │
│   │ └─────────────────┴──────────────┘      │
└───┴──────────────────────────────────────────┘
```

**Mudanças Principais**
1. ✅ Summary: Row com 4 cards (em vez de Grid 2x2)
2. ✅ Main Charts: Grid 2x2 (lado a lado)
3. ✅ Filtros integrados em cada chart (não repetidos)
4. ✅ Goals Progress + Insights: Row (60/40)
5. ✅ Daily/Value charts: Abaixo do fold ou em tabs
6. ✅ Max-width: 1400px

**Chart Sizing**
```dart
// Desktop
Chart container:
  - Width: (maxWidth - gap) / 2  // 50% cada
  - Height: 300-350px
  - Aspect ratio mantido

// Mobile
Chart container:
  - Width: 100%
  - Height: 250px
```

---

### 4. Transactions Screen Transformation

#### Layout Desktop (> 1200px)

```
┌──────────────────────────────────────────────┐
│  Transações                   [+ Nova] [⚙️] │
├──────────────────────────────────────────────┤
│ N │ ┌────────────┐  ┌─────────────────────┐ │
│ a │ │ Filtros    │  │ Summary             │ │
│ v │ │ ────────   │  │ ┌─────┬─────┬─────┐ │ │
│   │ │ Período:   │  │ │ Rec.│Desp.│Saldo│ │ │
│ R │ │ [ Mês ▼]   │  │ └─────┴─────┴─────┘ │ │
│ a │ │            │  ├─────────────────────┤ │
│ i │ │ Tipo:      │  │ Transactions List   │ │
│ l │ │ ☐ Receitas │  │ ┌─────────────────┐ │ │
│   │ │ ☐ Despesas │  │ │ Hoje            │ │ │
│   │ │            │  │ │ - Trans. 1      │ │ │
│   │ │ Categoria: │  │ │ - Trans. 2      │ │ │
│   │ │ [ Todas ▼] │  │ │                 │ │ │
│   │ │            │  │ │ Ontem           │ │ │
│   │ │ [Aplicar]  │  │ │ - Trans. 3      │ │ │
│   │ └────────────┘  │ └─────────────────┘ │ │
│   │                 │                     │ │
│   │                 │ [Ver mais...]       │ │
│   │                 └─────────────────────┘ │
└───┴──────────────────────────────────────────┘
```

**Mudanças Principais**
1. ✅ Sidebar permanente para filtros (esquerda)
2. ✅ Summary + List: Layout vertical (direita)
3. ✅ Click em transação: Abre dialog (não bottom sheet)
4. ✅ Toolbar button para adicionar (não FAB)
5. ✅ Virtual scrolling para listas longas
6. ✅ Paginação ou infinite scroll

**Master-Detail Option**
```
┌─────────────┬──────────────┬────────────┐
│   Filtros   │     List     │  Details   │
│   (20%)     │     (50%)    │   (30%)    │
└─────────────┴──────────────┴────────────┘
```

---

### 5. Goals Screen Transformation

#### Layout Desktop (> 1200px)

```
┌──────────────────────────────────────────────┐
│  Minhas Metas                 [+ Nova] [⚙️] │
├──────────────────────────────────────────────┤
│ N │  Summary + Filters                      │
│ a │  ┌────┬────┬────┐ [Todas▼] [A-Z▼]      │
│ v │  │Ativ│Conc│Task│                       │
│   │  └────┴────┴────┘                       │
│ R │                                          │
│ a │  Goals Grid (3 columns)                 │
│ i │  ┌──────────┬──────────┬──────────┐     │
│ l │  │ Goal 1   │ Goal 2   │ Goal 3   │     │
│   │  │ [====  ] │ [======] │ [==    ] │     │
│   │  ├──────────┼──────────┼──────────┤     │
│   │  │ Goal 4   │ Goal 5   │ Goal 6   │     │
│   │  └──────────┴──────────┴──────────┘     │
│   │                                          │
│   │  [Load more...]                         │
└───┴──────────────────────────────────────────┘

// Click em Goal → Abre side panel (não tela cheia)
┌──────────────────┬──────────────────────────┐
│   Goals Grid     │   Goal Detail Panel     │
│   (60%)          │   (40%)                 │
│                  │   [X] Close             │
│                  │   ────────────           │
│                  │   Title: Viagem         │
│                  │   Progress: 45%         │
│                  │                         │
│                  │   Tasks:                │
│                  │   ☑ Task 1              │
│                  │   ☐ Task 2              │
│                  │                         │
│                  │   Transactions (5)      │
│                  │   [Ver todas...]        │
└──────────────────┴──────────────────────────┘
```

**Mudanças Principais**
1. ✅ Grid 3 colunas (em vez de lista vertical)
2. ✅ Filtros e ordenação sempre visíveis
3. ✅ Detail em side panel (não fullscreen)
4. ✅ Masonry grid (diferentes alturas OK)
5. ✅ Hover: Preview informações adicionais
6. ✅ Drag-to-reorder (opcional)

---

### 6. Auth Screens

#### Estado Atual → Alvo

**Mudança Mínima** ✅ Já está bom!

**Enhancements Desktop**
```
┌──────────────────────────────────────────────┐
│                                              │
│  ┌────────────────┬─────────────────────┐   │
│  │                │                     │   │
│  │                │   ┌──────────┐      │   │
│  │  Illustration  │   │  Logo    │      │   │
│  │     (SVG)      │   ├──────────┤      │   │
│  │                │   │          │      │   │
│  │  [Marketing    │   │   Form   │      │   │
│  │   content]     │   │  (400px) │      │   │
│  │                │   │          │      │   │
│  │                │   └──────────┘      │   │
│  │                │                     │   │
│  └────────────────┴─────────────────────┘   │
│                                              │
└──────────────────────────────────────────────┘
    50% Illustration      50% Form
```

**Opcional**
- Ilustração/Hero image à esquerda (>1200px)
- Marketing copy
- Social proof (testemunhos)

---

## Componentes Adaptativos Alvo

### 1. Responsive Containers

```dart
// MaxWidthContainer
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  // Auto-adapta baseado no breakpoint
  // Mobile: 100%, Desktop: 1400px centralizado
}

// ResponsivePadding
class ResponsivePadding extends StatelessWidget {
  final Widget child;

  // Mobile: 16px, Tablet: 24px, Desktop: 32px
}

// ResponsiveGrid
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  // Auto-ajusta número de colunas
}
```

### 2. Navigation Components

```dart
// AppShell (wrapper principal)
class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  // Mobile: BottomNavigationBar
  // Desktop: NavigationRail + child
}

// ResponsiveSidebar
class ResponsiveSidebar extends StatelessWidget {
  final Widget child;
  final Widget? sidebar;

  // Mobile: Drawer
  // Desktop: Persistente ao lado
}
```

### 3. Enhanced Widgets

```dart
// HoverCard (com preview)
class HoverCard extends StatefulWidget {
  final Widget child;
  final Widget? hoverContent;

  // Desktop: Mostra preview on hover
  // Mobile: Tap para ver
}

// ResponsiveDialog
class ResponsiveDialog extends StatelessWidget {
  // Mobile: Bottom sheet
  // Desktop: Center dialog (max-width)
}

// DataTable (para listas grandes)
class ResponsiveDataTable extends StatelessWidget {
  // Mobile: Cards
  // Desktop: Table com sorting/filtering
}
```

---

## Performance Targets

### Métricas Alvo

| Métrica | Mobile | Desktop | Current | Target |
|---------|--------|---------|---------|--------|
| First Paint | < 1s | < 800ms | ~1.2s | ✅ |
| Time to Interactive | < 2s | < 1.5s | ~2.5s | ⚠️ |
| Frame Rate | 60fps | 60fps | ~50fps | ⚠️ |
| Bundle Size | < 2MB | < 3MB | ~1.8MB | ✅ |
| Memory Usage | < 100MB | < 150MB | ~120MB | ✅ |

### Otimizações

1. **Lazy Loading**
   ```dart
   // Charts carregam sob demanda
   // Tabs carregam conteúdo quando ativados
   // Images com lazy loading
   ```

2. **Virtual Scrolling**
   ```dart
   // Listas longas (>50 items)
   ListView.builder() // ✅ Já usa

   // Considerar:
   - flutter_sticky_header (para grupos)
   - infinite_scroll_pagination
   ```

---

## Design System Expandido

### Responsive Typography

```dart
class ResponsiveTypography {
  static TextStyle h1(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.responsiveFontSize(
        context,
        mobile: 28,
        tablet: 32,
        desktop: 36,
      ),
      fontWeight: FontWeight.bold,
    );
  }

  // h2, h3, body1, body2, caption...
}
```

### Spacing System

```dart
class Spacing {
  // Base: 4px
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  // Responsive
  static double responsive(BuildContext context, {
    double mobile = md,
    double? tablet,
    double? desktop,
  }) {
    return ResponsiveUtils.valueByScreen(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );
  }
}
```

### Interactive States

```dart
// Hover, Focus, Active states para desktop
class InteractiveCard extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setHover(true),
      onExit: (_) => setHover(false),
      child: AnimatedContainer(
        // Smooth transitions
        elevation: isHovered ? 8 : 2,
        scale: isHovered ? 1.02 : 1.0,
      ),
    );
  }
}
```

---

## Keyboard Navigation

### Shortcuts Alvo

```dart
// Global shortcuts
Ctrl/Cmd + K: Search
Ctrl/Cmd + N: New transaction
Ctrl/Cmd + G: New goal
Ctrl/Cmd + /: Toggle sidebar
Ctrl/Cmd + 1-5: Navigate tabs
Esc: Close modals
Tab: Focus next
Shift+Tab: Focus previous

// Implementação
class KeyboardShortcuts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
          SearchIntent(),
        // ...
      },
      actions: {
        SearchIntent: CallbackAction(
          onInvoke: (_) => openSearch(),
        ),
      },
      child: child,
    );
  }
}
```

---

## Accessibility (A11y)

### WCAG 2.1 AA Compliance

1. **Contrast Ratios**
   - Text: Mínimo 4.5:1
   - Large text: Mínimo 3:1
   - UI components: Mínimo 3:1

2. **Keyboard Navigation**
   - Todos os componentes acessíveis via Tab
   - Focus indicators visíveis
   - Skip links para conteúdo principal

3. **Screen Readers**
   - Semantics adequados em todos os widgets
   - Labels descritivos
   - ARIA roles onde necessário

4. **Responsive Text**
   - Zoom até 200% sem quebrar layout
   - Text scaling support

---

## Transição e Backwards Compatibility

### Estratégia de Migração

**Fase 1: Core Components (Semana 1-2)**
- ✅ ResponsiveContainers
- ✅ AppShell com NavigationRail
- ✅ RepaintBoundary optimization

**Fase 2: Main Screens (Semana 3-4)**
- ✅ Home Screen layout
- ✅ Dashboard Screen layout
- ✅ Transactions Screen layout

**Fase 3: Secondary Screens (Semana 5-6)**
- ✅ Goals Screen layout
- ✅ AI Screens
- ✅ Settings

**Fase 4: Polish (Semana 7-8)**
- ✅ Hover states
- ✅ Keyboard navigation
- ✅ Micro-interactions
- ✅ Performance tuning

### Backwards Compatibility

```dart
// GARANTIR que mobile não quebra!
// Todos os layouts devem ter fallback

ResponsiveUtils.isMobile(context)
  ? MobileLayout()
  : DesktopLayout()

// Testes em múltiplas resoluções:
// 360x640 (mobile)
// 768x1024 (tablet)
// 1366x768 (laptop)
// 1920x1080 (desktop)
// 2560x1440 (QHD)
```

---

## Checklist de Implementação

### Para Cada Screen

- [ ] Max-width container implementado
- [ ] Layout responsivo (mobile/tablet/desktop)
- [ ] Navigation adaptada (bottom bar / rail)
- [ ] Cards com sizing apropriado
- [ ] Grids com colunas responsivas
- [ ] Dialogs em vez de bottom sheets (desktop)
- [ ] Toolbar buttons em vez de FABs (desktop)
- [ ] Hover states adicionados
- [ ] Keyboard navigation funcional
- [ ] Performance otimizada (60fps)
- [ ] Testado em 4+ resoluções

### Para Cada Componente

- [ ] Responsive sizing
- [ ] Proper spacing (mobile/desktop)
- [ ] Touch e mouse interactions
- [ ] Accessibility (semantics)
- [ ] Documentation
- [ ] Unit tests
- [ ] Visual regression tests

---

## Conclusão

Com essas transformações, o app alcançará:
- **95%+ Desktop Readiness** (vs. 59% atual)
- **Melhor UX** em telas grandes
- **Performance otimizada** para web
- **Backward compatible** com mobile

**Next Steps**: Ver `03-implementation-guide.md` para guia prático de implementação.
