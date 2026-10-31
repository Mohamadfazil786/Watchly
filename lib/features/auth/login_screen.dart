import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0);
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _shakeController.forward(from: 0);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      // Do NOT manually navigate here. The RouterNotifier listens to
      // authStateChanges and will redirect to /home automatically once
      // the auth state stream emits. Calling context.go('/home') here
      // races with the router redirect and can cause a stuck loading state.
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = context.surface;
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;
    final inputBg = context.surface2;
    final borderColor = context.border;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        padding: EdgeInsets.fromLTRB(
            28, 12, 28, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_reset_rounded,
                      color: Color(0xFFE50914), size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reset Password',
                        style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    Text('We\'ll send a link to your email',
                        style: GoogleFonts.inter(
                            color: subtitleColor, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(color: textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Email address',
                hintStyle: GoogleFonts.inter(
                    color: context.muted, fontSize: 15),
                filled: true,
                fillColor: inputBg,
                prefixIcon: Icon(Icons.email_outlined,
                    color: context.muted, size: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFE50914), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);
                  await ref
                      .read(authRepositoryProvider)
                      .sendPasswordResetEmail(emailCtrl.text.trim());
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text('Reset email sent!',
                              style:
                              GoogleFonts.inter(color: Colors.white)),
                        ],
                      ),
                      backgroundColor: const Color(0xFF00C853),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('Send Reset Link',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;
    final surfaceColor = context.surface;
    final borderColor = context.border;

    // Adaptive accent glow
    final glowColor = isDark
        ? const Color(0xFFE50914).withValues(alpha: 0.07)
        : const Color(0xFFE50914).withValues(alpha: 0.05);
    final secondGlow = isDark
        ? const Color(0xFF6B35FF).withValues(alpha: 0.05)
        : const Color(0xFF6B35FF).withValues(alpha: 0.03);

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Ambient orbs
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                      colors: [glowColor, Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                      colors: [secondGlow, Colors.transparent]),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _buildHeroPanel(context, isDark, textColor,
                            subtitleColor, borderColor),
                        Expanded(
                            child: _buildFormPanel(
                                context,
                                isDark,
                                textColor,
                                subtitleColor,
                                surfaceColor,
                                borderColor)),
                      ],
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

  Widget _buildHeroPanel(BuildContext context, bool isDark, Color textColor,
      Color subtitleColor, Color borderColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE50914), Color(0xFFFF6B35)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.movie_filter_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Watchly',
                      style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(20),
                  color: context.surface2,
                ),
                child: Text('Member Area',
                    style: GoogleFonts.inter(
                        color: context.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5)),
              ),
            ],
          ),

          const SizedBox(height: 36),
          _FilmStripRow(isDark: isDark),
          const SizedBox(height: 28),

          RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.1),
              children: [
                TextSpan(
                    text: 'Your Cinema,\n',
                    style: TextStyle(color: textColor)),
                const TextSpan(
                    text: 'Everywhere.',
                    style: TextStyle(color: Color(0xFFE50914))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Thousands of films, series, and exclusives — all in one place.',
            style: GoogleFonts.inter(
                color: subtitleColor, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(
      BuildContext context,
      bool isDark,
      Color textColor,
      Color subtitleColor,
      Color surfaceColor,
      Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section pill
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('SIGN IN',
                    style: GoogleFonts.outfit(
                        color: const Color(0xFFE50914),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0)),
              ],
            ),
            const SizedBox(height: 20),

            // Error
            if (_errorMessage != null)
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                      8 * (_shakeAnimation.value - 0.5).abs() * 2, 0),
                  child: child,
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3333).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFF3333)
                            .withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Color(0xFFFF3333), size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(_errorMessage!,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFFFF3333),
                                  fontSize: 13))),
                    ],
                  ),
                ),
              ),

            _buildLabel('Email', context),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(color: textColor, fontSize: 15),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Enter a valid email'
                  : null,
              decoration: _fieldDecoration(
                  'you@example.com', Icons.alternate_email_rounded, context),
            ),
            const SizedBox(height: 18),

            _buildLabel('Password', context),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.inter(color: textColor, fontSize: 15),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Minimum 6 characters'
                  : null,
              decoration:
              _fieldDecoration('••••••••', Icons.lock_outline_rounded,
                  context)
                  .copyWith(
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: context.muted,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _showForgotPassword,
                child: Text('Forgot password?',
                    style: GoogleFonts.inter(
                        color: const Color(0xFFE50914),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 28),

            // Sign in button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  disabledBackgroundColor:
                  const Color(0xFFE50914).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sign In',
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Divider
            Row(children: [
              Expanded(child: Divider(color: borderColor, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('or continue with',
                    style: GoogleFonts.inter(
                        color: context.muted, fontSize: 12)),
              ),
              Expanded(child: Divider(color: borderColor, thickness: 1)),
            ]),
            const SizedBox(height: 20),

            // Google button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor, width: 1),
                  backgroundColor: context.surface2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CustomPaint(painter: _GoogleGPainter()),
                    ),
                    const SizedBox(width: 12),
                    Text('Continue with Google',
                        style: GoogleFonts.inter(
                            color: subtitleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Register link
            Center(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      color: subtitleColor, fontSize: 14),
                  children: [
                    const TextSpan(text: 'New to Watchly? '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () =>
                            context.go('/auth/login/register'),
                        child: Text('Create account',
                            style: GoogleFonts.inter(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: textColor)),
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
  }

  Widget _buildLabel(String text, BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            color: context.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3));
  }

  InputDecoration _fieldDecoration(
      String hint, IconData icon, BuildContext context) {
    final inputBg = context.surface2;
    final hintColor = context.muted;
    final borderColor = context.border;
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: hintColor, fontSize: 15),
      filled: true,
      fillColor: inputBg,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, color: hintColor, size: 18),
      ),
      prefixIconConstraints:
      const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFFE50914), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF3333))),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFFFF3333), width: 1.5)),
      errorStyle:
      GoogleFonts.inter(color: const Color(0xFFFF3333), fontSize: 12),
    );
  }
}

