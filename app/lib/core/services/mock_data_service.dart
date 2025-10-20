import 'dart:math';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/task_entity.dart';

/// Service to generate mock data for testing and demo purposes
class MockDataService {
  final Random _random = Random();

  /// Generate one year of transactions with variety
  List<TransactionEntity> generateYearTransactions(String userId) {
    final transactions = <TransactionEntity>[];
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

    // Generate monthly salary (income)
    for (int month = 0; month < 12; month++) {
      final salaryDate = DateTime(
        oneYearAgo.year,
        oneYearAgo.month + month,
        5, // Salary on the 5th of each month
      );

      // Main salary
      transactions.add(TransactionEntity(
        id: 'mock_salary_${month}_1',
        userId: userId,
        amount: 5000 + _random.nextDouble() * 2000, // R$ 5000-7000
        type: TransactionType.income,
        category: TransactionCategory.salary,
        description: 'Salário mensal',
        date: salaryDate,
        createdAt: salaryDate,
        updatedAt: salaryDate,
      ));

      // Random freelance income (30% chance each month)
      if (_random.nextDouble() < 0.3) {
        final freelanceDate = DateTime(
          oneYearAgo.year,
          oneYearAgo.month + month,
          10 + _random.nextInt(15),
        );
        transactions.add(TransactionEntity(
          id: 'mock_freelance_$month',
          userId: userId,
          amount: 500 + _random.nextDouble() * 2500, // R$ 500-3000
          type: TransactionType.income,
          category: TransactionCategory.freelance,
          description: 'Projeto freelance',
          date: freelanceDate,
          createdAt: freelanceDate,
          updatedAt: freelanceDate,
        ));
      }
    }

    // Generate daily/weekly expenses
    DateTime currentDate = oneYearAgo;
    int transactionId = 0;

    while (currentDate.isBefore(now)) {
      // 2-5 transactions per week
      final transactionsThisWeek = 2 + _random.nextInt(4);

      for (int i = 0; i < transactionsThisWeek; i++) {
        final dayOffset = _random.nextInt(7);
        final transactionDate = currentDate.add(Duration(days: dayOffset));

        if (transactionDate.isAfter(now)) break;

        final categoryData = _getRandomExpenseCategory();
        final amount = categoryData['amount'] as double;
        final description = categoryData['description'] as String;
        final category = categoryData['category'] as TransactionCategory;

        transactions.add(TransactionEntity(
          id: 'mock_expense_${transactionId++}',
          userId: userId,
          amount: amount,
          type: TransactionType.expense,
          category: category,
          description: description,
          date: transactionDate,
          createdAt: transactionDate,
          updatedAt: transactionDate,
        ));
      }

      currentDate = currentDate.add(const Duration(days: 7));
    }

    // Add some investment income (quarterly)
    for (int quarter = 0; quarter < 4; quarter++) {
      final investmentDate = DateTime(
        oneYearAgo.year,
        oneYearAgo.month + (quarter * 3),
        20,
      );

      if (investmentDate.isBefore(now)) {
        transactions.add(TransactionEntity(
          id: 'mock_investment_$quarter',
          userId: userId,
          amount: 200 + _random.nextDouble() * 800, // R$ 200-1000
          type: TransactionType.income,
          category: TransactionCategory.investment,
          description: 'Rendimento de investimentos',
          date: investmentDate,
          createdAt: investmentDate,
          updatedAt: investmentDate,
        ));
      }
    }

    return transactions;
  }

