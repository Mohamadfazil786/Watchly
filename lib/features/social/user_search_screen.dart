import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/image_helper.dart';

final _userSearchQueryProvider = StateProvider<String>((ref) => '');

final _userSearchResultsProvider = FutureProvider.autoDispose<List<UserModel>>((ref) {
  final query = ref.watch(_userSearchQueryProvider);
  if (query.isEmpty) return Future.value([]);
  return ref.read(socialRepositoryProvider).searchUsers(query);
});

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(_userSearchResultsProvider);
    final query = ref.watch(_userSearchQueryProvider);
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final dividerColor = context.border;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: textColor),
          onChanged: (v) => ref.read(_userSearchQueryProvider.notifier).state = v,
          decoration: InputDecoration(
            hintText: 'Search users...',
            hintStyle: GoogleFonts.inter(color: subColor),
            border: InputBorder.none,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: textColor.withOpacity(0.7)),
        ),
      ),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
        error: (_, __) => Center(child: Text('Search failed', style: TextStyle(color: subColor))),
        data: (users) {
          if (query.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_rounded, color: context.muted.withOpacity(0.4), size: 64),
                  const SizedBox(height: 16),
                  Text('Search for users', style: GoogleFonts.inter(color: subColor, fontSize: 16)),
                ],
              ),
            );
          }
          if (users.isEmpty) {
            return Center(child: Text('No users found for "$query"', style: GoogleFonts.inter(color: subColor)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => Divider(color: dividerColor),
            itemBuilder: (ctx, i) => _UserTile(user: users[i]),
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final timeColor = context.muted;

    return ListTile(
      onTap: () => context.push('/user/${user.uid}'),
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE50914).withValues(alpha: 0.2),
        backgroundImage: user.photoUrl.isNotEmpty ? ImageHelper.getAvatarImage(user.photoUrl) : null,
        child: user.photoUrl.isEmpty
            ? Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: GoogleFonts.outfit(color: const Color(0xFFE50914), fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text('@${user.username}', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600)),
      subtitle: user.bio.isNotEmpty
          ? Text(user.bio, style: GoogleFonts.inter(color: subColor, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: Text('${user.followersCount} followers', style: GoogleFonts.inter(color: timeColor, fontSize: 11)),
    );
  }
}
