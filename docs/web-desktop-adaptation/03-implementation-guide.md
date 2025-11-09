# Guia de Implementação - Adaptação Web Desktop

## Visão Geral

Este guia fornece instruções passo a passo para implementar as adaptações necessárias para otimizar o aplicativo Capital Reserve Tracker para web desktop.

---

## Fase 1: Fundação (Semana 1-2)

### 1.1 - Criar Componentes Core Responsivos

#### MaxWidthContainer

```dart
// lib/presentation/widgets/responsive/max_width_container.dart

import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';

/// Container que limita largura máxima e centraliza conteúdo
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool centerContent;

  const MaxWidthContainer({
    Key? key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.centerContent = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultMaxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final effectiveMaxWidth = maxWidth ?? defaultMaxWidth;

    Widget content = Container(
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      padding: padding ?? ResponsiveUtils.responsivePadding(context),
      child: child,
    );

    if (centerContent && effectiveMaxWidth != double.infinity) {
      content = Center(child: content);
    }

    return content;
  }
}
```

#### ResponsiveScaffold

```dart
// lib/presentation/widgets/responsive/responsive_scaffold.dart

import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';
import 'max_width_container.dart';

/// Scaffold adaptativo que muda navegação conforme screen size
class ResponsiveScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final int? currentNavIndex;
  final Function(int)? onNavIndexChanged;
  final List<NavigationDestination>? navigationDestinations;
  final bool useMaxWidth;
  final PreferredSizeWidget? appBar;

  const ResponsiveScaffold({
    Key? key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.currentNavIndex,
    this.onNavIndexChanged,
    this.navigationDestinations,
    this.useMaxWidth = true,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    // Desktop: NavigationRail + MaxWidth content
    if (isDesktop && navigationDestinations != null) {
      return Scaffold(
        body: Row(
          children: [
            // Navigation Rail
            NavigationRail(
              selectedIndex: currentNavIndex ?? 0,
              onDestinationSelected: onNavIndexChanged,
              extended: true,
              labelType: NavigationRailLabelType.none,
              destinations: navigationDestinations!
                  .map((dest) => NavigationRailDestination(
                        icon: dest.icon,
                        selectedIcon: dest.selectedIcon ?? dest.icon,
                        label: Text(dest.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content
            Expanded(
              child: Column(
                children: [
                  // AppBar (sem back button)
                  if (appBar != null)
                    appBar!
                  else if (title != null)
                    AppBar(
                      title: Text(title!),
                      automaticallyImplyLeading: false,
                      actions: actions,
                    ),
                  // Body
                  Expanded(
                    child: useMaxWidth
                        ? MaxWidthContainer(child: body)
                        : body,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile/Tablet: Standard scaffold
    return Scaffold(
      appBar: appBar ??
          (title != null
              ? AppBar(
                  title: Text(title!),
                  actions: actions,
                )
              : null),
      body: useMaxWidth ? MaxWidthContainer(child: body) : body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: navigationDestinations != null && isMobile
          ? NavigationBar(
              selectedIndex: currentNavIndex ?? 0,
              onDestinationSelected: onNavIndexChanged,
              destinations: navigationDestinations!,
            )
          : null,
    );
  }
}
```

### 1.2 - Wrapper para Background Animado

```dart
// lib/presentation/widgets/animated_background.dart

import 'package:flutter/material.dart';

/// Wrapper para o background animado existente
/// Mantém a animação em todas as plataformas
/// Usa o AnimatedBackground que já existe no projeto
class AdaptiveBackground extends StatelessWidget {
  final Widget child;

  const AdaptiveBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usa o AnimatedBackground existente do projeto
    // que já está otimizado e funciona bem
    return Stack(
      children: [
        // Background Layer com gradiente
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
        // Content
        child,
      ],
    );
  }
}

// NOTA: Se já existe um AnimatedBackground no projeto,
// basta usar ele diretamente. Este é apenas um wrapper
// para garantir consistência caso não exista.
```

### 1.3 - Atualizar ResponsiveUtils

