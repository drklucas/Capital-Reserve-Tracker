import 'package:equatable/equatable.dart';

/// Transaction type enumeration
enum TransactionType {
  income,
  expense,
}

/// Transaction category enumeration
enum TransactionCategory {
  // Income categories
  salary,
  bonus,
  investment,
  freelance,
  gift,
  other,

  // Expense categories
  food,
  transport,
  housing,
  utilities,
  entertainment,
  healthcare,
  education,
  shopping,
  savings,
}

/// Transaction entity representing a financial transaction in the domain layer
class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionCategory category;
  final String? goalId; // Optional association with a goal
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    this.goalId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if transaction is income
  bool get isIncome => type == TransactionType.income;

  /// Check if transaction is expense
  bool get isExpense => type == TransactionType.expense;

  /// Check if transaction is associated with a goal
  bool get hasGoal => goalId != null && goalId!.isNotEmpty;

  /// Get signed amount (positive for income, negative for expense)
  double get signedAmount => isIncome ? amount : -amount;

  /// Copy with method for creating modified copies
  TransactionEntity copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    TransactionCategory? category,
    String? goalId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        description,
        date,
        category,
        goalId,
        userId,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'TransactionEntity(id: $id, type: $type, amount: $amount, '
        'description: $description, date: $date, category: $category, '
        'goalId: $goalId, userId: $userId)';
  }
}

/// Extension for TransactionType to get display names
extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
    }
  }
}

/// Extension for TransactionCategory to get display names and icons
extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      // Income
      case TransactionCategory.salary:
        return 'Salário';
      case TransactionCategory.bonus:
        return 'Bônus';
      case TransactionCategory.investment:
        return 'Investimento';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.gift:
        return 'Presente';
      case TransactionCategory.other:
        return 'Outro';

      // Expense
      case TransactionCategory.food:
        return 'Alimentação';
      case TransactionCategory.transport:
        return 'Transporte';
      case TransactionCategory.housing:
        return 'Moradia';
      case TransactionCategory.utilities:
        return 'Utilidades';
      case TransactionCategory.entertainment:
        return 'Entretenimento';
      case TransactionCategory.healthcare:
        return 'Saúde';
      case TransactionCategory.education:
        return 'Educação';
      case TransactionCategory.shopping:
        return 'Compras';
      case TransactionCategory.savings:
        return 'Poupança';
    }
  }

  String get iconName {
    switch (this) {
      // Income
      case TransactionCategory.salary:
        return 'payments';
      case TransactionCategory.bonus:
        return 'card_giftcard';
      case TransactionCategory.investment:
        return 'trending_up';
      case TransactionCategory.freelance:
        return 'work';
      case TransactionCategory.gift:
        return 'redeem';
      case TransactionCategory.other:
        return 'more_horiz';

      // Expense
      case TransactionCategory.food:
        return 'restaurant';
      case TransactionCategory.transport:
        return 'directions_car';
      case TransactionCategory.housing:
        return 'home';
      case TransactionCategory.utilities:
        return 'bolt';
      case TransactionCategory.entertainment:
        return 'movie';
      case TransactionCategory.healthcare:
        return 'local_hospital';
      case TransactionCategory.education:
        return 'school';
      case TransactionCategory.shopping:
        return 'shopping_cart';
      case TransactionCategory.savings:
        return 'savings';
    }
  }

  bool get isIncomeCategory {
    return [
      TransactionCategory.salary,
      TransactionCategory.bonus,
      TransactionCategory.investment,
      TransactionCategory.freelance,
      TransactionCategory.gift,
      TransactionCategory.other,
    ].contains(this);
  }

  bool get isExpenseCategory => !isIncomeCategory;
}
