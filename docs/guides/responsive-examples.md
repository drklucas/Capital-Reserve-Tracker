# 📱 Exemplo Prático: Tela de Transações Responsiva

## Antes vs Depois

### ❌ Antes (Código Original - Não Responsivo)

```dart
class TransactionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transações'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTransactionScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              child: ListTile(
                title: Text(transaction.description),
                subtitle: Text(transaction.date),
                trailing: Text(
                  'R\$ ${transaction.amount}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

### ✅ Depois (Código Responsivo)

```dart
import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/adaptive_navigation.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedIndex = 1; // Transactions tab

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigation(
      currentIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        // Navigate to other screens based on index
      },
      destinations: [
        AdaptiveNavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        AdaptiveNavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Transações',
        ),
        AdaptiveNavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Dashboard',
        ),
      ],
      title: 'Transações',
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ResponsiveLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com filtros
          _buildHeader(context),

          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

          // Lista de transações
          Expanded(
            child: _buildTransactionsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ResponsiveFlexLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Título e filtros (em mobile fica empilhado)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minhas Transações',
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
            SizedBox(height: ResponsiveUtils.getSpacing(context)),
            _buildFilters(context),
          ],
        ),

        // Botão adicionar (responsivo)
        AdaptiveButton(
          label: ResponsiveUtils.isMobile(context) ? 'Novo' : 'Nova Transação',
          icon: Icons.add,
          isPrimary: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddTransactionScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return ResponsiveWidget(
      // Mobile: Dropdown compacto
      mobile: DropdownButton<String>(
        value: _selectedFilter,
        items: ['Todas', 'Receitas', 'Despesas']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) {
          setState(() => _selectedFilter = value!);
        },
      ),

      // Desktop: Chip filters
      desktop: Wrap(
        spacing: ResponsiveUtils.getSpacing(context),
        children: [
          FilterChip(
            label: Text('Todas'),
            selected: _selectedFilter == 'Todas',
            onSelected: (_) => setState(() => _selectedFilter = 'Todas'),
          ),
          FilterChip(
            label: Text('Receitas'),
            selected: _selectedFilter == 'Receitas',
            onSelected: (_) => setState(() => _selectedFilter = 'Receitas'),
          ),
          FilterChip(
            label: Text('Despesas'),
            selected: _selectedFilter == 'Despesas',
            onSelected: (_) => setState(() => _selectedFilter = 'Despesas'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    // Decide o layout baseado no tamanho da tela
    if (ResponsiveUtils.isMobile(context)) {
      return _buildMobileList(context);
    } else if (ResponsiveUtils.isTablet(context)) {
      return _buildTabletGrid(context);
    } else {
      return _buildDesktopTable(context);
    }
  }

  // Layout Mobile: Lista vertical
  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: transactions.length,
      separatorBuilder: (_, __) => SizedBox(
        height: ResponsiveUtils.getSpacing(context),
      ),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return AdaptiveCard(
          onTap: () => _showTransactionDetails(transaction),
          child: Row(
            children: [
              // Ícone
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: transaction.isIncome
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),

              SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 1.5)),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction.category,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      transaction.formattedDate,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Valor
              Text(
                transaction.formattedAmount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Layout Tablet: Grid 2 colunas
  Widget _buildTabletGrid(BuildContext context) {
    return ResponsiveGridView(
      tabletColumns: 2,
      spacing: ResponsiveUtils.getSpacing(context, multiplier: 2),
      runSpacing: ResponsiveUtils.getSpacing(context, multiplier: 2),
      childAspectRatio: 2.5,
      children: transactions.map((transaction) {
        return AdaptiveCard(
          onTap: () => _showTransactionDetails(transaction),
          child: Row(
            children: [
              // Ícone maior para tablet
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: transaction.isIncome
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                  size: 28,
                ),
              ),

              SizedBox(width: ResponsiveUtils.getSpacing(context, multiplier: 2)),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${transaction.category} • ${transaction.formattedDate}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      transaction.formattedAmount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: transaction.isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Layout Desktop: Tabela
  Widget _buildDesktopTable(BuildContext context) {
    return SingleChildScrollView(
      child: AdaptiveCard(
        padding: EdgeInsets.zero,
        child: DataTable(
          headingRowHeight: 56,
          dataRowHeight: 64,
          columns: [
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Descrição')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Data')),
            DataColumn(label: Text('Valor'), numeric: true),
            DataColumn(label: Text('Ações')),
          ],
          rows: transactions.map((transaction) {
            return DataRow(
              cells: [
                DataCell(
                  Icon(
                    transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: transaction.isIncome ? Colors.green : Colors.red,
                  ),
                ),
                DataCell(
                  Text(
                    transaction.description,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(
                  Chip(
                    label: Text(
                      transaction.category,
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                DataCell(Text(transaction.formattedDate)),
                DataCell(
                  Text(
                    transaction.formattedAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transaction.isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: () => _editTransaction(transaction),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _deleteTransaction(transaction),
                        tooltip: 'Excluir',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    AdaptiveDialog.show(
      context: context,
      title: 'Detalhes da Transação',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Descrição', transaction.description),
          _buildDetailRow('Categoria', transaction.category),
          _buildDetailRow('Data', transaction.formattedDate),
          _buildDetailRow('Valor', transaction.formattedAmount),
          if (transaction.note != null)
            _buildDetailRow('Observação', transaction.note!),
        ],
      ),
      actions: [
        AdaptiveButton(
          label: 'Fechar',
          isPrimary: false,
          onPressed: () => Navigator.pop(context),
        ),
        AdaptiveButton(
          label: 'Editar',
          isPrimary: true,
          icon: Icons.edit,
          onPressed: () {
            Navigator.pop(context);
            _editTransaction(transaction);
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getSpacing(context, multiplier: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editTransaction(Transaction transaction) {
    // Implementar edição
  }

  void _deleteTransaction(Transaction transaction) {
    // Implementar exclusão
  }
}
```

## 📊 Comparação Visual

### Mobile (< 600px)
```
┌─────────────────────┐
│  Minhas Transações  │
│  [Filtro Dropdown]  │
│  [Botão Novo]       │
├─────────────────────┤
│ ┌─────────────────┐ │
│ │ 💰 Salário      │ │
│ │ Trabalho        │ │
│ │ 01/01/2024      │ │
│ │         R$ 5000 │ │
│ └─────────────────┘ │
│ ┌─────────────────┐ │
│ │ 🛒 Compras      │ │
│ │ Alimentação     │ │
│ │ 02/01/2024      │ │
│ │        -R$ 200  │ │
│ └─────────────────┘ │
└─────────────────────┘
```

### Tablet (600-900px)
```
┌──────────────────────────────────────┐
│ ╔═══════╗  Minhas Transações         │
│ ║ Home  ║  [Chip: Todas] [Receitas]  │
│ ║Trans. ║  [Nova Transação →]        │
│ ╚═══════╝                            │
├──────────────────────────────────────┤
│ ┌────────────┐  ┌────────────┐      │
│ │ 💰 Salário │  │ 🛒 Compras │      │
│ │ Trabalho   │  │ Alimentação│      │
│ │ R$ 5000    │  │ -R$ 200    │      │
│ └────────────┘  └────────────┘      │
└──────────────────────────────────────┘
```

### Desktop (> 900px)
```
┌──────────────────────────────────────────────────────────┐
│ ╔══════════╗  CAPITAL RESERVE TRACKER                    │
│ ║ Home     ║ ┌──────────────────────────────────────┐   │
│ ║ Transações║ │ Tipo│Descrição│Categoria│Data │Valor│   │
│ ║ Dashboard║ ├──────────────────────────────────────┤   │
│ ║ Metas    ║ │ ↑  │Salário  │Trabalho│01/01│5000 │   │
│ ╚══════════╝ │ ↓  │Compras  │Comida  │02/01│-200 │   │
│              └──────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

## 🎯 Benefícios Alcançados

### ✅ User Experience
- **Mobile**: Lista compacta e fácil de rolar
- **Tablet**: Grid para aproveitar espaço horizontal
- **Desktop**: Tabela com todas as informações visíveis

### ✅ Performance
- Renderização otimizada para cada plataforma
- Lazy loading automático com ListView.builder
- Grid responsivo com aspect ratio correto

### ✅ Manutenibilidade
- Código reutilizável com componentes adaptativos
- Fácil de testar em diferentes tamanhos
- Separação clara de responsabilidades

### ✅ Acessibilidade
- Touch targets adequados para mobile
- Hover states para desktop
- Navegação por teclado suportada

## 🔄 Passos para Refatoração

1. **Identificar componentes fixos** (AppBar, BottomNav, etc.)
2. **Substituir por componentes adaptativos** (AdaptiveNavigation)
3. **Aplicar ResponsiveLayout** no conteúdo principal
4. **Criar layouts específicos** por plataforma
5. **Testar em todos os tamanhos** de tela
6. **Ajustar espaçamentos e fontes** responsivos

## 📝 Notas Importantes

- Sempre use `ResponsiveUtils` para valores dinâmicos
- Teste em dispositivos reais quando possível
- Considere orientação landscape/portrait
- Otimize imagens para cada tamanho
- Implemente lazy loading para listas grandes
