import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../providers/goal_provider.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  static const _bgColor = Color(0xFF0A0A0F);
  static const _cardColor = Color(0xFF161625);
  static const _accentPurple = Color(0xFF7C4DFF);
  static const _greenAccent = Color(0xFF69F0AE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // --- Header ---
              _buildHeader(),
              const SizedBox(height: 28),
              // --- Stats ---
              tasksAsync.when(
                data: (tasks) => _buildTaskStats(tasks),
                loading: () => _buildLoadingCard(),
                error: (e, _) => _buildErrorCard(e),
              ),
              const SizedBox(height: 20),
              goalsAsync.when(
                data: (goals) => _buildGoalStats(goals),
                loading: () => _buildLoadingCard(),
                error: (e, _) => _buildErrorCard(e),
              ),
              const SizedBox(height: 20),
              // --- Combined overview ---
              tasksAsync.when(
                data: (tasks) => _buildWeeklyOverview(tasks),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // HEADER
  // ========================================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Kamu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pantau pencapaianmu',
              style: TextStyle(
                color: Color(0xFF7C7C9A),
                fontSize: 13,
              ),
            ),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.analytics_outlined,
              color: Colors.white70, size: 20),
        ),
      ],
    );
  }

  // ========================================
  // TASK STATS
  // ========================================

  Widget _buildTaskStats(List<TaskModel> tasks) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.status == 'completed').length;
    final active = total - completed;
    final completionRate =
        total > 0 ? ((completed / total) * 100).round() : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.task_alt_rounded,
                    color: _accentPurple, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistik Tugas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress ring + numbers
          Row(
            children: [
              // Circular chart
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: total > 0 ? completed / total : 0,
                        strokeWidth: 8,
                        backgroundColor: _accentPurple.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            _accentPurple),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$completionRate%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Stats columns
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('Total Tugas', '$total',
                        Icons.layers_rounded, Colors.white70),
                    const SizedBox(height: 10),
                    _buildStatRow('Selesai', '$completed',
                        Icons.check_circle_rounded, _greenAccent),
                    const SizedBox(height: 10),
                    _buildStatRow('Aktif', '$active',
                        Icons.radio_button_checked_rounded, _accentPurple),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ========================================
  // GOAL STATS
  // ========================================

  Widget _buildGoalStats(List<GoalModel> goals) {
    final total = goals.length;
    final achieved = goals.where((g) => g.progressPercentage >= 100).length;
    final avgProgress = total > 0
        ? (goals.fold<double>(0, (sum, g) => sum + g.progressPercentage) / total).round()
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFAB40).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flag_rounded,
                    color: Color(0xFFFFAB40), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistik Tujuan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGoalStatCard(
                  'Total',
                  '$total',
                  Icons.flag_outlined,
                  _accentPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalStatCard(
                  'Tercapai',
                  '$achieved',
                  Icons.emoji_events_rounded,
                  _greenAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalStatCard(
                  'Rata-rata',
                  '$avgProgress%',
                  Icons.speed_rounded,
                  const Color(0xFFFFAB40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // WEEKLY OVERVIEW
  // ========================================

  Widget _buildWeeklyOverview(List<TaskModel> tasks) {
    // Count tasks completed per day of the current week (Mon–Sun)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    final dayCounts = List<int>.filled(7, 0);
    for (final t in tasks) {
      if (t.status == 'completed') {
        final diff = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day)
            .difference(DateTime(monday.year, monday.month, monday.day))
            .inDays;
        if (diff >= 0 && diff < 7) {
          dayCounts[diff]++;
        }
      }
    }
    final maxCount = dayCounts.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _greenAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: _greenAccent, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Aktivitas Minggu Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar chart
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final fraction = dayCounts[i] / maxCount;
                final isToday = i == (now.weekday - 1);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (dayCounts[i] > 0)
                          Text(
                            '${dayCounts[i]}',
                            style: TextStyle(
                              color: isToday ? _accentPurple : Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: (fraction * 80).clamp(6.0, 80.0),
                          decoration: BoxDecoration(
                            color: isToday
                                ? _accentPurple
                                : _accentPurple.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            color:
                                isToday ? Colors.white : Colors.grey[600],
                            fontSize: 11,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // HELPERS
  // ========================================

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _accentPurple),
      ),
    );
  }

  Widget _buildErrorCard(Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
      ),
    );
  }
}
