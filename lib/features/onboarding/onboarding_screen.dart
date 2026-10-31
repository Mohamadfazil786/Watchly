import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Discover\nCinema',
      subtitle: 'EXPLORE FILMS & SHOWS',
      description:
      'From Hollywood blockbusters to indie gems — your next obsession is one tap away.',
      primaryColor: const Color(0xFFFE0000),
      secondaryColor: const Color(0xFFFF6B35),
    ),
    OnboardingPageData(
      title: 'Track &\nCurate',
      subtitle: 'YOUR CINEMATIC IDENTITY',
      description:
      'Rate every film, write reviews, build curated lists, and own your entire watch history.',
      primaryColor: const Color(0xFF1F156C),
      secondaryColor: const Color(0xFF4A2FBD),
    ),
    OnboardingPageData(
      title: 'Connect &\nDiscover',
      subtitle: 'COMMUNITY & AI PICKS',
      description:
      'See what friends are watching and let our AI find your perfect next watch.',
      primaryColor: const Color(0xFF880805),
      secondaryColor: const Color(0xFF620B04),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/auth/login');
    }
  }

  void _getStarted() => context.go('/auth/login');

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. Full-screen PageView ──────────────────────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  'assets/images/img${index + 1}.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _pages[index].primaryColor.withValues(alpha: 0.4),
                          Colors.black,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── 2. Gradient overlay — clear top, dark bottom ─────────
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.62, 0.82, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.82),
                    Colors.black.withValues(alpha: 0.97),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Subtle accent tint on the image (very light) ──────
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.center,
                  colors: [
                    page.primaryColor.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 4. Filmstrip perforation strip (left edge) ───────────


          // ── 5. Top bar ───────────────────────────────────────────
          Positioned(
            top: topPad + 14,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: page.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.movie_filter_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Watchly',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                        letterSpacing: -0.5,
                        shadows: const [
                          Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _getStarted,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 6. Bottom content ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(28, 0, 28, bottomPad + 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eyebrow
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 18,
                            height: 2,
                            color: page.primaryColor,
                            margin: const EdgeInsets.only(right: 10),
                          ),
                          Text(
                            page.subtitle,
                            style: GoogleFonts.inter(
                              color: page.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                              shadows: const [
                                Shadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 1),
                                    blurRadius: 3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          page.title,
                          key: ValueKey(page.title),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            letterSpacing: -2,
                            shadows: const [
                              Shadow(
                                  color: Colors.black87,
                                  offset: Offset(0, 2),
                                  blurRadius: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        page.description,
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.65,
                          fontWeight: FontWeight.w400,
                          shadows: const [
                            Shadow(
                                color: Colors.black,
                                offset: Offset(0, 1),
                                blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Dots + Button row
                  Row(
                    children: [
                      // Dot indicators
                      Row(
                        children: List.generate(_pages.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 6),
                            width: isActive ? 26 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? page.primaryColor
                                  : Colors.white30,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),

                      const Spacer(),

                      // Next / Get Started button
                      GestureDetector(
                        onTap: _nextPage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 54,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 26),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                page.primaryColor,
                                page.secondaryColor
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: page.primaryColor.withValues(alpha: 0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLast ? 'Get Started' : 'Next',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isLast
                                    ? const SizedBox.shrink()
                                    : Icon(
                                  Icons.arrow_forward_rounded,
                                  key: const ValueKey('arrow'),
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filmstrip Side ────────────────────────────────────────────────────────────

class _FilmStripSide extends StatelessWidget {
  final Color accentColor;
  const _FilmStripSide({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Column(
        children: List.generate(32, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: i % 2 == 0
                    ? accentColor.withValues(alpha: 0.30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
  });
}