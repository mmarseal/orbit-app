import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/task_repository.dart';
import '../models/task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasks(uid);
});