// lib/screens/login_screen.dart
//
// Mirrors the web app's login page:
//  - Dark background #0A0A0A + dot-grid + ambient orange glow
//  - Orbital logo animation
//  - Email + password form with inline validation
//  - Feature cards row
//  - Firebase Auth

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _authService = AuthService();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  late final AnimationController _orbitCtrl1;
  late final AnimationController _orbitCtrl2;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _orbitCtrl1 =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
    _orbitCtrl2 =
        AnimationController(vsync: this, duration: const Duration(seconds: 18))
          ..repeat(reverse: false);
    _glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _emailFocus.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _orbitCtrl1.dispose();
    _orbitCtrl2.dispose();
    _glowCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _error = null;
    });

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty) {
      setState(() => _error = 'Email is required');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Password is required');
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.signIn(email, password);
      // AuthWrapper will handle routing automatically
    } on Exception catch (e) {
      setState(() => _error = _authService.getFriendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Dot grid background
          Positioned.fill(child: _DotGrid()),

          // Ambient orange glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) {
                final opacity = 0.5 + _glowCtrl.value * 0.5;
                return Center(
                  child: Container(
                    width: 500,
                    height: 400,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.07 * opacity),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top accent line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Color(0x80F97316),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Corner brackets
          ..._buildCornerBrackets(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildNav(),
                  const SizedBox(height: 40),
                  _buildOrbitalLogo(),
                  const SizedBox(height: 24),
                  _buildHeadline(),
                  const SizedBox(height: 32),
                  _buildAuthCard(),
                  const SizedBox(height: 24),
                  _buildFeatureCards(),
                  const SizedBox(height: 40),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
            ),
            child: const Center(child: _BucketIcon()),
          ),
          const SizedBox(width: 10),
          Text(
            'MY FILE MANAGER',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF444444),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ]),
        Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.5), blurRadius: 6)
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'SECURE',
            style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF444444), fontSize: 10, letterSpacing: 2),
          ),
        ]),
      ],
    );
  }

  Widget _buildOrbitalLogo() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer orbit ring
          AnimatedBuilder(
            animation: _orbitCtrl1,
            builder: (_, child) => Transform.rotate(
              angle: _orbitCtrl1.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(100, 100),
                painter: _OrbitPainter(
                  radiusX: 46,
                  radiusY: 17,
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
            ),
          ),
          // Inner orbit ring
          AnimatedBuilder(
            animation: _orbitCtrl2,
            builder: (_, child) => Transform.rotate(
              angle: -_orbitCtrl2.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(76, 76),
                painter: _CirclePainter(
                  radius: 34,
                  color: AppColors.primary.withOpacity(0.12),
                ),
              ),
            ),
          ),
          // Central icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF111111)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 40,
                ),
              ],
            ),
            child: const Center(child: _CloudUploadIcon()),
          ),
          // Dot badge
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.7), blurRadius: 8)
                ],
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline() {
    return Column(
      children: [
        const Text(
          'MY File Manager',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to access your Cloudflare R2 storage.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: const Color(0xFF4A4A4A), fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C1C1C)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 64,
              offset: const Offset(0, 24)),
        ],
      ),
      child: Stack(
        children: [
          // Top accent
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: const LinearGradient(colors: [
                  Colors.transparent,
                  Color(0x4DF97316),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email
                _buildLabel('EMAIL'),
                const SizedBox(height: 6),
                _buildEmailField(),
                const SizedBox(height: 16),
                // Password
                _buildLabel('PASSWORD'),
                const SizedBox(height: 6),
                _buildPasswordField(),
                const SizedBox(height: 12),
                // Error
                if (_error != null) ...[
                  _buildErrorBanner(_error!),
                  const SizedBox(height: 12),
                ],
                // Submit
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: const Color(0xFF444444),
        fontSize: 10,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildEmailField() {
    return AnimatedBuilder(
      animation: _emailFocus,
      builder: (context, child) {
        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _emailFocus.hasFocus
                  ? AppColors.primary
                  : const Color(0xFF242424),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const _EmailIcon(),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hoverColor: Colors.transparent,
                    hintText: 'you@example.com',
                    hintStyle: TextStyle(color: Color(0xFF3A3A3A)),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _passwordFocus.hasFocus
              ? AppColors.primary
              : const Color(0xFF242424),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          _LockIcon(),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _passwordCtrl,
              obscureText: !_showPassword,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hoverColor: Colors.transparent,
                hintText: '••••••••',
                hintStyle: TextStyle(color: Color(0xFF3A3A3A)),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _submit(),
              onChanged: (_) => setState(() => _error = null),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showPassword = !_showPassword),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF444444),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.destructive.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          top: BorderSide(color: AppColors.destructive.withOpacity(0.15)),
          right: BorderSide(color: AppColors.destructive.withOpacity(0.15)),
          bottom: BorderSide(color: AppColors.destructive.withOpacity(0.15)),
          left: BorderSide(
              color: AppColors.destructive.withOpacity(0.5), width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline,
              color: AppColors.destructive.withOpacity(0.7), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: AppColors.destructive.withOpacity(0.85),
                  fontSize: 12,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: _loading
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Signing in…',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Sign In',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
              ]),
      ),
    );
  }

  Widget _buildFeatureCards() {
    const features = [
      _FeatureData('UPLOAD', 'Fast Uploads', 'Presigned PUT URLs',
          Icons.upload_outlined, AppColors.primary),
      _FeatureData('AUTH', 'Secure Access', 'Firebase powered',
          Icons.lock_outline, AppColors.primary),
      _FeatureData('BROWSE', 'Navigation', 'Full folder tree',
          Icons.folder_open_outlined, AppColors.primary),
    ];
    return Row(
      children: features
          .map((f) => Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _FeatureCard(data: f),
              )))
          .toList(),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: const Color(0xFF1E1E1E)),
        const SizedBox(width: 12),
        Text(
          'CLOUDFLARE R2 · FIREBASE AUTH',
          style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFF252525),
            fontSize: 9,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 40, height: 1, color: const Color(0xFF1E1E1E)),
      ],
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 32.0;
    const offset = 20.0;
    const borderColor = Color(0x802A2A2A);
    final corners = [
      Positioned(
          top: offset,
          left: offset,
          child:
              _Corner(top: true, left: true, size: size, color: borderColor)),
      Positioned(
          top: offset,
          right: offset,
          child:
              _Corner(top: true, left: false, size: size, color: borderColor)),
      Positioned(
          bottom: offset,
          left: offset,
          child:
              _Corner(top: false, left: true, size: size, color: borderColor)),
      Positioned(
          bottom: offset,
          right: offset,
          child:
              _Corner(top: false, left: false, size: size, color: borderColor)),
    ];
    return corners;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DotGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0EFFFFFF)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbitPainter extends CustomPainter {
  final double radiusX, radiusY;
  final Color color;
  _OrbitPainter(
      {required this.radiusX, required this.radiusY, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    const dashLen = 4.0;
    const gapLen = 6.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path();
    const steps = 360;
    for (int i = 0; i < steps; i++) {
      final angle = i / steps * 2 * math.pi;
      final x = cx + radiusX * math.cos(angle);
      final y = cy + radiusY * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    // Draw dashed - simplified
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CirclePainter extends CustomPainter {
  final double radius;
  final Color color;
  _CirclePainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Corner extends StatelessWidget {
  final bool top, left;
  final double size;
  final Color color;
  const _Corner(
      {required this.top,
      required this.left,
      required this.size,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(top: top, left: left, color: color),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top, left;
  final Color color;
  _CornerPainter({required this.top, required this.left, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BucketIcon extends StatelessWidget {
  const _BucketIcon();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(14, 14), painter: _BucketPainter());
  }
}

class _BucketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(1.5, 6, 11, 6.5),
      const Radius.circular(2),
    ));
    canvas.drawPath(path, paint);
    final path2 = Path()
      ..moveTo(4.5, 6)
      ..lineTo(4.5, 5)
      ..arcToPoint(const Offset(9.5, 5),
          radius: const Radius.circular(2.5), clockwise: false)
      ..lineTo(9.5, 6);
    canvas.drawPath(path2, paint);
    canvas.drawCircle(
        const Offset(7, 9.5), 1, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CloudUploadIcon extends StatelessWidget {
  const _CloudUploadIcon();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        size: const Size(26, 26), painter: _CloudUploadPainter());
  }
}

class _CloudUploadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final cloudPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.69)
      ..arcToPoint(Offset(size.width * 0.25, size.height * 0.37),
          radius: Radius.circular(size.height * 0.15), clockwise: false)
      ..arcToPoint(Offset(size.width * 0.625, size.height * 0.25),
          radius: Radius.circular(size.height * 0.18), clockwise: false)
      ..arcToPoint(Offset(size.width * 0.875, size.height * 0.37),
          radius: Radius.circular(size.height * 0.14), clockwise: false)
      ..arcToPoint(Offset(size.width * 0.875, size.height * 0.69),
          radius: Radius.circular(size.height * 0.15), clockwise: false)
      ..close();

    canvas.drawPath(cloudPath, fill);
    canvas.drawPath(cloudPath, paint);

    // Upload arrow
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.56),
      Offset(size.width / 2, size.height * 0.37),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.40, size.height * 0.47),
      Offset(size.width / 2, size.height * 0.37),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.60, size.height * 0.47),
      Offset(size.width / 2, size.height * 0.37),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmailIcon extends StatelessWidget {
  const _EmailIcon();
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.email_outlined, color: Color(0xFF444444), size: 16);
  }
}