```dart
// lib/core/utils/responsive_utils.dart
// ADICIONAR novos métodos

class ResponsiveUtils {
  // ... métodos existentes ...

  /// Get content padding based on screen size
  static EdgeInsets getContentPadding(BuildContext context) {
    return EdgeInsets.all(valueByScreen(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    ));
  }

  /// Get card padding based on screen size
  static EdgeInsets getCardPadding(BuildContext context) {
    return EdgeInsets.all(valueByScreen(
      context: context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    ));
  }

  /// Get optimal grid columns for dashboard
  static int getDashboardColumns(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }

  /// Check if should show FAB or toolbar button
  static bool shouldShowFAB(BuildContext context) {
    return isMobile(context);
  }

  /// Get optimal chart height
  static double getChartHeight(BuildContext context) {
    return valueByScreen(
      context: context,
      mobile: 250.0,
      tablet: 300.0,
      desktop: 350.0,
    );
  }
}
```

---

## Fase 2: Home Screen (Semana 2)

### 2.1 - Refatorar Home Screen Layout

```dart
// lib/presentation/screens/home/home_screen.dart
// MODIFICAR build method

@override
Widget build(BuildContext context) {
  final isDesktop = ResponsiveUtils.isDesktop(context);
  final isMobile = ResponsiveUtils.isMobile(context);

  return ResponsiveScaffold(
    title: AppConstants.appName,
    useMaxWidth: true,
    actions: [
      if (isDesktop) _buildDesktopActions(context),
      if (isMobile) _buildMobileActions(context),
    ],
    body: AdaptiveBackground(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

            // Capital + Goals Cards: Row em desktop, Column em mobile
            ResponsiveFlexLayout(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildCapitalCard(context)),
                SizedBox(
                  width: ResponsiveUtils.getSpacing(context, multiplier: 2),
                  height: ResponsiveUtils.getSpacing(context, multiplier: 2),
                ),
                Flexible(child: _buildGoalsCard(context)),
              ],
            ),

            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 4)),

            // Quick Actions Grid: 2 cols mobile, 5 cols desktop
            _buildQuickActionsGrid(context),

            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 4)),

            // Stats Overview
            _buildStatsOverview(context),

            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 4)),

            // Active Goals
            _buildActiveGoalsSection(context),

            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),
          ],
        ),
      ),
    ),
    floatingActionButton: isMobile ? _buildFloatingActionButton(context) : null,
  );
}

Widget _buildDesktopActions(BuildContext context) {
  return Row(
    children: [
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () {
          // TODO: Implement notifications
        },
        tooltip: 'Notificações',
      ),
      const SizedBox(width: 8),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
      ),
      const SizedBox(width: 16),
      _buildUserMenu(context),
    ],
  );
}
```

### 2.2 - Adaptar Quick Actions Grid

```dart
Widget _buildQuickActionsGrid(BuildContext context) {
  final columns = ResponsiveUtils.valueByScreen(
    context: context,
    mobile: 2,
    tablet: 3,
    desktop: 5,
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Ações Rápidas',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: columns,
        mainAxisSpacing: ResponsiveUtils.getSpacing(context, multiplier: 2),
        crossAxisSpacing: ResponsiveUtils.getSpacing(context, multiplier: 2),
        childAspectRatio: ResponsiveUtils.isDesktop(context) ? 1.1 : 1.3,
        children: [
          _AnimatedQuickActionCard(
            icon: Icons.flag_rounded,
            title: 'Metas',
            accentColor: const Color(0xFF3B82F6),
            delay: 0,
            onTap: () => Navigator.pushNamed(context, '/goals'),
          ),
          // ... outros cards
        ],
      ),
    ],
  );
}
```

---

## Fase 3: Dashboard Screen (Semana 3)

### 3.1 - Refatorar Dashboard Layout

