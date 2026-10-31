import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;
    final surfaceColor = context.surface;
    final borderColor = context.border;

    final glowColor = isDark
        ? const Color(0xFF6C63FF).withValues(alpha: 0.07)
        : const Color(0xFF6C63FF).withValues(alpha: 0.04);
    final secondGlow = isDark
        ? const Color(0xFFE50914).withValues(alpha: 0.05)
        : const Color(0xFFE50914).withValues(alpha: 0.03);

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Ambient orbs — violet top-right, red bottom-left
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                      colors: [glowColor, Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                      colors: [secondGlow, Colors.transparent]),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER ──────────────────────────────────────
                    _buildHeader(context, isDark, textColor, subtitleColor,
                        borderColor),

                    // ── FORM CARD ────────────────────────────────────
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28)),
                        border: Border(
                            top: BorderSide(color: borderColor, width: 1)),
                      ),
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section label
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('CREATE ACCOUNT',
                                    style: GoogleFonts.outfit(
                                        color: const Color(0xFF6C63FF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2.0)),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Error
                            if (_errorMessage != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3333)
                                      .withValues(alpha: 0.08),
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
                                                color:
                                                const Color(0xFFFF3333),
                                                fontSize: 13))),
                                  ],
                                ),
                              ),

                            // Username
                            _buildLabel('Username', context),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              style: GoogleFonts.inter(
                                  color: textColor, fontSize: 15),
                              validator: (v) => (v == null || v.length < 3)
                                  ? 'At least 3 characters'
                                  : null,
                              decoration: _fieldDecoration('Choose a username',
                                  Icons.person_outline_rounded, context),
                            ),
                            const SizedBox(height: 18),

                            // Email
                            _buildLabel('Email', context),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.inter(
                                  color: textColor, fontSize: 15),
                              validator: (v) =>
                              (v == null || !v.contains('@'))
                                  ? 'Enter a valid email'
                                  : null,
                              decoration: _fieldDecoration(
                                  'you@example.com',
                                  Icons.alternate_email_rounded,
                                  context),
                            ),
                            const SizedBox(height: 18),

                            // Password
                            _buildLabel('Password', context),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.inter(
                                  color: textColor, fontSize: 15),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Minimum 6 characters'
                                  : null,
                              decoration: _fieldDecoration('Create a password',
                                  Icons.lock_outline_rounded, context)
                                  .copyWith(
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
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
                            const SizedBox(height: 18),

                            // Confirm Password
                            _buildLabel('Confirm Password', context),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: _obscureConfirm,
                              style: GoogleFonts.inter(
                                  color: textColor, fontSize: 15),
                              validator: (v) =>
                              v != _passwordController.text
                                  ? 'Passwords do not match'
                                  : null,
                              decoration: _fieldDecoration(
                                  'Confirm your password',
                                  Icons.lock_outline_rounded,
                                  context)
                                  .copyWith(
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() =>
                                  _obscureConfirm = !_obscureConfirm),
                                  child: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: context.muted,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Terms hint
                            Padding(
                              padding:
                              const EdgeInsets.only(bottom: 20),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                      color: context.muted,
                                      fontSize: 12,
                                      height: 1.5),
                                  children: [
                                    const TextSpan(
                                        text:
                                        'By creating an account you agree to our '),
                                    TextSpan(
                                        text: 'Terms of Service',
                                        style: GoogleFonts.inter(
                                            color: const Color(0xFF6C63FF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                        text: 'Privacy Policy',
                                        style: GoogleFonts.inter(
                                            color: const Color(0xFF6C63FF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),

                            // Create account button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF6C63FF),
                                  disabledBackgroundColor:
                                  const Color(0xFF6C63FF)
                                      .withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text('Create Account',
                                        style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.2)),
                                    const SizedBox(width: 8),
                                    const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Sign in link
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                      color: subtitleColor, fontSize: 14),
                                  children: [
                                    const TextSpan(
                                        text: 'Already have an account? '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () => context.pop(),
                                        child: Text('Sign in',
                                            style: GoogleFonts.inter(
                                                color: const Color(
                                                    0xFFE50914),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor,
      Color subtitleColor, Color borderColor) {
    final perfColor =
    isDark ? const Color(0xFF2A2A35) : const Color(0xFFDDDDE8);
    final cellColors = isDark
        ? [
      const Color(0xFF130D2A),
      const Color(0xFF0D1A2E),
      const Color(0xFF1A0D2E),
      const Color(0xFF0D1520),
      const Color(0xFF1A1330),
    ]
        : [
      const Color(0xFFEDE9FF),
      const Color(0xFFE0EDFF),
      const Color(0xFFEEE9FF),
      const Color(0xFFE5EEFF),
      const Color(0xFFECE8FF),
    ];
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : const Color(0xFF6C63FF).withValues(alpha: 0.4);
    final cellIcons = [
      Icons.movie_outlined,
      Icons.auto_awesome_outlined,
      Icons.movie_creation_outlined,
      Icons.camera_roll_outlined,
      Icons.live_tv_outlined,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar — back button + logo
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: textColor, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.movie_filter_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text('Watchly',
                      style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Film strip — violet-tinted cells for register
          SizedBox(
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
                          margin:
                          const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: cellColors[i],
                          ),
                          child: Center(
                            child: Icon(cellIcons[i],
                                color: iconColor, size: 15),
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
          ),

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
                    text: 'Join the\n',
                    style: TextStyle(color: textColor)),
                const TextSpan(
                    text: 'Cinephiles.',
                    style: TextStyle(color: Color(0xFF6C63FF))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your free account and start watching in minutes.',
            style: GoogleFonts.inter(
                color: subtitleColor, fontSize: 14, height: 1.5),
          ),
        ],
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
          const BorderSide(color: Color(0xFF6C63FF), width: 1.5)),
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

// ── Shared perforations widget ────────────────────────────────────────────────
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