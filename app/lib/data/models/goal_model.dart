import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goal_entity.dart';

/// Goal data model for Firestore serialization
///
/// This model handles conversion between Firestore documents and domain entities.
/// It includes methods for JSON and Firestore serialization/deserialization.
class GoalModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int targetAmount;
  final int currentAmount;
  final DateTime startDate;
  final DateTime targetDate;
  final String status;
  final List<String> associatedTransactionIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int colorIndex;

  GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.targetDate,
    required this.status,
    required this.associatedTransactionIds,
    required this.createdAt,
    this.updatedAt,
    this.colorIndex = -1,
  });

  /// Convert model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'status': status,
      'associatedTransactionIds': associatedTransactionIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'colorIndex': colorIndex,
    };
  }

  /// Create model from Firestore document
  factory GoalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return GoalModel(
      id: snapshot.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      targetAmount: data['targetAmount'] as int,
      currentAmount: data['currentAmount'] as int,
      startDate: (data['startDate'] as Timestamp).toDate(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      status: data['status'] as String,
      associatedTransactionIds:
          (data['associatedTransactionIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      colorIndex: data['colorIndex'] as int? ?? -1,
    );
  }

  /// Create model from Firestore map (for queries)
  factory GoalModel.fromMap(String id, Map<String, dynamic> data) {
    return GoalModel(
      id: id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      targetAmount: data['targetAmount'] as int,
      currentAmount: data['currentAmount'] as int,
      startDate: (data['startDate'] as Timestamp).toDate(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      status: data['status'] as String,
      associatedTransactionIds:
          (data['associatedTransactionIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      colorIndex: data['colorIndex'] as int? ?? -1,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'status': status,
      'associatedTransactionIds': associatedTransactionIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'colorIndex': colorIndex,
    };
  }

  /// Create model from JSON
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetAmount: json['targetAmount'] as int,
      currentAmount: json['currentAmount'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      status: json['status'] as String,
      associatedTransactionIds:
          (json['associatedTransactionIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      colorIndex: json['colorIndex'] as int? ?? -1,
    );
  }

  /// Convert model to domain entity
  GoalEntity toEntity() {
    return GoalEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      startDate: startDate,
      targetDate: targetDate,
      status: GoalStatus.fromString(status),
      associatedTransactionIds: associatedTransactionIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      colorIndex: colorIndex,
    );
  }

  /// Create model from domain entity
  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      startDate: entity.startDate,
      targetDate: entity.targetDate,
      status: entity.status.name,
      associatedTransactionIds: entity.associatedTransactionIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      colorIndex: entity.colorIndex,
    );
  }

  /// Create a copy of this model with updated fields
  GoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? targetAmount,
    int? currentAmount,
    DateTime? startDate,
    DateTime? targetDate,
    String? status,
    List<String>? associatedTransactionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? colorIndex,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      associatedTransactionIds:
          associatedTransactionIds ?? this.associatedTransactionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
