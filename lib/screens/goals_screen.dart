import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  // --- Color palette (consistent with app theme) ---
  static const _bgColor = Color(0xFF0A0A0F);
  static const _cardColor = Color(0xFF161625);
  static const _accentPurple = Color(0xFF7C4DFF);
  static const _accentPurpleDark = Color(0xFF5C2D91);
  static const _greenAccent = Color(0xFF69F0AE);
  static const _sheetBg = Color(0xFF12121F);
  static const _surfaceBorder = Color(0xFF2A2A40);

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      floatingActionButton: _buildFab(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: goalsAsync.when(
                data: (goals) => goals.isEmpty
                    ? _buildEmptyState()
                    : _buildGoalsList(goals),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: _accentPurple),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Terjadi kesalahan: $err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tujuan Besar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kejar mimpimu langkah demi langkah',
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
            child: const Icon(Icons.flag_rounded,
                color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentPurple.withOpacity(0.15),
                    _accentPurpleDark.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada tujuan besar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan mimpimu sekarang!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // CTA button
            GestureDetector(
              onTap: () => _showAddGoalSheet(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _accentPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _accentPurple.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: _accentPurple, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Buat Tujuan Pertama',
                      style: TextStyle(
                        color: _accentPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(List<GoalModel> goals) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildGoalCard(goals[index]),
        );
      },
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final progress = goal.progressPercentage.round().clamp(0, 100);
    final progressFraction = progress / 100.0;
    final isComplete = progress >= 100;

    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final targetStr =
        '${goal.targetDate.day} ${_monthNames[goal.targetDate.month - 1]} ${goal.targetDate.year}';

    final Color deadlineColor;
    if (isComplete) {
      deadlineColor = _greenAccent;
    } else if (daysLeft < 0) {
      deadlineColor = Colors.redAccent;
    } else if (daysLeft <= 7) {
      deadlineColor = const Color(0xFFFFAB40);
    } else {
      deadlineColor = Colors.grey[500]!;
    }

    final Color progressColor;
    if (isComplete) {
      progressColor = _greenAccent;
    } else if (progress >= 60) {
      progressColor = const Color(0xFFFFAB40);
    } else {
      progressColor = _accentPurple;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isComplete
              ? _greenAccent.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: CircularProgressIndicator(
                        value: progressFraction,
                        strokeWidth: 4,
                        backgroundColor: progressColor.withOpacity(0.12),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$progress%',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        color: isComplete ? Colors.grey[500] : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration:
                            isComplete ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            color: deadlineColor, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          targetStr,
                          style: TextStyle(
                            color: deadlineColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (daysLeft >= 0 && !isComplete) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: deadlineColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$daysLeft hari lagi',
                              style: TextStyle(
                                color: deadlineColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (daysLeft < 0 && !isComplete) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Terlewat',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(goal),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 6,
              backgroundColor: progressColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isComplete
                      ? _greenAccent.withOpacity(0.12)
                      : _accentPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isComplete ? '🎉 Tercapai' : 'Sedang Berjalan',
                  style: TextStyle(
                    color: isComplete ? _greenAccent : _accentPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Milestones manage button
              GestureDetector(
                onTap: () => _showUpdateProgressSheet(goal),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentPurple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.checklist_rounded,
                          color: _accentPurple.withOpacity(0.8), size: 14),
                      const SizedBox(width: 5),
                      Text(
                        'Milestones',
                        style: TextStyle(
                          color: _accentPurple.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Inline milestone checklist
          if (goal.milestones.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _surfaceBorder.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist_rounded,
                          color: Colors.grey[500], size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${goal.milestones.where((m) => m.isCompleted).length}/${goal.milestones.length} milestone selesai',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...goal.milestones.map((ms) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GestureDetector(
                        onTap: () async {
                          await ref
                              .read(goalRepositoryProvider)
                              .toggleMilestone(goal, ms.id);
                        },
                        child: Row(
                          children: [
                            Icon(
                              ms.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: ms.isCompleted
                                  ? _greenAccent
                                  : Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ms.title,
                                style: TextStyle(
                                  color: ms.isCompleted
                                      ? Colors.grey[600]
                                      : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: ms.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => _showAddGoalSheet(),
      backgroundColor: _accentPurple,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }

  void _showAddGoalSheet() {
    final titleController = TextEditingController();
    final milestoneInputController = TextEditingController();
    DateTime? selectedDate;
    bool isSubmitting = false;
    List<String> milestoneTitles = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            final hasDate = selectedDate != null;
            final dateLabel = hasDate
                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                : 'Pilih target tanggal...';

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.85,
              ),
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: _sheetBg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_accentPurpleDark, _accentPurple],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.flag_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tujuan Baru',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tentukan mimpi besarmu dan kejar!',
                                style: TextStyle(
                                  color: Color(0xFF7C7C9A),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Goal title
                    const Text(
                      'Nama Tujuan',
                      style: TextStyle(
                        color: Color(0xFFB0B0CC),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _surfaceBorder),
                      ),
                      child: TextField(
                        controller: titleController,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Misal: Lulus dengan IPK 3.8...',
                          hintStyle: TextStyle(
                              color: Colors.grey[600], fontSize: 14),
                          prefixIcon: const Icon(Icons.emoji_events_rounded,
                              color: _accentPurple, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Target date
                    const Text(
                      'Target Tanggal',
                      style: TextStyle(
                        color: Color(0xFFB0B0CC),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate:
                              selectedDate ?? now.add(const Duration(days: 30)),
                          firstDate: now,
                          lastDate: DateTime(now.year + 5),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: _accentPurple,
                                  surface: Color(0xFF1A1A2E),
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor:
                                    const Color(0xFF12121F),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasDate
                                ? _accentPurple.withOpacity(0.4)
                                : _surfaceBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: hasDate
                                  ? _accentPurple
                                  : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              dateLabel,
                              style: TextStyle(
                                color: hasDate
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.grey[700], size: 14),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Text(
                          'Tambah Milestone',
                          style: TextStyle(
                            color: Color(0xFFB0B0CC),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(opsional)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pecah tujuanmu menjadi langkah-langkah kecil',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Input row for adding milestone
                    Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: milestoneInputController,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Nama milestone...',
                                hintStyle: TextStyle(
                                    color: Colors.grey[600], fontSize: 13),
                                prefixIcon: Icon(
                                    Icons.outlined_flag_rounded,
                                    color: Colors.grey[600],
                                    size: 18),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                              ),
                              onSubmitted: (val) {
                                final text = val.trim();
                                if (text.isEmpty) return;
                                setSheetState(() {
                                  milestoneTitles.add(text);
                                  milestoneInputController.clear();
                                });
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final text =
                                  milestoneInputController.text.trim();
                              if (text.isEmpty) return;
                              setSheetState(() {
                                milestoneTitles.add(text);
                                milestoneInputController.clear();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _accentPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: _accentPurple, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Added milestones list
                    if (milestoneTitles.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...List.generate(milestoneTitles.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: _surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                    Icons
                                        .radio_button_unchecked_rounded,
                                    color: Colors.grey[600],
                                    size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    milestoneTitles[i],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      milestoneTitles.removeAt(i);
                                    });
                                  },
                                  child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey[600],
                                      size: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 28),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final title = titleController.text.trim();
                                if (title.isEmpty || selectedDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        title.isEmpty
                                            ? 'Nama tujuan tidak boleh kosong!'
                                            : 'Pilih target tanggal!',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor:
                                          Colors.redAccent.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() => isSubmitting = true);

                                final uid = FirebaseAuth
                                        .instance.currentUser?.uid ??
                                    '';

                                // Map milestone titles to GoalMilestone objects
                                final milestones = milestoneTitles
                                    .map((t) => GoalMilestone(title: t))
                                    .toList();

                                final goal = GoalModel(
                                  id: FirebaseFirestore.instance
                                      .collection('goals')
                                      .doc()
                                      .id,
                                  userId: uid,
                                  title: title,
                                  targetDate: selectedDate!,
                                  milestones: milestones,
                                );

                                await ref
                                    .read(goalRepositoryProvider)
                                    .addGoal(goal);

                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.flag_rounded,
                                              color: Colors.white,
                                              size: 18),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Tujuan "$title" berhasil ditambahkan!',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: _accentPurpleDark,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentPurple,
                          disabledBackgroundColor:
                              _accentPurple.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.flag_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Simpan Tujuan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUpdateProgressSheet(GoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        // Local copy of milestones for toggling
        List<GoalMilestone> localMilestones =
            goal.milestones.map((m) => GoalMilestone(
                  id: m.id,
                  title: m.title,
                  isCompleted: m.isCompleted,
                )).toList();
        final addController = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final completed =
                localMilestones.where((m) => m.isCompleted).length;
            final total = localMilestones.length;
            final pct = total > 0 ? ((completed / total) * 100).round() : 0;

            final Color trackColor;
            if (pct >= 100) {
              trackColor = _greenAccent;
            } else if (pct >= 60) {
              trackColor = const Color(0xFFFFAB40);
            } else {
              trackColor = _accentPurple;
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.75,
              ),
              decoration: const BoxDecoration(
                color: _sheetBg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Title
                    Text(
                      goal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Progress display
                    Text(
                      '$pct%',
                      style: TextStyle(
                        color: trackColor,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: total > 0 ? completed / total : 0,
                        minHeight: 6,
                        backgroundColor: trackColor.withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(trackColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completed / $total milestones selesai',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add milestone input
                    Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: addController,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Tambah milestone baru...',
                                hintStyle: TextStyle(
                                    color: Colors.grey[600], fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final text = addController.text.trim();
                              if (text.isEmpty) return;
                              setSheetState(() {
                                localMilestones.add(
                                  GoalMilestone(title: text),
                                );
                                addController.clear();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _accentPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: _accentPurple, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Milestone list
                    Flexible(
                      child: localMilestones.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Belum ada milestone.\nTambahkan langkah-langkah untuk mencapai tujuanmu!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: localMilestones.length,
                              itemBuilder: (_, i) {
                                final ms = localMilestones[i];
                                return Dismissible(
                                  key: ValueKey(ms.id),
                                  direction:
                                      DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding:
                                        const EdgeInsets.only(right: 16),
                                    margin: const EdgeInsets.only(
                                        bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 20),
                                  ),
                                  onDismissed: (_) {
                                    setSheetState(() {
                                      localMilestones.removeAt(i);
                                    });
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      setSheetState(() {
                                        localMilestones[i] =
                                            GoalMilestone(
                                          id: ms.id,
                                          title: ms.title,
                                          isCompleted: !ms.isCompleted,
                                        );
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: ms.isCompleted
                                            ? _greenAccent
                                                .withOpacity(0.06)
                                            : _cardColor,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: ms.isCompleted
                                              ? _greenAccent
                                                  .withOpacity(0.15)
                                              : _surfaceBorder,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            ms.isCompleted
                                                ? Icons
                                                    .check_circle_rounded
                                                : Icons
                                                    .radio_button_unchecked_rounded,
                                            color: ms.isCompleted
                                                ? _greenAccent
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              ms.title,
                                              style: TextStyle(
                                                color: ms.isCompleted
                                                    ? Colors.grey[500]
                                                    : Colors.white,
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w500,
                                                decoration:
                                                    ms.isCompleted
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                                decorationColor:
                                                    Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final updatedGoal = GoalModel(
                            id: goal.id,
                            userId: goal.userId,
                            title: goal.title,
                            targetDate: goal.targetDate,
                            milestones: localMilestones,
                            createdAt: goal.createdAt,
                          );
                          await ref
                              .read(goalRepositoryProvider)
                              .updateGoal(updatedGoal);
                          if (mounted) Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Simpan Milestones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // DELETE CONFIRMATION
  void _confirmDelete(GoalModel goal) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Tujuan',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          content: Text(
            'Hapus "${goal.title}" secara permanen?',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ref.read(goalRepositoryProvider).deleteGoal(goal.id);
              },
              child: const Text('Hapus',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