  /// Generate diverse goals with different statuses and timeframes
  List<GoalEntity> generateGoals(String userId) {
    final now = DateTime.now();
    final goals = <GoalEntity>[];

    // Goal 1: Long-term active goal (1 year)
    goals.add(GoalEntity(
      id: 'mock_goal_1',
      userId: userId,
      title: 'Reserva de Emergência',
      description: 'Construir uma reserva de emergência de 6 meses de despesas',
      targetAmount: 30000,
      currentAmount: 18500,
      startDate: DateTime(now.year, 1, 1),
      targetDate: DateTime(now.year, 12, 31),
      status: GoalStatus.active,
      associatedTransactionIds: [],
      createdAt: DateTime(now.year, 1, 1),
      updatedAt: now,
    ));

    // Goal 2: Medium-term active goal (6 months)
    goals.add(GoalEntity(
      id: 'mock_goal_2',
      userId: userId,
      title: 'Viagem para Europa',
      description: 'Economizar para uma viagem de férias pela Europa',
      targetAmount: 15000,
      currentAmount: 8200,
      startDate: DateTime(now.year, now.month - 3, 1),
      targetDate: DateTime(now.year, now.month + 3, 30),
      status: GoalStatus.active,
      associatedTransactionIds: [],
      createdAt: DateTime(now.year, now.month - 3, 1),
      updatedAt: now,
    ));

    // Goal 3: Short-term active goal (3 months)
    goals.add(GoalEntity(
      id: 'mock_goal_3',
      userId: userId,
      title: 'Novo Notebook',
      description: 'Comprar um notebook para trabalho',
      targetAmount: 5000,
      currentAmount: 3800,
      startDate: DateTime(now.year, now.month - 1, 1),
      targetDate: DateTime(now.year, now.month + 2, 30),
      status: GoalStatus.active,
      associatedTransactionIds: [],
      createdAt: DateTime(now.year, now.month - 1, 1),
      updatedAt: now,
    ));

    // Goal 4: Completed goal
    goals.add(GoalEntity(
      id: 'mock_goal_4',
      userId: userId,
      title: 'Curso de Desenvolvimento',
      description: 'Investir em educação com curso online',
      targetAmount: 2000,
      currentAmount: 2000,
      startDate: DateTime(now.year - 1, 10, 1),
      targetDate: DateTime(now.year - 1, 12, 31),
      status: GoalStatus.completed,
      associatedTransactionIds: [],
      createdAt: DateTime(now.year - 1, 10, 1),
      updatedAt: DateTime(now.year - 1, 12, 31),
    ));

    // Goal 5: Paused goal
    goals.add(GoalEntity(
      id: 'mock_goal_5',
      userId: userId,
      title: 'Investimento em Ações',
      description: 'Começar a investir em ações da bolsa',
      targetAmount: 10000,
      currentAmount: 2500,
      startDate: DateTime(now.year, now.month - 2, 1),
      targetDate: DateTime(now.year + 1, now.month, 30),
      status: GoalStatus.paused,
      associatedTransactionIds: [],
      createdAt: DateTime(now.year, now.month - 2, 1),
      updatedAt: DateTime(now.year, now.month - 1, 15),
    ));

    return goals;
  }

  /// Generate tasks for goals
  List<TaskEntity> generateTasksForGoals(List<GoalEntity> goals, String userId) {
    final tasks = <TaskEntity>[];
    int taskId = 0;

    for (var goal in goals) {
      // Only generate tasks for active goals
      if (goal.status != GoalStatus.active) continue;

      final taskCount = 5 + _random.nextInt(8); // 5-12 tasks per goal
      final now = DateTime.now();

      for (int i = 0; i < taskCount; i++) {
        final isCompleted = _random.nextDouble() < 0.4; // 40% completed
        final priority = _getRandomPriority();
        final createdAt = goal.startDate.add(Duration(days: i * 3));

        tasks.add(TaskEntity(
          id: 'mock_task_${taskId++}',
          userId: userId,
          goalId: goal.id,
          title: _getTaskTitleForGoal(goal.title, i),
          description: _getTaskDescription(goal.title, i),
          isCompleted: isCompleted,
          priority: priority,
          dueDate: goal.targetDate.subtract(Duration(days: taskCount - i)),
          completedAt: isCompleted ? createdAt.add(Duration(days: _random.nextInt(10))) : null,
          createdAt: createdAt,
          updatedAt: isCompleted ? createdAt.add(Duration(days: _random.nextInt(10))) : createdAt,
        ));
      }
    }

    return tasks;
  }

  // Helper methods

