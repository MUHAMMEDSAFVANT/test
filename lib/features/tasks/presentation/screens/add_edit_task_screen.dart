import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../../domain/models/task_model.dart';


enum _Priority { low, medium, high }

extension _PriorityX on _Priority {
  String get label => switch (this) {
        _Priority.low => 'Low',
        _Priority.medium => 'Medium',
        _Priority.high => 'High',
      };

  IconData get icon => switch (this) {
        _Priority.low => Icons.arrow_downward_rounded,
        _Priority.medium => Icons.remove_rounded,
        _Priority.high => Icons.arrow_upward_rounded,
      };

  Color get color => switch (this) {
        _Priority.low => const Color(0xFF34A853),
        _Priority.medium => const Color(0xFFFBBC05),
        _Priority.high => const Color(0xFFEA4335),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.existingTask});

  final TaskModel? existingTask;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  _Priority _priority = _Priority.medium;
  bool _isSaving = false;

  late final AnimationController _btnAnim;
  late final Animation<double> _btnScale;

  static const _maxTitle = 120;

  bool get _isEditing => widget.existingTask != null;

  // ── life-cycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingTask?.title ?? '');
    _descCtrl =
        TextEditingController(text: widget.existingTask?.description ?? '');

    _btnAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _btnAnim, curve: Curves.easeInOut),
    );

    // keep counter refreshing
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _btnAnim.dispose();
    super.dispose();
  }

  // ── save logic ───────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await _btnAnim.forward();
    await _btnAnim.reverse();

    setState(() => _isSaving = true);
    try {
      if (!mounted) return;
      final taskProv = context.read<TaskProvider>();
      final uid = context.read<AuthProvider>().user!.uid;

      if (_isEditing) {
        await taskProv.updateTask(
          task: widget.existingTask!,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
        );
      } else {
        await taskProv.addTask(
          uid: uid,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            backgroundColor: Colors.red.shade600,
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Failed to save task: $e',
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCard(
                      children: [
                        _SectionLabel(label: 'Task Title'),
                        SizedBox(height: 8.h),
                        _buildTitleField(),
                        SizedBox(height: 4.h),
                        _buildCharCounter(),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildCard(
                      children: [
                        _SectionLabel(label: 'Description'),
                        SizedBox(height: 8.h),
                        _buildDescField(),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildCard(
                      children: [
                        _SectionLabel(label: 'Priority'),
                        SizedBox(height: 12.h),
                        _buildPrioritySelector(),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD6336C), Color(0xFFFF6B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            children: [
              // back button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Edit Task' : 'New Task',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _isEditing
                          ? 'Update the details below'
                          : 'Fill in the details below',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // decorative icon badge
              Container(
                width: 42.w,
                height: 42.w,
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _isEditing
                      ? Icons.edit_note_rounded
                      : Icons.add_task_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── card wrapper ──────────────────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ── title field ───────────────────────────────────────────────────────────
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      maxLines: 1,
      maxLength: _maxTitle,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
          const SizedBox.shrink(), // we draw our own counter
      textInputAction: TextInputAction.next,
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: _inputDecoration(
        hint: 'e.g. Buy groceries',
        prefix: Icon(
          Icons.title_rounded,
          size: 20.sp,
          color: const Color(0xFFD6336C),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Title cannot be empty.';
        if (v.trim().length > _maxTitle) return 'Title is too long.';
        return null;
      },
    );
  }

  Widget _buildCharCounter() {
    final count = _titleCtrl.text.length;
    final isNearLimit = count > _maxTitle * 0.8;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$count / $_maxTitle',
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          color: isNearLimit ? Colors.orange.shade600 : Colors.grey.shade400,
          fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  // ── description field ─────────────────────────────────────────────────────
  Widget _buildDescField() {
    return TextFormField(
      controller: _descCtrl,
      maxLines: 5,
      minLines: 3,
      textInputAction: TextInputAction.newline,
      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
      decoration: _inputDecoration(
        hint: 'Add more details about this task...',
        prefix: Icon(
          Icons.notes_rounded,
          size: 20.sp,
          color: const Color(0xFFD6336C),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  // ── priority selector ─────────────────────────────────────────────────────
  Widget _buildPrioritySelector() {
    return Row(
      children: _Priority.values.map((p) {
        final selected = p == _priority;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: selected
                    ? p.color.withValues(alpha: 0.12)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected ? p.color : Colors.grey.shade200,
                  width: selected ? 1.8 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(p.icon,
                      size: 20.sp,
                      color: selected ? p.color : Colors.grey.shade400),
                  SizedBox(height: 4.h),
                  Text(
                    p.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? p.color : Colors.grey.shade500,
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

  // ── save button ───────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return ScaleTransition(
      scale: _btnScale,
      child: SizedBox(
        height: 56.h,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD6336C),
            disabledBackgroundColor:
                const Color(0xFFD6336C).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 4,
            shadowColor: const Color(0xFFD6336C).withValues(alpha: 0.4),
          ),
          child: _isSaving
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isEditing
                          ? Icons.save_rounded
                          : Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _isEditing ? 'Save Changes' : 'Add Task',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── shared input decoration ───────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required Widget prefix,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
          fontSize: 14.sp, color: Colors.grey.shade400),
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: prefix,
      ),
      prefixIconConstraints:
          BoxConstraints(minWidth: 44.w, minHeight: 44.h),
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:
            const BorderSide(color: Color(0xFFD6336C), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
      ),
      errorStyle: GoogleFonts.poppins(
          fontSize: 11.sp, color: Colors.red.shade500),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: const Color(0xFFD6336C),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
