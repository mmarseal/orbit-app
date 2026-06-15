import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String course;
  final DateTime deadline;
  final int difficulty; 
  final String weight; 
  final String? notes;
  final String status; 
  final int orbitScore; 
  final DateTime idealStartDate;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    this.userId = '',
    required this.title,
    required this.course,
    required this.deadline,
    required this.difficulty,
    required this.weight,
    this.notes,
    required this.status,
    required this.orbitScore,
    required this.idealStartDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

 

  factory TaskModel.withSmartDefaults({
    required String id,
    String userId = '',
    required String title,
    required String course,
    required DateTime deadline,
    required int difficulty,
    required String weight,
    String? notes,
    String status = 'orbiting',
  }) {
    final score = _calculateOrbitScore(
      difficulty: difficulty,
      weight: weight,
      deadline: deadline,
    );
    final startDate = _calculateIdealStartDate(
      difficulty: difficulty,
      weight: weight,
      deadline: deadline,
    );

    return TaskModel(
      id: id,
      userId: userId,
      title: title,
      course: course,
      deadline: deadline,
      difficulty: difficulty,
      weight: weight,
      notes: notes,
      status: status,
      orbitScore: score,
      idealStartDate: startDate,
      createdAt: DateTime.now(),
    );
  }

  /// Orbit Score formula (0–100):
  ///   • Urgency   → max 50 pts (linear scale over 14 days)
  ///   • Impact    → max 30 pts (based on weight string)
  ///   • Difficulty → max 20 pts (difficulty / 10 × 20)
  static int _calculateOrbitScore({
    required int difficulty,
    required String weight,
    required DateTime deadline,
  }) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;
    double urgency;
    if (daysLeft <= 0) {
      urgency = 50.0;
    } else if (daysLeft >= 14) {
      urgency = 0.0;
    } else {
      urgency = 50.0 - (daysLeft * 50.0 / 14.0);
    }

    double impact;
    switch (weight) {
      case 'Besar':
        impact = 30.0;
        break;
      case 'Sedang':
        impact = 20.0;
        break;
      case 'Kecil':
        impact = 10.0;
        break;
      default:
        impact = 0.0;
        break;
    }

    final difficultyScore = (difficulty / 10.0) * 20.0;

    return (urgency + impact + difficultyScore).round().clamp(0, 100);
  }

  /// Ideal start date:
  ///   Base = difficulty days before deadline
  ///   Buffer: +2 if 'Besar', +1 if 'Sedang', +0 if 'Kecil'
  ///   idealStartDate = deadline − (difficulty + buffer) days
  static DateTime _calculateIdealStartDate({
    required int difficulty,
    required String weight,
    required DateTime deadline,
  }) {
    int bufferDays;
    switch (weight) {
      case 'Besar':
        bufferDays = 2;
        break;
      case 'Sedang':
        bufferDays = 1;
        break;
      default:
        bufferDays = 0;
        break;
    }

    return deadline.subtract(Duration(days: difficulty + bufferDays));
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      course: data['course'] ?? '',
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : DateTime.now(),
      difficulty: (data['difficulty'] as num?)?.toInt() ?? 5,
      weight: data['weight'] ?? 'Sedang',
      notes: data['notes'],
      status: data['status'] ?? 'orbiting',
      orbitScore: (data['orbit_score'] as num?)?.toInt() ?? 0,
      idealStartDate: data['ideal_start_date'] != null
          ? (data['ideal_start_date'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'course': course,
      'deadline': Timestamp.fromDate(deadline),
      'difficulty': difficulty,
      'weight': weight,
      'notes': notes,
      'status': status,
      'orbit_score': orbitScore,
      'ideal_start_date': Timestamp.fromDate(idealStartDate),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}