import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../../domain/models/task_model.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      context.read<TaskProvider>().startListening(uid);
    }
  }

  Future<void> _confirmDelete(BuildContext context, TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete task?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          '"${task.title}" will be permanently removed.',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TaskProvider>().deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProv = context.watch<TaskProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFD6336C),
        title: Text(
          'My Tasks',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          if (user?.photoURL != null)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => _showSignOutDialog(context),
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundImage: NetworkImage(user!.photoURL!),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              tooltip: 'Sign out',
              onPressed: () => _showSignOutDialog(context),
            ),
          SizedBox(width: 4.w),
        ],
      ),
      body: _buildBody(taskProv, user?.displayName),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD6336C),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'New Task',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(TaskProvider taskProv, String? displayName) {
    if (taskProv.status == TaskStatus.loading ||
        taskProv.status == TaskStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD6336C)),
      );
    }

    if (taskProv.status == TaskStatus.error) {
      return Center(
        child: Text(
          taskProv.errorMessage ?? 'Something went wrong.',
          style: GoogleFonts.poppins(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    final tasks = taskProv.tasks;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _GreetingHeader(displayName: displayName, tasks: tasks),
        ),
        if (tasks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = tasks[index];
                  return _TaskCard(
                    task: task,
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(existingTask: task),
                      ),
                    ),
                    onDelete: () => _confirmDelete(context, task),
                    onToggle: () => context.read<TaskProvider>().toggleDone(task),
                  );
                },
                childCount: tasks.length,
              ),
            ),
          ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Sign out?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'You will be returned to the login screen.',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskProvider>().stopListening();
              context.read<AuthProvider>().signOut();
            },
            child: Text(
              'Sign out',
              style: GoogleFonts.poppins(
                color: const Color(0xFFD6336C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.displayName, required this.tasks});
  final String? displayName;
  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    final done = tasks.where((t) => t.isDone).length;
    final total = tasks.length;

    return Container(
      color: const Color(0xFFD6336C),
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${displayName?.split(' ').first ?? 'there'} 👋',
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            total == 0
                ? 'No tasks yet. Add your first one!'
                : '$done of $total task${total == 1 ? '' : 's'} completed',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.white70,
            ),
          ),
          if (total > 0) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: 6.h,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 72.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'Nothing here yet',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap + New Task to get started.',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isDone ? const Color(0xFFD6336C) : Colors.transparent,
              border: Border.all(
                color: task.isDone ? const Color(0xFFD6336C) : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: task.isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: task.isDone ? Colors.grey.shade400 : Colors.black87,
            decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                  decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: const Color(0xFFD6336C), size: 20.sp),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20.sp),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
