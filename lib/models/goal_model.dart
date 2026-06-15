import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class GoalMilestone {
  final String id;
  final String title;
  final bool isCompleted;

  GoalMilestone({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory GoalMilestone.fromMap(Map<String, dynamic> map) {
    return GoalMilestone(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}


class GoalModel {
  final String id;
  final String userId;
  final String title;
  final DateTime targetDate;
  final List<GoalMilestone> milestones;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    this.userId = '',
    required this.title,
    required this.targetDate,
    this.milestones = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progressPercentage {
    if (milestones.isEmpty) return 0;
    final completed = milestones.where((m) => m.isCompleted).length;
    return (completed / milestones.length) * 100;
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawMilestones = data['milestones'] as List<dynamic>? ?? [];

    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      targetDate: data['target_date'] != null
          ? (data['target_date'] as Timestamp).toDate()
          : DateTime.now(),
      milestones: rawMilestones
          .map((m) => GoalMilestone.fromMap(m as Map<String, dynamic>))
          .toList(),
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'target_date': Timestamp.fromDate(targetDate),
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