// ── Film strip widget ─────────────────────────────────────────────────────────
class _FilmStripRow extends StatelessWidget {
  final bool isDark;
  const _FilmStripRow({required this.isDark});

  static const _icons = [
    Icons.star_rounded,
    Icons.play_circle_outline_rounded,
    Icons.favorite_border_rounded,
    Icons.theaters_rounded,
    Icons.bookmark_border_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final cellBg = isDark
        ? [
      const Color(0xFF1A1230),
      const Color(0xFF0D1A2E),
      const Color(0xFF1E0A0A),
      const Color(0xFF0A1A15),
      const Color(0xFF1A1505),
    ]
        : [
      const Color(0xFFEDE9FF),
      const Color(0xFFE0EDFF),
      const Color(0xFFFFECEC),
      const Color(0xFFE6FFF4),
      const Color(0xFFFFF8E0),
    ];

    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.25);

    final perfColor =
    isDark ? const Color(0xFF2A2A35) : const Color(0xFFDDDDE8);

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          _Perforations(color: perfColor),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: List.generate(
                5,
                    (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: cellBg[i],
                    ),
                    child: Center(
                      child: Icon(_icons[i], color: iconColor, size: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          _Perforations(color: perfColor),
        ],
      ),
    );
  }
}

class _Perforations extends StatelessWidget {
  final Color color;
  const _Perforations({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        3,
            (_) => Container(
          width: 6,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

// ── Google G painter ──────────────────────────────────────────────────────────
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final segments = [
      (0.0, 0.5, const Color(0xFF4285F4)),
      (0.5, 0.75, const Color(0xFF34A853)),
      (0.75, 0.875, const Color(0xFFFBBC05)),
      (0.875, 1.0, const Color(0xFFEA4335)),
    ];

    for (final (start, end, color) in segments) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r - 1.5),
        (start * 2 - 0.5) * 3.14159,
        (end - start) * 2 * 3.14159,
        false,
        paint,
      );
    }

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(size.width, cy), barPaint);
  }

  @override
  bool shouldRepaint(_GoogleGPainter old) => false;
}