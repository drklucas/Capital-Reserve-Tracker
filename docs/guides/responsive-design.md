# 🎨 Guia Completo de Responsividade Multi-Plataforma

## 📱 Visão Geral

Este guia mostra como adaptar o aplicativo Capital Reserve Tracker para ser verdadeiramente responsivo em todas as plataformas (Web Mobile, Web Desktop, Android, iOS).

## 🔧 Sistema de Breakpoints

### Breakpoints Definidos
```dart
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: 900px - 1200px
- Large Desktop: > 1200px
```

## 🚀 Como Usar

### 1. Detecção de Tamanho de Tela

```dart
import 'package:app/core/utils/responsive_utils.dart';

// Verificar tipo de tela
bool isMobile = ResponsiveUtils.isMobile(context);
bool isTablet = ResponsiveUtils.isTablet(context);
bool isDesktop = ResponsiveUtils.isDesktop(context);

// Obter tipo de tela
ScreenType screenType = ResponsiveUtils.getScreenType(context);
```

### 2. Valores Responsivos

```dart
// Retornar valores diferentes por tamanho de tela
double padding = ResponsiveUtils.valueByScreen(
  context: context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
  largeDesktop: 48.0,
);

// Font sizes responsivos
double fontSize = ResponsiveUtils.responsiveFontSize(
  context,
  mobile: 14.0,
  tablet: 16.0,
  desktop: 18.0,
);
```

### 3. Widgets Responsivos

#### ResponsiveWidget
```dart
ResponsiveWidget(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

#### ResponsiveLayout
```dart
ResponsiveLayout(
  child: YourContent(),
  // Centraliza conteúdo em telas grandes
  // Aplica padding responsivo automaticamente
)
```

#### ResponsiveGridView
```dart
ResponsiveGridView(
  children: items.map((item) => ItemCard(item)).toList(),
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
  spacing: 16,
)
```

#### ResponsiveFlexLayout
```dart
ResponsiveFlexLayout(
  // Column em mobile, Row em desktop
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
)
```

### 4. Navegação Adaptativa

```dart
import 'package:app/presentation/widgets/adaptive_navigation.dart';

AdaptiveNavigation(
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
    AdaptiveNavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Dashboard',
    ),
    // ... mais destinos
  ],
  child: YourScreen(),
  title: 'App Title',
)
```

**Comportamento:**
- **Mobile**: Bottom Navigation Bar
- **Tablet/Desktop**: Navigation Rail (sidebar)
- **Large Desktop**: Navigation Rail expandida

### 5. Componentes Adaptativos

#### AdaptiveCard
```dart
AdaptiveCard(
  child: YourCardContent(),
  onTap: () {},
  // Elevation e border radius ajustam automaticamente
)
```

#### AdaptiveButton
```dart
AdaptiveButton(
  label: 'Salvar',
  icon: Icons.save,
  isPrimary: true,
  isLoading: isLoading,
  onPressed: () {},
  // Padding responsivo automático
)
```

#### AdaptiveTextField
```dart
AdaptiveTextField(
  label: 'Email',
  hint: 'Digite seu email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  // Font size e padding responsivos
)
```

#### AdaptiveDialog
```dart
AdaptiveDialog.show(
  context: context,
  title: 'Confirmar',
  content: Text('Deseja continuar?'),
  actions: [
    TextButton(
      child: Text('Cancelar'),
      onPressed: () => Navigator.pop(context),
    ),
    ElevatedButton(
      child: Text('Confirmar'),
      onPressed: () {
        // Ação
        Navigator.pop(context);
      },
    ),
  ],
);
```

## 📐 Exemplo Prático: Refatorar uma Tela

### Antes (Não Responsivo)
```dart
class MyScreen extends StatelessWidget {
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
                child: Text('Conteúdo'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [...],
      ),
    );
  }
}
```

### Depois (Responsivo)
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigation(
      currentIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: _destinations,
      title: 'Título',
      child: ResponsiveLayout(
        child: Column(
          children: [
            AdaptiveCard(
              child: Text('Conteúdo'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🎯 Exemplos de Layout por Plataforma

### Dashboard com Gráficos

#### Mobile (< 600px)
```dart
Column(
  children: [
    ChartWidget1(), // Full width
    ChartWidget2(), // Full width
    ChartWidget3(), // Full width
  ],
)
```

#### Tablet (600-900px)
```dart
ResponsiveGridView(
  tabletColumns: 2,
  children: [
    ChartWidget1(), // 50% width
    ChartWidget2(), // 50% width
    ChartWidget3(), // 50% width
  ],
)
```

#### Desktop (> 900px)
```dart
ResponsiveGridView(
  desktopColumns: 3,
  children: [
    ChartWidget1(), // 33% width
    ChartWidget2(), // 33% width
    ChartWidget3(), // 33% width
  ],
)
```

## 🔍 Dicas de Otimização

### 1. Lazy Loading em Grids
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveUtils.getGridColumns(context),
  ),
  itemBuilder: (context, index) => YourWidget(),
)
```