```dart
// lib/presentation/screens/dashboard/dashboard_screen.dart
// MODIFICAR build

@override
Widget build(BuildContext context) {
  final isDesktop = ResponsiveUtils.isDesktop(context);

  return ResponsiveScaffold(
    title: 'Dashboard',
    useMaxWidth: true,
    body: AdaptiveBackground(
      child: Consumer2<DashboardProvider, TransactionProvider>(
        builder: (context, dashboardProvider, transactionProvider, _) {
          // ... initialization code ...

          return RefreshIndicator(
            onRefresh: () async => _loadDashboardData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveUtils.getSpacing(context)),

                  // Summary Cards
                  _buildSummaryCards(summary, isDesktop),

                  SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 4)),

                  // Charts Grid (2x2 em desktop, vertical em mobile)
                  if (isDesktop)
                    _buildDesktopChartsGrid(dashboardProvider)
                  else
                    _buildMobileChartsList(dashboardProvider),

                  SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 4)),

                  // Goals + Insights (lado a lado em desktop)
                  if (isDesktop)
                    _buildDesktopGoalsInsights(dashboardProvider)
                  else
                    _buildMobileGoalsInsights(dashboardProvider),

                  SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildSummaryCards(DashboardSummary summary, bool isDesktop) {
  if (isDesktop) {
    // Desktop: Row com 4 cards
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Reserva Total',
            value: _currencyFormat.format(summary.totalReserve),
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF5A67D8),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 1.5)),
        Expanded(
          child: _buildSummaryCard(
            title: 'Meta Total',
            value: _currencyFormat.format(summary.totalGoalAmount),
            icon: Icons.flag,
            color: const Color(0xFF6B46C1),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 1.5)),
        Expanded(
          child: _buildSummaryCard(
            title: 'Progresso',
            value: '${summary.progressPercentage.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: const Color(0xFF48BB78),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 1.5)),
        Expanded(
          child: _buildSummaryCard(
            title: 'Saldo Mensal',
            value: _currencyFormat.format(summary.monthlyBalance),
            icon: Icons.calendar_today,
            color: summary.monthlyBalance >= 0
                ? const Color(0xFF48BB78)
                : const Color(0xFFE53E3E),
          ),
        ),
      ],
    );
  } else {
    // Mobile: Grid 2x2
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildSummaryCard(/* ... */),
        _buildSummaryCard(/* ... */),
        _buildSummaryCard(/* ... */),
        _buildSummaryCard(/* ... */),
      ],
    );
  }
}

Widget _buildDesktopChartsGrid(DashboardProvider provider) {
  return Column(
    children: [
      // Row 1: Reserve Evolution + Income vs Expenses
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitleWithFilter(
                  'Evolução da Reserva',
                  _selectedPeriod,
                  (p) => setState(() => _selectedPeriod = p!),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                _buildReserveEvolutionChart(provider),
              ],
            ),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitleWithIncomeExpensesFilter(
                  'Receitas vs Despesas',
                  _selectedIncomeExpensesPeriod,
                  (p) => setState(() => _selectedIncomeExpensesPeriod = p!),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),
                _buildIncomeExpensesChart(provider),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 4)),
      // Row 2: Category + Hourly
      Row(
        children: [
          Expanded(child: _buildCategorySpendingChart(provider)),
          SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 2)),
          Expanded(child: _buildHourlySpendingChart(provider)),
        ],
      ),
    ],
  );
}
```

---

## Fase 4: Transactions Screen (Semana 4)

### 4.1 - Adicionar Filtros Persistentes (Desktop)

```dart
// lib/presentation/screens/transactions/transactions_screen.dart

@override
Widget build(BuildContext context) {
  final isDesktop = ResponsiveUtils.isDesktop(context);

  if (isDesktop) {
    return _buildDesktopLayout();
  } else {
    return _buildMobileLayout();
  }
}

Widget _buildDesktopLayout() {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Transações'),
      actions: [
        ElevatedButton.icon(
          onPressed: _addTransaction,
          icon: const Icon(Icons.add),
          label: const Text('Nova Transação'),
        ),
        const SizedBox(width: 16),
      ],
    ),
    body: AdaptiveBackground(
      child: Row(
        children: [
          // Sidebar com filtros (esquerda - 300px)
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: _buildFilterSidebar(),
          ),
          // Content (direita - expandido)
          Expanded(
            child: MaxWidthContainer(
              maxWidth: 1000,
              child: Column(
                children: [
                  _buildSummaryCard(),
                  Expanded(
                    child: Consumer<TransactionProvider>(
                      builder: (context, provider, _) {
                        if (provider.transactions.isEmpty) {
                          return _buildEmptyState();
                        }
                        return _buildGroupedTransactionsList(
                          provider.transactions,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildFilterSidebar() {
  return Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtros',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // Período
        _buildFilterSection(
          'Período',
          DropdownButtonFormField<String>(
            value: 'all',
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Todos')),
              DropdownMenuItem(value: 'today', child: Text('Hoje')),
              DropdownMenuItem(value: 'week', child: Text('Esta semana')),
              DropdownMenuItem(value: 'month', child: Text('Este mês')),
            ],
            onChanged: (value) {
              // TODO: Aplicar filtro
            },
          ),
        ),

        const SizedBox(height: 16),

        // Tipo
        _buildFilterSection(
          'Tipo',
          Column(
            children: [
              CheckboxListTile(
                title: const Text('Receitas'),
                value: _filterType == null || _filterType == TransactionType.income,
                onChanged: (value) {
                  setState(() {
                    _filterType = value! ? TransactionType.income : null;
                  });
                  _loadTransactions();
                },
              ),
              CheckboxListTile(
                title: const Text('Despesas'),
                value: _filterType == null || _filterType == TransactionType.expense,
                onChanged: (value) {
                  setState(() {
                    _filterType = value! ? TransactionType.expense : null;
                  });
                  _loadTransactions();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Categoria
        _buildFilterSection(
          'Categoria',
          DropdownButtonFormField<String>(
            value: 'all',
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Todas')),
              // TODO: Adicionar categorias dinamicamente
            ],
            onChanged: (value) {
              // TODO: Aplicar filtro
            },
          ),
        ),

        const Spacer(),

        // Clear button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _filterType = null;
                _startDate = null;
                _endDate = null;
              });
              _loadTransactions();
            },
            child: const Text('Limpar Filtros'),
          ),
        ),
      ],
    ),
  );
}
```

