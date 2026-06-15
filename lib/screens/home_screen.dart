import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../models/task_model.dart';
import '../widgets/add_task_bottom_sheet.dart';
import 'task_screen.dart';
import 'goals_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  // --- Color Palette ---
  static const _bgColor = Color(0xFF0A0A0F);
  static const _cardColor = Color(0xFF161625);
  static const _accentPurple = Color(0xFF7C4DFF);

  void _completeTask(TaskModel task) {
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
        status: 'completed',
        orbitScore: task.orbitScore,
        idealStartDate: task.idealStartDate,
        createdAt: task.createdAt,
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showAddTaskSheet(context);
  }

  // ========================================
  // BUILD
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 1:
        return const TaskScreen();
      case 2:
        return const GoalsScreen();
      case 3:
        return const ProgressScreen();
      case 0:
      default:
        final tasksAsyncValue = ref.watch(tasksStreamProvider);
        return tasksAsyncValue.when(
          data: (tasks) => _buildDashboard(tasks),
          loading: () => const Center(
              child: CircularProgressIndicator(color: _accentPurple)),
          error: (err, stack) => Center(
              child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Terjadi anomali: $err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent)),
          )),
        );
    }
  }

  Widget _buildDashboard(List<TaskModel> tasks) {
    final totalTasks = tasks.length;
    final completedTasks =
        tasks.where((t) => t.status == 'completed').length;

    final activeTasks = tasks
        .where((t) => t.status != 'completed')
        .toList()
      ..sort((a, b) => b.orbitScore.compareTo(a.orbitScore));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildHeader(),
          const SizedBox(height: 28),
          _buildGreeting(),
          const SizedBox(height: 24),
          _buildConsistencyCard(totalTasks, completedTasks),
          const SizedBox(height: 28),
          _buildOverviewSection(totalTasks, completedTasks, activeTasks),
          const SizedBox(height: 28),
          _buildNextTasksSection(activeTasks),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Hamburger menu
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white70, size: 22),
            onPressed: () {},
          ),
        ),
        // Notification bell
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white70, size: 22),
                onPressed: () {},
              ),
              // Notification dot
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _accentPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final displayName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Pengguna';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Halo, $displayName! ',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 20),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Siap untuk hari yang\nproduktif?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildConsistencyCard(int totalTasks, int completedTasks) {
    final percentStr = totalTasks == 0
        ? '0%'
        : '${((completedTasks / totalTasks) * 100).toInt()}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5C2D91), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentPurple.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_graph_rounded,
                        color: Colors.white.withOpacity(0.8), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Consistency Score',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  percentStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$completedTasks Tugas tuntas ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right: Globe icon
          _buildGlobeIllustration(),
        ],
      ),
    );
  }

  Widget _buildGlobeIllustration() {
    return SizedBox(
      width: 110,
      height: 110,
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE1BEE7), Color(0xFFCE93D8), Color(0xFFAB47BC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCE93D8).withOpacity(0.3),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.public, color: Colors.white70, size: 48),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(
      int totalTasks, int completedTasks, List<TaskModel> activeTasks) {
    final bebanTotal = activeTasks.fold<int>(
        0, (sum, task) => sum + task.difficulty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Overview Hari Ini'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                icon: Icons.layers_rounded,
                iconBgColor: const Color(0xFF1A237E),
                iconColor: const Color(0xFF7C4DFF),
                label: 'Total',
                value: '$totalTasks',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                icon: Icons.check_circle_outline_rounded,
                iconBgColor: const Color(0xFF1B5E20).withOpacity(0.5),
                iconColor: const Color(0xFF69F0AE),
                label: 'Selesai',
                value: '$completedTasks',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                icon: Icons.fitness_center_rounded,
                iconBgColor: const Color(0xFFE65100).withOpacity(0.3),
                iconColor: const Color(0xFFFFAB40),
                label: 'Beban',
                value: '$bebanTotal Poin',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextTasksSection(List<TaskModel> activeTasks) {
    final displayTasks = activeTasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Tugas Berikutnya'),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: _accentPurple.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (displayTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              children: [
                Icon(Icons.rocket_launch_rounded,
                    color: Colors.grey[700], size: 40),
                const SizedBox(height: 12),
                Text(
                  'Tidak ada tugas aktif.\nTambahkan tugas baru!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...displayTasks.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTaskDetailCard(task),
            );
          }),
      ],
    );
  }

  Widget _buildTaskDetailCard(TaskModel task) {
    final deadlineStr =
        '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}';
    final subtitle = task.notes != null && task.notes!.isNotEmpty
        ? task.notes!
        : 'Deadline: $deadlineStr';

    return GestureDetector(
      onTap: () => _completeTask(task),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: Colors.grey[600], size: 14),
                const SizedBox(width: 6),
                Text(
                  'Deadline: $deadlineStr',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _accentPurple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: _accentPurple, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              task.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle: notes or deadline
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildTag(task.course, _accentPurple),
                const SizedBox(width: 8),
                _buildTag(
                  'Score: ${task.orbitScore}',
                  const Color(0xFFFFAB40),
                ),
                const SizedBox(width: 8),
                _buildTag(
                  task.status == 'orbiting' ? 'Aktif' : task.status,
                  const Color(0xFF00BFA5),
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Beranda', 0),
            _buildNavItem(Icons.task_alt_rounded, 'Tugas', 1),
            _buildCenterAddButton(),
            _buildNavItem(Icons.flag_rounded, 'Tujuan', 2),
            _buildNavItem(Icons.analytics_outlined, 'Progress', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {VoidCallback? onTap}) {
    final isActive = _navIndex == index;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _navIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? _accentPurple : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? _accentPurple : Colors.grey[600],
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Keluar',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          content: Text(
            'Apakah kamu yakin ingin keluar dari Orbit?',
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authServiceProvider).signOut();
              },
              child: const Text('Keluar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () => _showAddTaskDialog(context),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accentPurple, Color(0xFF651FFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accentPurple.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}