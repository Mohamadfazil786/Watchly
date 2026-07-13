import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/image_helper.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // User Card
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.border,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE50914).withValues(alpha: 0.15),
                    backgroundImage: user.photoUrl.isNotEmpty ? ImageHelper.getAvatarImage(user.photoUrl) : null,
                    child: user.photoUrl.isEmpty
                        ? Text(
                            user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                            style: GoogleFonts.outfit(color: const Color(0xFFE50914), fontSize: 24, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          user.email,
                          style: GoogleFonts.inter(
                            color: context.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Theme Settings Section
          _sectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            trailing: Switch.adaptive(
              value: isDark,
              activeThumbColor: const Color(0xFFE50914),
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).update((state) {
                  final newState = !state;
                  Hive.box(AppConstants.userPrefsBox).put('is_dark_mode', newState);
                  return newState;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // Account Settings Section
          _sectionHeader(context, 'General'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Push Notifications',
            trailing: Switch.adaptive(
              value: true,
              activeThumbColor: const Color(0xFFE50914),
              onChanged: (_) {},
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.cleaning_services_rounded,
            title: 'Clear Cache',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Color(0xFF00C853),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'About CineVerse',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'CineVerse',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE50914), Color(0xFFFF9233)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 28),
                ),
                applicationLegalese: '© 2026 CineVerse Team. All rights reserved.',
              );
            },
          ),
          const SizedBox(height: 40),

          // Logout Button
          if (user != null)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate immediately for a snappy experience.
                  // signOut() awaits only _auth.signOut() (fast); Google
                  // sign-out runs fire-and-forget in the repository.
                  context.go('/auth/login');
                  ref.read(authRepositoryProvider).signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3333).withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFFFF3333),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFF3333), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: context.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFFE50914)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: context.textPrimary,
          ),
        ),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios_rounded, size: 16) : null),
      ),
    );
  }
}