class _LockIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.lock_outline, color: Color(0xFF444444), size: 16);
  }
}

class _FeatureData {
  final String label, title, desc;
  final IconData icon;
  final Color color;
  const _FeatureData(this.label, this.title, this.desc, this.icon, this.color);
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.primary.withOpacity(0.03)
              : const Color(0xFF0E0E0E),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            top: BorderSide(
                color: _hovered
                    ? AppColors.primary.withOpacity(0.3)
                    : const Color(0xFF1A1A1A)),
            right: BorderSide(
                color: _hovered
                    ? AppColors.primary.withOpacity(0.3)
                    : const Color(0xFF1A1A1A)),
            bottom: BorderSide(
                color: _hovered
                    ? AppColors.primary.withOpacity(0.3)
                    : const Color(0xFF1A1A1A)),
            left: BorderSide(
                color: AppColors.primary.withOpacity(0.25), width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.12)),
              ),
              child: Icon(widget.data.icon, color: AppColors.primary, size: 14),
            ),
            const SizedBox(height: 8),
            Text(widget.data.label,
                style: GoogleFonts.jetBrainsMono(
                    color: AppColors.primary.withOpacity(0.55),
                    fontSize: 8,
                    letterSpacing: 2)),
            const SizedBox(height: 2),
            Text(widget.data.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(widget.data.desc,
                style: const TextStyle(
                    color: Color(0xFF333333), fontSize: 9, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
