import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

/// Opens the Add Task bottom sheet.
void showAddTaskSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddTaskBottomSheet(),
  );
}

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  // --- Controllers ---
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  // --- Form state ---
  String _selectedCourse = 'Mobile Development';
  DateTime? _selectedDeadline;
  double _difficulty = 5;
  String _selectedWeight = 'Sedang';
  bool _isSubmitting = false;

  static const _courses = [
    'Mobile Development',
    'UI/UX',
    'Algoritma',
    'Basis Data',
    'Jaringan Komputer',
    'Kecerdasan Buatan',
  ];

  static const _weights = ['Kecil', 'Sedang', 'Besar'];

  // --- Color palette ---
  static const _sheetBg = Color(0xFF12121F);
  static const _cardColor = Color(0xFF1A1A2E);
  static const _accentPurple = Color(0xFF7C4DFF);
  static const _accentPurpleDark = Color(0xFF5C2D91);
  static const _surfaceBorder = Color(0xFF2A2A40);

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            title.isEmpty
                ? 'Nama tugas tidak boleh kosong!'
                : 'Pilih deadline terlebih dahulu!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final task = TaskModel.withSmartDefaults(
      id: FirebaseFirestore.instance.collection('tasks').doc().id,
      userId: uid,
      title: title,
      course: _selectedCourse,
      deadline: _selectedDeadline!,
      difficulty: _difficulty.round(),
      weight: _selectedWeight,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await ref.read(taskRepositoryProvider).addTask(task);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tugas "$title" berhasil ditambahkan! (Score: ${task.orbitScore})',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: _accentPurpleDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Date Picker
  // ---------------------------------------------------------------------------

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accentPurple,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF12121F),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Handle bar ---
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

            // --- Title row ---
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
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tugas Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Smart Task Engine akan menghitung prioritas otomatis',
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

            // ===================== Task Name =====================
            _buildLabel('Nama Tugas'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'Misal: Buat wireframe halaman utama...',
              icon: Icons.edit_rounded,
            ),

            const SizedBox(height: 22),

            // ===================== Course =====================
            _buildLabel('Mata Kuliah'),
            const SizedBox(height: 8),
            _buildCourseDropdown(),

            const SizedBox(height: 22),

            // ===================== Deadline =====================
            _buildLabel('Deadline'),
            const SizedBox(height: 8),
            _buildDeadlinePicker(),

            const SizedBox(height: 22),

            // ===================== Difficulty =====================
            _buildLabel('Tingkat Kesulitan'),
            const SizedBox(height: 8),
            _buildDifficultySlider(),

            const SizedBox(height: 22),

            // ===================== Weight =====================
            _buildLabel('Bobot Tugas'),
            const SizedBox(height: 10),
            _buildWeightChips(),

            const SizedBox(height: 22),

            // ===================== Notes =====================
            _buildLabel('Catatan (opsional)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _notesController,
              hint: 'Tambahkan catatan...',
              icon: Icons.sticky_note_2_rounded,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // ===================== Submit =====================
            _buildSubmitButton(),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFB0B0CC),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _surfaceBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: _accentPurple, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _surfaceBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCourse,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1E35),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: _accentPurple),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: _courses.map((course) {
            return DropdownMenuItem(
              value: course,
              child: Row(
                children: [
                  Icon(Icons.school_rounded,
                      color: _accentPurple.withOpacity(0.7), size: 18),
                  const SizedBox(width: 12),
                  Text(course),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCourse = val);
          },
        ),
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    final hasDate = _selectedDeadline != null;
    final label = hasDate
        ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
        : 'Pilih tanggal deadline...';

    return GestureDetector(
      onTap: _pickDeadline,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDate ? _accentPurple.withOpacity(0.4) : _surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: hasDate ? _accentPurple : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: hasDate ? Colors.white : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey[700], size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySlider() {
    final diffInt = _difficulty.round();
    Color trackColor;
    String diffLabel;

    if (diffInt <= 3) {
      trackColor = const Color(0xFF69F0AE);
      diffLabel = 'Mudah';
    } else if (diffInt <= 6) {
      trackColor = const Color(0xFFFFAB40);
      diffLabel = 'Sedang';
    } else {
      trackColor = const Color(0xFFFF5252);
      diffLabel = 'Sulit';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.speed_rounded, color: trackColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    diffLabel,
                    style: TextStyle(
                      color: trackColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: trackColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$diffInt / 10',
                  style: TextStyle(
                    color: trackColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: trackColor,
              inactiveTrackColor: trackColor.withOpacity(0.15),
              thumbColor: trackColor,
              overlayColor: trackColor.withOpacity(0.12),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: _difficulty,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (val) => setState(() => _difficulty = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChips() {
    const weightIcons = {
      'Kecil': Icons.circle_outlined,
      'Sedang': Icons.change_history_rounded,
      'Besar': Icons.hexagon_outlined,
    };
    const weightColors = {
      'Kecil': Color(0xFF69F0AE),
      'Sedang': Color(0xFFFFAB40),
      'Besar': Color(0xFFFF5252),
    };

    return Row(
      children: _weights.map((w) {
        final isSelected = _selectedWeight == w;
        final color = weightColors[w]!;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedWeight = w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: w != _weights.last ? 10 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : _cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.5) : _surfaceBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    weightIcons[w],
                    color: isSelected ? color : Colors.grey[600],
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    w,
                    style: TextStyle(
                      color: isSelected ? color : Colors.grey[500],
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentPurple,
          disabledBackgroundColor: _accentPurple.withOpacity(0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSubmitting
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
                  Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Luncurkan Tugas 🚀',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
