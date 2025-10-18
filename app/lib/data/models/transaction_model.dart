import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

/// Transaction model for data layer with Firestore serialization
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.description,
    required super.date,
    required super.category,
    super.goalId,
    required super.userId,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create TransactionModel from TransactionEntity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      type: entity.type,
      amount: entity.amount,
      description: entity.description,
      date: entity.date,
      category: entity.category,
      goalId: entity.goalId,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create TransactionModel from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      type: _parseTransactionType(data['type'] as String),
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] as String,
      date: (data['date'] as Timestamp).toDate(),
      category: _parseTransactionCategory(data['category'] as String),
      goalId: data['goalId'] as String?,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create TransactionModel from JSON map
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: _parseTransactionType(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      category: _parseTransactionCategory(json['category'] as String),
      goalId: json['goalId'] as String?,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'category': category.name,
      'goalId': goalId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category.name,
      'goalId': goalId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      type: type,
      amount: amount,
      description: description,
      date: date,
      category: category,
      goalId: goalId,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with updated fields
  @override
  TransactionModel copyWith({
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
    return TransactionModel(
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

  /// Parse TransactionType from string
  static TransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        throw ArgumentError('Invalid transaction type: $type');
    }
  }

  /// Parse TransactionCategory from string
  static TransactionCategory _parseTransactionCategory(String category) {
    switch (category.toLowerCase()) {
      // Income categories
      case 'salary':
        return TransactionCategory.salary;
      case 'bonus':
        return TransactionCategory.bonus;
      case 'investment':
        return TransactionCategory.investment;
      case 'freelance':
        return TransactionCategory.freelance;
      case 'gift':
        return TransactionCategory.gift;
      case 'other':
        return TransactionCategory.other;

      // Expense categories
      case 'food':
        return TransactionCategory.food;
      case 'transport':
        return TransactionCategory.transport;
      case 'housing':
        return TransactionCategory.housing;
      case 'utilities':
        return TransactionCategory.utilities;
      case 'entertainment':
        return TransactionCategory.entertainment;
      case 'healthcare':
        return TransactionCategory.healthcare;
      case 'education':
        return TransactionCategory.education;
      case 'shopping':
        return TransactionCategory.shopping;
      case 'savings':
        return TransactionCategory.savings;

      default:
        throw ArgumentError('Invalid transaction category: $category');
    }
  }
}
