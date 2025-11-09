import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../core/utils/widget_updater.dart';
import '../../providers/auth_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/home_screen_provider.dart';
import '../../widgets/goal_card.dart';
import '../ai/ai_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _backgroundAnimation;

  // Period selection for stats overview
  int _selectedPeriodIndex = 2; // 0 = Hoje, 1 = Semana, 2 = Mês

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = context.read<AppAuthProvider>();
    if (authProvider.user != null) {
      debugPrint('HomeScreen: Loading data for user ${authProvider.user!.id}');
      context.read<HomeScreenProvider>().watchGoals(authProvider.user!.id);
      context.read<TransactionProvider>().watchTransactions(userId: authProvider.user!.id);

      // Atualizar widgets da home screen após carregar os dados
      debugPrint('HomeScreen: Agendando atualização de widgets em 3 segundos...');
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          debugPrint('HomeScreen: Chamando WidgetUpdater.updateWidgets...');
          WidgetUpdater.updateWidgets(context);
        } else {
          debugPrint('HomeScreen: Widget não montado, pulando atualização');
        }
      });
    } else {
      debugPrint('HomeScreen: User is null, waiting for auth...');
      // Try again after a short delay if user is not ready yet
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _loadUserData();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: AppBar(
              backgroundColor: Colors.transparent, 
              elevation: 0,
              title: Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.notifications_outlined, size: 20),
                  ),
                  onPressed: () {
                    // TODO: Implement notifications
                  },
                ),
                const SizedBox(width: 8),
                Consumer<AppAuthProvider>(
                  builder: (context, authProvider, _) {
                    return PopupMenuButton<String>(
                      child: Hero(
                        tag: 'user_avatar',
                        child: GestureDetector(
                          onLongPress: () {
                            // Hidden feature: show mock data option on long press
                            _showMockDataDialog(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF5A67D8),
                              child: Text(
                                authProvider.userInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onSelected: (value) async {
                        switch (value) {
                          case 'profile':
                            // TODO: Navigate to profile
                            break;
                          case 'settings':
                            // TODO: Navigate to settings
                            break;
                          case 'logout':
                            await authProvider.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                AppConstants.loginRoute,
                              );
                            }
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline),
                              SizedBox(width: 8),
                              Text('Perfil'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_outlined),
                              SizedBox(width: 8),
                              Text('Configurações'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text('Sair'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated Background Layer (separated from content)
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Much Darker Background for liquid glass contrast
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF020308), // Almost pure black with hint of blue
                          Color(0xFF050510), // Pure dark
                          Color(0xFF0A0618), // Very dark purple-black
                          Color(0xFF050B15), // Very dark blue-black
                        ],
                        stops: [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Animated Purple glow - Top Right (MUITO VISÍVEL)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            0.3 + (0.8 * _backgroundAnimation.value),
                            -0.5 - (0.6 * _backgroundAnimation.value),
                          ),
                          radius: 1.2,
                          colors: [
                            const Color(0xFF8B5CF6).withOpacity(0.25), // Purple mais sutil
                            const Color(0xFF6B46C1).withOpacity(0.15), // Purple leve
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Animated Deep blue accent - Top Center (MUITO VISÍVEL)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            -0.4 + (0.8 * _backgroundAnimation.value),
                            -0.3 + (0.6 * _backgroundAnimation.value),
                          ),
                          radius: 1.5,
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.22), // Blue mais sutil
                            const Color(0xFF2563EB).withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Animated Violet glow - Bottom Left (MUITO VISÍVEL)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            -0.5 - (0.8 * _backgroundAnimation.value),
                            0.3 + (0.8 * _backgroundAnimation.value),
                          ),
                          radius: 1.4,
                          colors: [
                            const Color(0xFF9333EA).withOpacity(0.24), // Violet mais sutil
                            const Color(0xFF7C3AED).withOpacity(0.14), // Purple leve
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Animated Pink-purple accent - Center Right (MUITO VISÍVEL)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            0.2 + (0.9 * _backgroundAnimation.value),
                            -0.4 + (0.8 * _backgroundAnimation.value),
                          ),
                          radius: 1.6,
                          colors: [
                            const Color(0xFFD946EF).withOpacity(0.20), // Magenta mais sutil
                            const Color(0xFFA855F7).withOpacity(0.12), // Purple-pink leve
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Animated additional deep blue - Bottom Right (MUITO VISÍVEL)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                            0.6 - (0.7 * _backgroundAnimation.value),
                            0.4 - (0.7 * _backgroundAnimation.value),
                          ),
                          radius: 1.3,
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.23), // Blue royal mais sutil
                            const Color(0xFF2563EB).withOpacity(0.13),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Content Layer (not affected by animation rebuilds)
          SafeArea(
            child: Consumer<AppAuthProvider>(
              builder: (context, authProvider, _) {
                final greeting = DateTimeUtils.getGreeting();

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Greeting Section
                            // _buildGreetingSection(context, greeting, authProvider),

                            // const SizedBox(height: 32),

                            // Capital Card
                            _buildCapitalCard(context),

                            const SizedBox(height: 16),

                            // Goals Card
                            _buildGoalsCard(context),

                            const SizedBox(height: 32),

                            // Quick Actions Grid
                            _buildQuickActionsGrid(context),

                            const SizedBox(height: 32),

                            // Stats Overview
                            _buildStatsOverview(context),

                            const SizedBox(height: 32),

                            // Active Goals Cards
                            _buildActiveGoalsSection(context),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildGreetingSection(BuildContext context, String greeting, AppAuthProvider authProvider) {
    // Get display name with fallback
    final displayName = authProvider.user?.displayName ??
                       authProvider.user?.email ??
                       (authProvider.isLoading ? 'Carregando...' : 'Usuário');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCapitalCard(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
        final transactions = transactionProvider.transactions;

        // Calculate balance from transactions
        double totalIncome = 0;
        double totalExpense = 0;

        for (var transaction in transactions) {
          if (transaction.isIncome) {
            totalIncome += transaction.amount;
          } else if (transaction.isExpense) {
            totalExpense += transaction.amount;
          }
        }

        final balance = totalIncome - totalExpense;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/transactions'),
                borderRadius: BorderRadius.circular(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        // Thin, subtle border (purple/indigo from capital theme)
                        border: Border.all(
                          color: const Color(0xFF5A67D8).withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5A67D8).withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 3),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Reserva de Capital',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.history,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currencyFormat.format(balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              balance >= 0 ? 'Saldo disponível' : 'Saldo negativo',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMiniStat(
                                    'Receitas',
                                    currencyFormat.format(totalIncome),
                                    Icons.trending_up,
                                    Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMiniStat(
                                    'Despesas',
                                    currencyFormat.format(totalExpense),
                                    Icons.trending_down,
                                    Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Thin, subtle border with color
            border: Border.all(
              color: color.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 3),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context) {
    return Consumer<HomeScreenProvider>(
      builder: (context, homeProvider, _) {
        final activeGoals = homeProvider.activeGoals;
        final hasGoals = activeGoals.isNotEmpty;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/goals'),
                borderRadius: BorderRadius.circular(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        // Thin, subtle border (blue/cyan from goals theme)
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 3),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.flag_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      hasGoals
                                          ? '${activeGoals.length} Meta${activeGoals.length != 1 ? 's' : ''} Ativa${activeGoals.length != 1 ? 's' : ''}'
                                          : 'Nenhuma meta definida',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 16,
                                ),
                              ],
                            ),
                            if (hasGoals) ...[
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progresso Geral',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    homeProvider.totalTasksForActiveGoals > 0
                                        ? '${homeProvider.completedTasksForActiveGoals}/${homeProvider.totalTasksForActiveGoals} tarefas'
                                        : 'Sem tarefas',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: homeProvider.activeGoalsTaskProgress),
                                  duration: const Duration(milliseconds: 1500),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, animValue, child) {
                                    return LinearProgressIndicator(
                                      value: animValue,
                                      minHeight: 6,
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              Text(
                                'Crie sua primeira meta',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
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
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _AnimatedQuickActionCard(
              icon: Icons.flag_rounded,
              title: 'Metas',
              accentColor: const Color(0xFF3B82F6),
              delay: 0,
              onTap: () => Navigator.pushNamed(context, '/goals'),
            ),
            _AnimatedQuickActionCard(
              icon: Icons.add_card_rounded,
              title: 'Nova Transação',
              accentColor: const Color(0xFF10B981),
              delay: 100,
              onTap: () => Navigator.pushNamed(context, '/add-transaction'),
            ),
            _AnimatedQuickActionCard(
              icon: Icons.history_rounded,
              title: 'Histórico',
              accentColor: const Color(0xFFF59E0B),
              delay: 200,
              onTap: () => Navigator.pushNamed(context, '/transactions'),
            ),
            _AnimatedQuickActionCard(
              icon: Icons.analytics_rounded,
              title: 'Dashboard',
              accentColor: const Color(0xFF8B5CF6),
              delay: 300,
              onTap: () => Navigator.pushNamed(context, AppConstants.dashboardRoute),
            ),
            _AnimatedQuickActionCard(
              icon: Icons.psychology_rounded,
              title: 'Assistente IA',
              accentColor: const Color(0xFFEC4899),
              delay: 400,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIHomeScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    return Consumer2<TransactionProvider, GoalProvider>(
      builder: (context, transactionProvider, goalProvider, _) {
        final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
        final now = DateTime.now();

        // Filter transactions based on selected period
        final filteredTransactions = transactionProvider.transactions.where((transaction) {
          final transactionDate = DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          );
          final today = DateTime(now.year, now.month, now.day);

          switch (_selectedPeriodIndex) {
            case 0: // Hoje
              return transactionDate.isAtSameMomentAs(today);
            case 1: // Semana (últimos 7 dias incluindo hoje)
              final weekAgo = today.subtract(const Duration(days: 6));
              return !transactionDate.isBefore(weekAgo) &&
                     !transactionDate.isAfter(today);
            case 2: // Mês (mês atual)
              return transaction.date.year == now.year &&
                  transaction.date.month == now.month;
            default:
              return true;
          }
        }).toList();

        // Calculate income and expenses for filtered period
        double totalIncome = 0;
        double totalExpense = 0;

        for (var transaction in filteredTransactions) {
          if (transaction.isIncome) {
            totalIncome += transaction.amount;
          } else if (transaction.isExpense) {
            totalExpense += transaction.amount;
          }
        }

        final balance = totalIncome - totalExpense;
        final transactionCount = filteredTransactions.length;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // Thin, subtle border (purple from stats theme)
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title
                  const Text(
                    'Visão Geral',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Period selector tabs
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _PeriodTab(
                                label: 'Hoje',
                                isSelected: _selectedPeriodIndex == 0,
                                onTap: () {
                                  setState(() {
                                    _selectedPeriodIndex = 0;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _PeriodTab(
                                label: 'Semana',
                                isSelected: _selectedPeriodIndex == 1,
                                onTap: () {
                                  setState(() {
                                    _selectedPeriodIndex = 1;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _PeriodTab(
                                label: 'Mês',
                                isSelected: _selectedPeriodIndex == 2,
                                onTap: () {
                                  setState(() {
                                    _selectedPeriodIndex = 2;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          icon: Icons.trending_up,
                          label: 'Receitas',
                          value: currencyFormat.format(totalIncome),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.trending_down,
                          label: 'Despesas',
                          value: currencyFormat.format(totalExpense),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          icon: Icons.account_balance_wallet,
                          label: 'Saldo',
                          value: currencyFormat.format(balance),
                          color: balance >= 0 ? Colors.blue : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.receipt_long,
                          label: 'Transações',
                          value: transactionCount.toString(),
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveGoalsSection(BuildContext context) {
    return Consumer<HomeScreenProvider>(
      builder: (context, homeScreenProvider, _) {
        final activeGoals = homeScreenProvider.activeGoals;

        if (activeGoals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Metas Ativas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/goals'),
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: activeGoals.length > 3 ? 3 : activeGoals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = activeGoals[index];
                final tasks = homeScreenProvider.getTasksForGoal(goal.id);
                return GoalCard(
                  goal: goal,
                  index: index,
                  tasks: tasks,
                  useGlassEffect: true, // Apply glass effect only on HomeScreen
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.8),
                const Color(0xFF059669).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/add-transaction');
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.white,
            ),
            label: const Text(
              'Adicionar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hidden feature: populate mock data
  void _showMockDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1f2544),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.science, color: Colors.amber),
              SizedBox(width: 12),
              Text(
                'Modo Demo',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deseja popular o banco de dados com dados fictícios de demonstração?',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Isso irá criar:',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 1 ano de transações variadas',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '• 5 metas com diferentes status',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '• Tarefas para cada meta',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _populateMockData(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Popular Dados'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _populateMockData(BuildContext context) async {
    final authProvider = context.read<AppAuthProvider>();
    final goalProvider = context.read<GoalProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final taskProvider = context.read<TaskProvider>();

    if (authProvider.user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final userId = authProvider.user!.id;

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(
            child: Card(
              color: Color(0xFF1f2544),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      'Criando dados de demonstração...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    try {
      final mockService = MockDataService();

      // Generate mock data
      debugPrint('MockData: Generating transactions...');
      final transactions = mockService.generateYearTransactions(userId);

      debugPrint('MockData: Generating goals...');
      final goals = mockService.generateGoals(userId);

      debugPrint('MockData: Generating tasks...');
      final tasks = mockService.generateTasksForGoals(goals, userId);

      // Save transactions
      debugPrint('MockData: Saving ${transactions.length} transactions...');
      for (var transaction in transactions) {
        final success = await transactionProvider.createTransaction(
          userId: transaction.userId,
          type: transaction.type,
          amount: transaction.amount,
          description: transaction.description,
          date: transaction.date,
          category: transaction.category,
        );
        if (!success) {
          debugPrint('MockData: Failed to create transaction');
        }
      }

      // Save goals
      debugPrint('MockData: Saving ${goals.length} goals...');
      for (var goal in goals) {
        final success = await goalProvider.createGoal(goal);
        if (!success) {
          debugPrint('MockData: Failed to create goal');
        }
      }

      // Wait a bit for goals to be created
      await Future.delayed(const Duration(milliseconds: 500));

      // Save tasks
      debugPrint('MockData: Saving ${tasks.length} tasks...');
      for (var task in tasks) {
        final success = await taskProvider.createTask(
          userId: task.userId,
          goalId: task.goalId,
          title: task.title,
          description: task.description,
          priority: task.priority,
          dueDate: task.dueDate,
        );
        if (!success) {
          debugPrint('MockData: Failed to create task');
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dados criados com sucesso!\n'
              '${transactions.length} transações, ${goals.length} metas, ${tasks.length} tarefas',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      debugPrint('MockData: All data created successfully!');
    } catch (e) {
      debugPrint('MockData: Error creating mock data: $e');

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar dados: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _AnimatedQuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final VoidCallback onTap;
  final int delay;

  const _AnimatedQuickActionCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_AnimatedQuickActionCard> createState() => _AnimatedQuickActionCardState();
}

class _AnimatedQuickActionCardState extends State<_AnimatedQuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Delayed entrance animation
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + widget.delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTapDown: (_) {
                  _controller.forward();
                  setState(() => _isPressed = true);
                },
                onTapUp: (_) {
                  _controller.reverse();
                  setState(() => _isPressed = false);
                  widget.onTap();
                },
                onTapCancel: () {
                  _controller.reverse();
                  setState(() => _isPressed = false);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        // Thin, subtle border with accent color
                        border: Border.all(
                          color: widget.accentColor.withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor.withOpacity(_isPressed ? 0.1 : 0.15),
                            blurRadius: _isPressed ? 10 : 15,
                            offset: Offset(0, _isPressed ? 2 : 3),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.accentColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Thin, subtle border with stat color
            border: Border.all(
              color: color.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 3),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
