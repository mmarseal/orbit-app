import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<GoalModel>> getGoals(String userId) {
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GoalModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addGoal(GoalModel goal) async {
    await _firestore
        .collection('goals')
        .doc(goal.id)
        .set(goal.toFirestore());
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _firestore
        .collection('goals')
        .doc(goal.id)
        .update(goal.toFirestore());
  }

  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection('goals').doc(goalId).delete();
  }

  Future<void> toggleMilestone(GoalModel goal, String milestoneId) async {
    final updatedMilestones = goal.milestones.map((m) {
      if (m.id == milestoneId) {
        return GoalMilestone(
          id: m.id,
          title: m.title,
          isCompleted: !m.isCompleted,
        );
      }
      return m;
    }).toList();

    final updatedGoal = GoalModel(
      id: goal.id,
      userId: goal.userId,
      title: goal.title,
      targetDate: goal.targetDate,
      milestones: updatedMilestones,
      createdAt: goal.createdAt,
    );

    await updateGoal(updatedGoal);
  }
}

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

final goalsStreamProvider = StreamProvider<List<GoalModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(goalRepositoryProvider);
  return repository.getGoals(uid);
});
