import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD6336C), Color(0xFFFF6B9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 52.sp,
                    color: const Color(0xFFD6336C),
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  'TaskNest',
                  style: GoogleFonts.poppins(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Stay organised, get things done.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                if (auth.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      auth.errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                _GoogleSignInButton(
                  isLoading: isLoading,
                  onTap: isLoading
                      ? null
                      : () => context.read<AuthProvider>().signInWithGoogle(),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.isLoading, this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Color(0xFFD6336C)),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleGLogo(),
                  SizedBox(width: 12.w),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleGLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sweepAngle = 1.5708;
    final paints = [
      Paint()..color = const Color(0xFF4285F4),
      Paint()..color = const Color(0xFF34A853),
      Paint()..color = const Color(0xFFFBBC05),
      Paint()..color = const Color(0xFFEA4335),
    ];

    for (int i = 0; i < 4; i++) {
      paints[i].style = PaintingStyle.stroke;
      paints[i].strokeWidth = size.width * 0.22;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.72),
        i * sweepAngle - 0.2,
        sweepAngle - 0.1,
        false,
        paints[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
