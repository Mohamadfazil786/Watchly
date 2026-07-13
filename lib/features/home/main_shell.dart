import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/image_helper.dart';
import '../reviews/log_movie_sheet.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _openLogMovieSheet() async {
    await _fabController.reverse();
    await _fabController.forward();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LogMovieSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);
    final user = ref.watch(currentUserProvider);

    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location == '/search') currentIndex = 1;
    else if (location == '/social') currentIndex = 2;
    else if (location == '/profile') currentIndex = 3;

    final unreadCount = ref.watch(unreadNotificationCountProvider).value ?? 0;

    return Scaffold(
      drawer: _buildDrawer(context, user, isDark),
      body: widget.child,
      bottomNavigationBar: _CinemaNavBar(
        currentIndex: currentIndex,
        isDark: isDark,
        unreadCount: unreadCount,
        fabScaleAnim: _fabScaleAnim,
        onFabTap: _openLogMovieSheet,
        onNavTap: (index) {
          switch (index) {
            case 0: context.go('/home'); break;
            case 1: context.go('/search'); break;
            case 2: context.go('/social'); break;
            case 3: context.go('/profile'); break;
          }
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, user, bool isDark) {
    return Drawer(
      backgroundColor: context.bg,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE50914), Color(0xFFFF9233)],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white24,
              backgroundImage: user?.photoUrl.isNotEmpty == true
                  ? ImageHelper.getAvatarImage(user!.photoUrl)
                  : null,
              child: user?.photoUrl.isEmpty == true || user == null
                  ? Text(
                user?.username.isNotEmpty == true
                    ? user!.username[0].toUpperCase()
                    : '?',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            accountName: Text(
              user?.username ?? 'Guest',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              user?.email ?? 'Sign in to access all features',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
            ),
          ),
          _drawerTile(context, Icons.home_rounded, 'Home', () {
            Navigator.pop(context);
            context.go('/home');
          }),
          _drawerTile(context, Icons.auto_awesome_rounded, 'AI Recommendation Center', () {
            Navigator.pop(context);
            context.push('/ai');
          }),
          _drawerTile(context, Icons.settings_rounded, 'Settings', () {
            Navigator.pop(context);
            context.push('/settings');
          }),
          const Spacer(),
          Divider(color: context.border),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: context.textSecondary),
            title: Text('Sign Out',
                style: GoogleFonts.inter(color: context.textSecondary)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/auth/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE50914)),
      title: Text(label,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, color: context.textPrimary)),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────
//  Cinema Nav Bar — standalone stateful widget
// ─────────────────────────────────────────────

class _CinemaNavBar extends StatefulWidget {
  final int currentIndex;
  final bool isDark;
  final int unreadCount;
  final Animation<double> fabScaleAnim;
  final VoidCallback onFabTap;
  final ValueChanged<int> onNavTap;

  const _CinemaNavBar({
    required this.currentIndex,
    required this.isDark,
    required this.unreadCount,
    required this.fabScaleAnim,
    required this.onFabTap,
    required this.onNavTap,
  });

  @override
  State<_CinemaNavBar> createState() => _CinemaNavBarState();
}

class _CinemaNavBarState extends State<_CinemaNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;

  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(_CinemaNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _prevIndex = oldWidget.currentIndex;
      _slideController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color redAccent = const Color(0xFFE50914);
    final bool isDark = widget.isDark;

    final Color navBg = isDark ? const Color(0xFF141414) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
    final Color inactiveColor =
    isDark ? const Color(0xFF666666) : const Color(0xFFAAAAAA);

    final List<_NavItemData> items = [
      _NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItemData(
        icon: Icons.search_outlined,
        activeIcon: Icons.search_rounded,
        label: 'Search',
      ),
      _NavItemData(
        icon: Icons.notifications_none_outlined,
        activeIcon: Icons.notifications_rounded,
        label: 'Activity',
      ),
      _NavItemData(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(color: borderColor, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              // Left two items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(2, (i) {
                    return _NavButton(
                      data: items[i],
                      isActive: widget.currentIndex == i,
                      inactiveColor: inactiveColor,
                      activeColor: redAccent,
                      slideAnim: _slideController,
                      onTap: () => widget.onNavTap(i),
                    );
                  }),
                ),
              ),

              // Center FAB
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _CinemaFab(
                  scaleAnim: widget.fabScaleAnim,
                  onTap: widget.onFabTap,
                  isDark: isDark,
                ),
              ),

              // Right two items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(2, (i) {
                    final index = i + 2;
                    return _NavButton(
                      data: items[index],
                      isActive: widget.currentIndex == index,
                      inactiveColor: inactiveColor,
                      activeColor: redAccent,
                      slideAnim: _slideController,
                      badgeCount: index == 2 ? widget.unreadCount : 0,
                      onTap: () => widget.onNavTap(index),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Individual nav button with animated label
// ─────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final Color inactiveColor;
  final Color activeColor;
  final Animation<double> slideAnim;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavButton({
    required this.data,
    required this.isActive,
    required this.inactiveColor,
    required this.activeColor,
    required this.slideAnim,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with optional badge
            _buildIcon(),
            const SizedBox(height: 3),
            // Animated label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: isActive ? 0.3 : 0,
              ),
              child: Text(data.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    Widget iconW = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Icon(
        isActive ? data.activeIcon : data.icon,
        key: ValueKey(isActive),
        color: isActive ? activeColor : inactiveColor,
        size: 24,
      ),
    );

    if (badgeCount > 0) {
      iconW = Badge(
        label: Text(
          badgeCount > 99 ? '99+' : '$badgeCount',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFE50914),
        child: iconW,
      );
    }

    return iconW;
  }
}

// ─────────────────────────────────────────────
//  Center FAB — cinematic "+" button
// ─────────────────────────────────────────────

class _CinemaFab extends StatelessWidget {
  final Animation<double> scaleAnim;
  final VoidCallback onTap;
  final bool isDark;

  const _CinemaFab({
    required this.scaleAnim,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnim,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF2D20), Color(0xFFE50914)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE50914).withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}