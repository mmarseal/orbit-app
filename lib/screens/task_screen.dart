import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  static const _bgColor = Color(0xFF0A0A0F);
  static const _cardColor = Color(0xFF161625);
  static const _accentPurple = Color(0xFF7C4DFF);
  static const _greenAccent = Color(0xFF69F0AE);

  static const _dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  static const _dayNamesFull = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];
  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns true if date [a] is on the same day or after date [b] (day-level).
  static bool _isSameOrAfter(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return !da.isBefore(db);
  }

  /// Returns true if date [a] is on the same day or before date [b] (day-level).
  static bool _isSameOrBefore(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return !da.isAfter(db);
  }

  static String _formatHeaderDate(DateTime date) {
    return '${_dayNamesFull[date.weekday % 7]}, ${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  // ========================================
  // Task completion toggle
  // ========================================

  void _toggleTaskCompletion(TaskModel task) {
    final newStatus = task.status == 'completed' ? 'orbiting' : 'completed';
    ref.read(taskRepositoryProvider).updateTask(
      TaskModel(
        id: task.id,
        userId: task.userId,
        title: task.title,
        course: task.course,
        deadline: task.deadline,
        difficulty: task.difficulty,
        weight: task.weight,
        notes: task.notes,
        status: newStatus,
        orbitScore: task.orbitScore,
        idealStartDate: task.idealStartDate,
        createdAt: task.createdAt,
      ),
    );
  }

  // ========================================
  // BUILD
  // ========================================

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // --- Header ---
              _buildHeader(),
              const SizedBox(height: 20),
              // --- Date Strip ---
              _buildDateStrip(),
              const SizedBox(height: 24),
              // --- Nightly Question Card ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildNightlyCard(),
              ),
              const SizedBox(height: 28),
              // --- Daily Priority Flow ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPriorityFlowSection(tasksAsync),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rencana Hari Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: Colors.white70, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatHeaderDate(_selectedDate),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // DATE STRIP
  // ========================================

  Widget _buildDateStrip() {
    final today = DateTime.now();
    final dates = List.generate(
      11,
      (i) {
        final d = today.add(Duration(days: i - 5));
        return DateTime(d.year, d.month, d.day);
      },
    );

    const itemWidth = 58.0;
    final initialIndex =
        dates.indexWhere((d) => _isSameDay(d, _selectedDate));
    final controller = ScrollController(
      initialScrollOffset:
          (initialIndex >= 0 ? initialIndex : 5) * itemWidth - 100,
    );

    return SizedBox(
      height: 86,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, today);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: itemWidth,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? _accentPurple : _cardColor,
                borderRadius: BorderRadius.circular(18),
                border: isToday && !isSelected
                    ? Border.all(
                        color: _accentPurple.withOpacity(0.4), width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayNames[date.weekday % 7],
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 20,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isToday)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : _accentPurple,
                      ),
                    )
                  else
                    const SizedBox(height: 5),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ========================================
  // NIGHTLY CARD
  // ========================================

  Widget _buildNightlyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1040), Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _accentPurple.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accentPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('🌙', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          // Text + Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pertanyaan Malam',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Apa rencana produktifmu untuk besok?',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: _accentPurple,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _accentPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Buat Rencana Besok',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // DAILY PRIORITY FLOW SECTION
  // ========================================

  Widget _buildPriorityFlowSection(AsyncValue<List<TaskModel>> tasksAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prioritas Hari Ini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded,
                      color: Colors.grey[500], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Orbit Score',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Task cards
        tasksAsync.when(
          data: (allTasks) {
            final filtered = allTasks.where((t) {
              final start = t.idealStartDate;
              return _isSameOrAfter(_selectedDate, start) &&
                     _isSameOrBefore(_selectedDate, t.deadline);
            }).toList()
              ..sort((a, b) => b.orbitScore.compareTo(a.orbitScore));

            if (filtered.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: filtered.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTaskCard(task),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: _accentPurple),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Error: $err',
                  style: const TextStyle(color: Colors.redAccent)),
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // EMPTY STATE
  // ========================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available_rounded,
              color: Colors.grey[700], size: 44),
          const SizedBox(height: 14),
          Text(
            'Tidak ada tugas untuk hari ini.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan tugas dari halaman Beranda.',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ========================================
  // TASK CARD (standalone, no timeline line)
  // ========================================

  Widget _buildTaskCard(TaskModel task) {
    final isCompleted = task.status == 'completed';
    final hasNotes = task.notes != null && task.notes!.isNotEmpty;
    final deadlineStr =
        '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}';

    return GestureDetector(
      onTap: () => _toggleTaskCompletion(task),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? _greenAccent.withOpacity(0.08)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Course tag + Orbit Score + Checkmark
            Row(
              children: [
                // Course tag
                _buildTag(task.course, _accentPurple),
                const SizedBox(width: 8),
                // Orbit Score badge
                _buildOrbitScoreBadge(task.orbitScore),
                const Spacer(),
                // Checkmark button
                _buildCheckmarkButton(isCompleted),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              task.title,
              style: TextStyle(
                color: isCompleted ? Colors.grey[600] : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Notes (only if present)
            if (hasNotes) ...[
              const SizedBox(height: 6),
              Text(
                task.notes!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // Bottom row: Deadline + Status badge
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: Colors.grey[700], size: 13),
                const SizedBox(width: 5),
                Text(
                  'Deadline: $deadlineStr',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(task.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // UI COMPONENTS
  // ========================================

  Widget _buildOrbitScoreBadge(int score) {
    // Color shifts from purple (low) to orange (high)
    final Color badgeColor;
    if (score >= 70) {
      badgeColor = const Color(0xFFFF6D00);
    } else if (score >= 40) {
      badgeColor = const Color(0xFFFFAB40);
    } else {
      badgeColor = _accentPurple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rocket_launch_rounded, color: badgeColor, size: 12),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckmarkButton(bool isCompleted) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isCompleted
            ? _greenAccent.withOpacity(0.15)
            : _accentPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isCompleted
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        color: isCompleted ? _greenAccent : _accentPurple,
        size: 20,
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    late final String label;
    late final Color color;

    switch (status) {
      case 'completed':
        label = 'Selesai';
        color = _greenAccent;
        break;
      case 'crashed':
        label = 'Gagal';
        color = Colors.redAccent;
        break;
      case 'orbiting':
      default:
        label = 'Aktif';
        color = _accentPurple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