  Map<String, dynamic> _getRandomExpenseCategory() {
    final categories = [
      {
        'category': TransactionCategory.food,
        'amount': 20 + _random.nextDouble() * 150,
        'descriptions': ['Supermercado', 'Restaurante', 'Lanche', 'Delivery', 'Padaria', 'Feira'],
      },
      {
        'category': TransactionCategory.transport,
        'amount': 10 + _random.nextDouble() * 100,
        'descriptions': ['Uber', 'Gasolina', 'Estacionamento', 'Metrô', 'Ônibus', 'Pedágio'],
      },
      {
        'category': TransactionCategory.entertainment,
        'amount': 30 + _random.nextDouble() * 200,
        'descriptions': ['Cinema', 'Show', 'Livros', 'Jogos', 'Streaming', 'Viagem fim de semana'],
      },
      {
        'category': TransactionCategory.healthcare,
        'amount': 50 + _random.nextDouble() * 300,
        'descriptions': ['Farmácia', 'Consulta médica', 'Exames', 'Academia', 'Dentista'],
      },
      {
        'category': TransactionCategory.education,
        'amount': 100 + _random.nextDouble() * 500,
        'descriptions': ['Curso online', 'Livros técnicos', 'Material de estudo', 'Workshop', 'Certificação'],
      },
      {
        'category': TransactionCategory.housing,
        'amount': 500 + _random.nextDouble() * 1500,
        'descriptions': ['Aluguel', 'Condomínio', 'IPTU', 'Manutenção', 'Móveis'],
      },
      {
        'category': TransactionCategory.shopping,
        'amount': 50 + _random.nextDouble() * 300,
        'descriptions': ['Roupas', 'Sapatos', 'Acessórios', 'Eletrônicos'],
      },
      {
        'category': TransactionCategory.utilities,
        'amount': 100 + _random.nextDouble() * 400,
        'descriptions': ['Internet', 'Energia', 'Água', 'Telefone', 'Gás', 'Assinaturas'],
      },
    ];

    final categoryData = categories[_random.nextInt(categories.length)];
    final descriptions = categoryData['descriptions'] as List<String>;

    return {
      'category': categoryData['category'],
      'amount': categoryData['amount'],
      'description': descriptions[_random.nextInt(descriptions.length)],
    };
  }

  int _getRandomPriority() {
    final priorities = [1, 2, 3, 4, 5];
    final weights = [0.2, 0.3, 0.3, 0.15, 0.05]; // Low to high priority distribution

    final rand = _random.nextDouble();
    double cumulative = 0;

    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (rand < cumulative) {
        return priorities[i];
      }
    }

    return 3; // Default medium priority
  }

  String _getTaskTitleForGoal(String goalTitle, int index) {
    final taskTemplates = {
      'Reserva de Emergência': [
        'Definir valor mensal de economia',
        'Abrir conta poupança separada',
        'Cortar gastos supérfluos',
        'Automatizar transferências',
        'Revisar progresso mensal',
        'Buscar renda extra',
        'Vender itens não utilizados',
        'Renegociar contas fixas',
      ],
      'Viagem para Europa': [
        'Pesquisar passagens aéreas',
        'Reservar hospedagem',
        'Solicitar visto/passaporte',
        'Comprar seguro viagem',
        'Planejar roteiro',
        'Reservar passeios',
        'Trocar moeda',
        'Fazer check-in online',
      ],
      'Novo Notebook': [
        'Pesquisar modelos disponíveis',
        'Comparar preços',
        'Ler reviews',
        'Verificar garantia',
        'Escolher loja confiável',
        'Aguardar promoção',
        'Realizar compra',
        'Configurar sistema',
      ],
    };

    for (var key in taskTemplates.keys) {
      if (goalTitle.contains(key)) {
        final tasks = taskTemplates[key]!;
        return tasks[index % tasks.length];
      }
    }

    return 'Tarefa ${index + 1} - $goalTitle';
  }

  String _getTaskDescription(String goalTitle, int index) {
    return 'Descrição detalhada da tarefa relacionada a: $goalTitle';
  }
}
