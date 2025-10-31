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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
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

          // Content
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
                            _buildGreetingSection(context, greeting, authProvider),

                            const SizedBox(height: 32),

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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5A67D8),
                        Color(0xFF6B46C1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5A67D8).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                            Icon(
                              Icons.history,
                              color: Colors.white.withOpacity(0.7),
                              size: 20,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receitas',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(totalIncome),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Despesas',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(totalExpense),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF06B6D4),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                                const Icon(
                                  Icons.flag_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
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
                              color: Colors.white.withOpacity(0.7),
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
                                  backgroundColor: Colors.white.withOpacity(0.2),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
              ),
              delay: 0,
              onTap: () => Navigator.pushNamed(context, '/goals'),
            ),
            _AnimatedQuickActionCard(
              icon: Icons.add_card_rounded,
              title: 'Nova Transação',
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              delay: 100,
              onTap: () => Navigator.pushNamed(context, '/add-transaction'),
            ),
            _AnimatedQuickActionCard(
              icon: Icons.history_rounded,
              title: 'Histórico',
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
              delay: 200,
              onTap: () => Navigator.pushNamed(context, '/transactions'),
            ),
            _AnimatedQuickActionCard(
              icon: Icons.analytics_rounded,
              title: 'Dashboard',
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
              ),
              delay: 300,
              onTap: () => Navigator.pushNamed(context, AppConstants.dashboardRoute),
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

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2d3561),
                Color(0xFF1f2544),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                return GoalCard(goal: goal, index: index, tasks: tasks);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
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
  final Gradient gradient;
  final VoidCallback onTap;
  final int delay;

  const _AnimatedQuickActionCard({
    required this.icon,
    required this.title,
    required this.gradient,
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.gradient.colors.first.withOpacity(0.3),
                        blurRadius: _isPressed ? 10 : 15,
                        offset: Offset(0, _isPressed ? 3 : 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
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
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
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