### 4.2 - Usar Dialog em vez de Bottom Sheet

```dart
void _showTransactionDetails(TransactionEntity transaction) {
  final isDesktop = ResponsiveUtils.isDesktop(context);

  if (isDesktop) {
    // Desktop: Dialog centralizado
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 700,
          ),
          child: _TransactionDetailsCard(
            transaction: transaction,
            onEdit: () {
              Navigator.pop(context);
              _editTransaction(transaction);
            },
            onDelete: () {
              Navigator.pop(context);
              _deleteTransaction(transaction.id);
            },
          ),
        ),
      ),
    );
  } else {
    // Mobile: Bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailsSheet(
        transaction: transaction,
        onEdit: () => _editTransaction(transaction),
        onDelete: () => _deleteTransaction(transaction.id),
      ),
    );
  }
}
```

---

## Fase 5: Goals Screen (Semana 5)

### 5.1 - Grid Multi-Coluna

```dart
// lib/presentation/screens/goals/goals_screen.dart

Widget _buildGoalsList(GoalsScreenProvider provider) {
  final isDesktop = ResponsiveUtils.isDesktop(context);
  final columns = ResponsiveUtils.valueByScreen(
    context: context,
    mobile: 1,
    tablet: 2,
    desktop: 3,
  );

  if (isDesktop) {
    // Desktop: Grid com 3 colunas
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,  // Ajustar conforme necessário
      ),
      itemCount: provider.goals.length,
      itemBuilder: (context, index) {
        final goal = provider.goals[index];
        final tasks = provider.getTasksForGoal(goal.id);
        return GoalCard(
          goal: goal,
          index: index,
          tasks: tasks,
        );
      },
    );
  } else {
    // Mobile: Lista vertical
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.goals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final goal = provider.goals[index];
        final tasks = provider.getTasksForGoal(goal.id);
        return GoalCard(
          goal: goal,
          index: index,
          tasks: tasks,
        );
      },
    );
  }
}
```

### 5.2 - Side Panel para Detalhes (Desktop)

```dart
class _GoalsScreenState extends State<GoalsScreen> {
  String? _selectedGoalId;  // Track selected goal

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    if (isDesktop && _selectedGoalId != null) {
      // Desktop: Master-Detail layout
      return Row(
        children: [
          // Master (lista de metas) - 60%
          Expanded(
            flex: 6,
            child: _buildGoalsList(),
          ),
          // Detail (painel lateral) - 40%
          Expanded(
            flex: 4,
            child: _buildDetailPanel(_selectedGoalId!),
          ),
        ],
      );
    } else {
      // Mobile ou nada selecionado: apenas lista
      return _buildGoalsList();
    }
  }

  Widget _buildDetailPanel(String goalId) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com close button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalhes da Meta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedGoalId = null;
                    });
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: GoalDetailScreen(
              goalId: goalId,
              isEmbedded: true,  // Flag para não mostrar AppBar
            ),
          ),
        ],
      ),
    );
  }

  void _onGoalTap(String goalId) {
    if (ResponsiveUtils.isDesktop(context)) {
      // Desktop: Abre no painel lateral
      setState(() {
        _selectedGoalId = goalId;
      });
    } else {
      // Mobile: Navega para fullscreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalDetailScreen(goalId: goalId),
        ),
      );
    }
  }
}
```

---

## Fase 6: Polish e Performance (Semana 6-8)

### 6.1 - Hover States