### 2. Imagens Responsivas
```dart
Image.network(
  imageUrl,
  width: ResponsiveUtils.valueByScreen(
    context: context,
    mobile: 150,
    tablet: 200,
    desktop: 250,
  ),
)
```

### 3. Espaçamento Responsivo
```dart
SizedBox(
  height: ResponsiveUtils.getSpacing(context, multiplier: 2),
)
```

### 4. Tamanho de Fonte Responsivo
```dart
Text(
  'Título',
  style: TextStyle(
    fontSize: ResponsiveUtils.responsiveFontSize(
      context,
      mobile: 18,
      tablet: 22,
      desktop: 26,
    ),
  ),
)
```

## 📊 Exemplo: Adaptar Dashboard Screen

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header adaptativo
            _buildHeader(context),

            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

            // Cards em grid responsivo
            ResponsiveGridView(
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 3,
              children: [
                _buildIncomeCard(context),
                _buildExpenseCard(context),
                _buildBalanceCard(context),
              ],
            ),

            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),

            // Gráficos
            ResponsiveFlexLayout(
              children: [
                Expanded(child: _buildPieChart(context)),
                Expanded(child: _buildLineChart(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ResponsiveFlexLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        AdaptiveButton(
          label: 'Adicionar',
          icon: Icons.add,
          onPressed: () {},
        ),
      ],
    );
  }
}
```

## 🎨 Exemplo: Form Responsivo

```dart
class ResponsiveForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      child: Form(
        child: Column(
          children: [
            // Em mobile: 1 coluna
            // Em tablet/desktop: 2 colunas
            ResponsiveFlexLayout(
              children: [
                AdaptiveTextField(
                  label: 'Nome',
                  controller: nameController,
                ),
                AdaptiveTextField(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

            AdaptiveTextField(
              label: 'Descrição',
              controller: descriptionController,
              maxLines: 5,
            ),

            SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),

            // Botões responsivos
            ResponsiveFlexLayout(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AdaptiveButton(
                  label: 'Cancelar',
                  isPrimary: false,
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context)),
                AdaptiveButton(
                  label: 'Salvar',
                  isPrimary: true,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🌐 Considerações para Web

### 1. Limitar Largura Máxima
```dart
ResponsiveLayout(
  child: YourContent(),
  // Centraliza e limita largura em telas grandes
)
```

### 2. Usar Hover States (Desktop)
```dart
MouseRegion(
  onEnter: (_) => setState(() => isHovered = true),
  onExit: (_) => setState(() => isHovered = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: isHovered ? Colors.blue : Colors.white,
    ),
    child: YourContent(),
  ),
)
```

### 3. Suportar Atalhos de Teclado
```dart
Focus(
  onKey: (node, event) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _handleSubmit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  },
  child: YourWidget(),
)
```

## ✅ Checklist de Responsividade

- [ ] Usar `ResponsiveUtils` para valores baseados em tamanho de tela
- [ ] Implementar `AdaptiveNavigation` para navegação
- [ ] Usar `ResponsiveLayout` para limitar largura em desktops
- [ ] Aplicar `ResponsiveGridView` para listas/grids
- [ ] Usar componentes adaptativos (`AdaptiveCard`, `AdaptiveButton`, etc.)
- [ ] Testar em diferentes resoluções (mobile, tablet, desktop)
- [ ] Verificar orientação landscape/portrait
- [ ] Otimizar imagens para diferentes tamanhos
- [ ] Implementar lazy loading quando necessário
- [ ] Adicionar hover states para web desktop
- [ ] Suportar atalhos de teclado (web)
- [ ] Testar com diferentes fontes/zoom do navegador

## 🎯 Próximos Passos

1. **Refatorar telas existentes** usando os componentes adaptativos
2. **Testar em diferentes dispositivos** e tamanhos de tela
3. **Otimizar performance** em grids grandes
4. **Adicionar animações** suaves entre layouts
5. **Implementar temas** dark/light responsivos
6. **Criar snapshots** de testes para cada breakpoint

## 📚 Referências

- [Flutter Responsive Design](https://docs.flutter.dev/development/ui/layout/responsive)
- [Material Design Breakpoints](https://material.io/design/layout/responsive-layout-grid.html)
- [Adaptive Design](https://flutter.dev/docs/development/ui/layout/adaptive-responsive)
