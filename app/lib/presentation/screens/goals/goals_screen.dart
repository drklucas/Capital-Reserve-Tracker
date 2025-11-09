import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/goals_screen_provider.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/goal_card.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

/// Goals screen displaying list of user's financial goals
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AppAuthProvider>();
      if (authProvider.user != null) {
        final userId = authProvider.user!.id;
        // GoalsScreenProvider gerencia suas próprias metas e tarefas
        context.read<GoalsScreenProvider>().watchGoals(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Minhas Metas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 22,
              tablet: 24,
              desktop: 26,
            ),
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 20),
            ),
            onPressed: () => _navigateToAddGoal(context),
            tooltip: 'Adicionar Meta',
          ),
          const SizedBox(width: 8),
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
            child: Consumer<GoalsScreenProvider>(
              builder: (context, goalsScreenProvider, child) {
                if (goalsScreenProvider.isLoadingGoals) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (goalsScreenProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.white70),
                        const SizedBox(height: 16),
                        Text(
                          goalsScreenProvider.error ?? 'Erro ao carregar metas',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            final authProvider = context.read<AppAuthProvider>();
                            if (authProvider.user != null) {
                              goalsScreenProvider.watchGoals(authProvider.user!.id);
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (goalsScreenProvider.goals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Nenhuma meta cadastrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crie sua primeira meta financeira!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddGoal(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Criar Meta'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final authProvider = context.read<AppAuthProvider>();
                    if (authProvider.user != null) {
                      goalsScreenProvider.watchGoals(authProvider.user!.id);
                    }
                  },
                  color: const Color(0xFF3B82F6),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ResponsiveLayout(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2.5)),

                          // Summary Card - usando GoalsScreenProvider
                          _buildSummaryCard(goalsScreenProvider),

                          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 3)),

                          // Goals List Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Suas Metas',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.responsiveFontSize(
                                    context,
                                    mobile: 20,
                                    tablet: 22,
                                    desktop: 24,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${goalsScreenProvider.goals.length} ${goalsScreenProvider.goals.length == 1 ? 'meta' : 'metas'}',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.responsiveFontSize(
                                    context,
                                    mobile: 13,
                                    tablet: 14,
                                    desktop: 15,
                                  ),
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2)),

                          // Goals Grid (instead of list for better responsive layout)
                          _buildGoalsGrid(goalsScreenProvider),

                          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 10)), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToAddGoal(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Nova Meta',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsGrid(GoalsScreenProvider goalsScreenProvider) {
    final columns = ResponsiveUtils.valueByScreen(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: ResponsiveUtils.getSpacing(context, multiplier: 2),
        mainAxisSpacing: ResponsiveUtils.getSpacing(context, multiplier: 2),
        childAspectRatio: ResponsiveUtils.valueByScreen(
          context: context,
          mobile: 1.0,
          tablet: 0.95,
          desktop: 0.9,
        ),
      ),
      itemCount: goalsScreenProvider.goals.length,
      itemBuilder: (context, index) {
        final goal = goalsScreenProvider.goals[index];
        final tasks = goalsScreenProvider.getTasksForGoal(goal.id);
        return GoalCard(
          goal: goal,
          index: index,
          tasks: tasks,
        );
      },
    );
  }

  Widget _buildSummaryCard(GoalsScreenProvider goalsScreenProvider) {
    return Container(
      padding: ResponsiveUtils.getCardPadding(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2d3561),
            Color(0xFF1f2544),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo Geral',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 2.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Ativas',
                goalsScreenProvider.activeGoals.length.toString(),
                Colors.blue,
                Icons.flag,
              ),
              _buildSummaryItem(
                'Concluídas',
                goalsScreenProvider.completedGoals.length.toString(),
                Colors.green,
                Icons.check_circle,
              ),
              _buildSummaryItem(
                'Tarefas',
                '${goalsScreenProvider.completedTasksForActiveGoals}/${goalsScreenProvider.totalTasksForActiveGoals}',
                Colors.orange,
                Icons.task_alt,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(
            ResponsiveUtils.getSpacing(context, multiplier: 1.5),
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveUtils.valueByScreen(
              context: context,
              mobile: 22,
              tablet: 24,
              desktop: 26,
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, multiplier: 0.5)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 11,
              tablet: 12,
              desktop: 13,
            ),
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }


  void _navigateToAddGoal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );
  }
}