```dart
// lib/presentation/widgets/hoverable_card.dart

import 'package:flutter/material.dart';

/// Card com hover effect para desktop
class HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? hoverColor;

  const HoverableCard({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.hoverColor,
  }) : super(key: key);

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.02))
            : Matrix4.identity(),
        child: Card(
          elevation: _isHovered ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
```

### 6.2 - Keyboard Shortcuts

```dart
// lib/presentation/widgets/keyboard_shortcuts.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onNewTransaction;
  final VoidCallback? onNewGoal;
  final VoidCallback? onSearch;

  const AppShortcuts({
    Key? key,
    required this.child,
    this.onNewTransaction,
    this.onNewGoal,
    this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        // Ctrl/Cmd + N: Nova transação
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            NewTransactionIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN):
            NewTransactionIntent(),

        // Ctrl/Cmd + G: Nova meta
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyG):
            NewGoalIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyG):
            NewGoalIntent(),

        // Ctrl/Cmd + K: Search
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            SearchIntent(),
      },
      actions: {
        NewTransactionIntent: CallbackAction<NewTransactionIntent>(
          onInvoke: (_) {
            onNewTransaction?.call();
            return null;
          },
        ),
        NewGoalIntent: CallbackAction<NewGoalIntent>(
          onInvoke: (_) {
            onNewGoal?.call();
            return null;
          },
        ),
        SearchIntent: CallbackAction<SearchIntent>(
          onInvoke: (_) {
            onSearch?.call();
            return null;
          },
        ),
      },
      child: child,
    );
  }
}

// Intents
class NewTransactionIntent extends Intent {}
class NewGoalIntent extends Intent {}
class SearchIntent extends Intent {}
```

### 6.3 - Virtual Scrolling (se necessário)

```dart
// Para listas muito longas (>100 items)
// Usar ListView.builder que já implementa lazy loading

// Se precisar de mais controle:
// https://pub.dev/packages/scrollable_positioned_list
```

---

## Testing Strategy

### 1. Responsive Testing

```dart
// test/responsive_test.dart

void main() {
  testWidgets('HomeScreen adapta layout para desktop', (tester) async {
    // Simular desktop (1920x1080)
    tester.binding.window.physicalSizeTestValue = Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verificar que NavigationRail está presente
    expect(find.byType(NavigationRail), findsOneWidget);

    // Verificar que BottomNavigationBar NÃO está presente
    expect(find.byType(NavigationBar), findsNothing);

    // Verificar grid com 5 colunas
    // ... assertions
  });

  testWidgets('HomeScreen adapta layout para mobile', (tester) async {
    // Simular mobile (375x667)
    tester.binding.window.physicalSizeTestValue = Size(375, 667);
    tester.binding.window.devicePixelRatioTestValue = 2.0;

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verificar que BottomNavigationBar está presente
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verificar que NavigationRail NÃO está presente
    expect(find.byType(NavigationRail), findsNothing);
  });
}
```

### 2. Visual Regression Testing

```dart
// Usar package: golden_toolkit
// https://pub.dev/packages/golden_toolkit

testGoldens('HomeScreen desktop layout', (tester) async {
  await tester.pumpWidgetBuilder(
    HomeScreen(),
    surfaceSize: Size(1920, 1080),
  );

  await screenMatchesGolden(tester, 'home_screen_desktop');
});
```

---

## Checklist Final

### Por Screen

- [ ] Layout responsivo implementado
- [ ] MaxWidthContainer aplicado
- [ ] Navegação adaptada (bottom bar / rail)
- [ ] Actions adaptados (FAB / toolbar)
- [ ] Modals adaptados (bottom sheet / dialog)
- [ ] Spacing responsivo
- [ ] Hover states (desktop)
- [ ] Keyboard shortcuts (desktop)
- [ ] Performance otimizada (60fps)
- [ ] Testado em 3+ resoluções
- [ ] Golden tests criados

### Global

- [ ] ResponsiveUtils completo
- [ ] AdaptiveBackground implementado
- [ ] HoverableCard criado
- [ ] AppShortcuts implementado
- [ ] ResponsiveScaffold criado
- [ ] MaxWidthContainer criado
- [ ] Documentation atualizada
- [ ] Performance benchmarks OK
- [ ] A11y compliance verificado

---

## Conclusão

Seguindo este guia, o aplicativo terá:
- ✅ Layout otimizado para desktop
- ✅ Performance melhorada
- ✅ UX apropriada para cada plataforma
- ✅ Código maintainable e testável

**Tempo estimado total**: 6-8 semanas
**Resultado esperado**: 95%+ desktop readiness
