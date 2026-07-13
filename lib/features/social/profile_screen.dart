import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/providers/providers.dart';
import '../../core/models/user_model.dart';
import '../../core/models/review_model.dart';
import '../../core/models/custom_list_model.dart';
import '../../core/models/watchlist_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/image_helper.dart';

final profileUserProvider = StreamProvider.autoDispose.family<UserModel?, String>((ref, uid) {
  return ref.read(authRepositoryProvider).watchUserProfile(uid);
});

final profileReviewsProvider = FutureProvider.autoDispose.family<List<ReviewModel>, String>((ref, uid) {
  return ref.read(reviewsRepositoryProvider).getUserReviews(uid);
});

// ─── Design Tokens (shared with home_screen) ─────────────────────────────────

class _C {
  static const darkBg       = Color(0xFF000000);
  static const darkSurface  = Color(0xFF15181C);
  static const darkSurface2 = Color(0xFF202327);
  static const darkBorder   = Color(0xFF2F3336);
  static const darkText     = Color(0xFFF7F9F9);
  static const darkSubtext  = Color(0xFF71767B);
  static const darkMuted    = Color(0xFF71767B);

  static const lightBg      = Color(0xFFF5F0E8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder  = Color(0xFFE8E2D8);
  static const lightText    = Color(0xFF1A1A2E);
  static const lightSubtext = Color(0xFF6B6878);

  static const red   = Color(0xFFE50914);
  static const redDim= Color(0xFF8B0000);
  static const gold  = Color(0xFFC8A96E);
  static const green = Color(0xFF1DB954);
  static const amber = Color(0xFFFF9500);
}

extension _ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg          => isDark ? _C.darkBg       : _C.lightBg;
  Color get surface     => isDark ? _C.darkSurface  : _C.lightSurface;
  Color get surface2    => isDark ? _C.darkSurface2 : const Color(0xFFF0EBE0);
  Color get border      => isDark ? _C.darkBorder   : _C.lightBorder;
  Color get textPrimary => isDark ? _C.darkText     : _C.lightText;
  Color get textSub     => isDark ? _C.darkSubtext  : _C.lightSubtext;
  Color get muted       => isDark ? _C.darkMuted    : const Color(0xFFBBB5A8);
}

// ─── Entry Point ─────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerWidget {
  final String? uid;
  const ProfileScreen({super.key, this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwnProfile = uid == null || uid == currentUser?.uid;
    final targetUid = uid ?? currentUser?.uid ?? '';

    if (targetUid.isEmpty) {
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: CircularProgressIndicator(color: _C.red)),
      );
    }
    return _ProfileBody(uid: targetUid, isOwnProfile: isOwnProfile);
  }
}

// ─── Profile Body ─────────────────────────────────────────────────────────────

class _ProfileBody extends ConsumerStatefulWidget {
  final String uid;
  final bool isOwnProfile;
  const _ProfileBody({required this.uid, required this.isOwnProfile});

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody>
    with SingleTickerProviderStateMixin {
  bool? _following;
  int _selectedTab = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    if (!widget.isOwnProfile) _loadFollowState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowState() async {
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    if (uid.isEmpty) return;
    final f = await ref.read(socialRepositoryProvider).isFollowing(uid, widget.uid);
    if (mounted) setState(() => _following = f);
  }

  Future<void> _toggleFollow(String targetUid) async {
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    if (uid.isEmpty) return;
    setState(() => _following = !(_following ?? false));
    if (_following!) {
      await ref.read(socialRepositoryProvider).followUser(uid, targetUid);
    } else {
      await ref.read(socialRepositoryProvider).unfollowUser(uid, targetUid);
    }
  }

  void _showEditProfile(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        user: user,
        onSaved: () {
          ref.invalidate(profileUserProvider(widget.uid));
          ref.invalidate(profileReviewsProvider(widget.uid));
          ref.invalidate(userListsProvider(widget.uid));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser   = ref.watch(currentUserProvider);
    final userAsync     = ref.watch(profileUserProvider(widget.uid));
    final reviewsAsync  = ref.watch(profileReviewsProvider(widget.uid));
    final listsAsync    = ref.watch(userListsProvider(widget.uid));
    final watchlistAsync= ref.watch(userWatchlistProvider(widget.uid));

    UserModel? displayUser = widget.isOwnProfile ? currentUser : null;
    bool isLoading = false;
    String? errorMsg;

    userAsync.when(
      loading: () { if (!widget.isOwnProfile) isLoading = true; },
      error: (e, _) { if (!widget.isOwnProfile) errorMsg = 'Profile not found'; },
      data: (u) { if (u != null) displayUser = u; },
    );

    if (isLoading) {
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: CircularProgressIndicator(color: _C.red)),
      );
    }

    if (displayUser == null) {
      return Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textSub),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_rounded, color: context.muted, size: 56),
              const SizedBox(height: 16),
              Text(
                errorMsg ?? 'User not found',
                style: GoogleFonts.inter(color: context.textSub, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    final user = displayUser!;

    return Scaffold(
      backgroundColor: context.bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          // ── App Bar ───────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: context.bg,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            leading: widget.isOwnProfile
                ? null
                : IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.textSub, size: 20),
            ),
            title: widget.isOwnProfile
                ? null
                : Text(
              user.username,
              style: GoogleFonts.outfit(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            actions: [
              if (widget.isOwnProfile) ...[
                _AppBarIconBtn(
                  icon: Icons.edit_outlined,
                  onTap: () => _showEditProfile(user),
                  context: context,
                ),
                _AppBarIconBtn(
                  icon: Icons.settings_rounded,
                  onTap: () => context.push('/settings'),
                  context: context,
                ),
                const SizedBox(width: 4),
              ],
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, thickness: 0.8, color: context.border.withValues(alpha: 0.5)),
            ),
          ),

          // ── Profile Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(
              user: user,
              isOwnProfile: widget.isOwnProfile,
              following: _following,
              onFollow: () => _toggleFollow(user.uid),
              onEditAvatar: () => _showEditProfile(user),
            ),
          ),

          // ── Tab Bar ───────────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                onTap: (i) => setState(() => _selectedTab = i),
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
                labelColor: _C.red,
                unselectedLabelColor: context.textSub,
                indicatorColor: _C.red,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: context.border,
                tabs: [
                  Tab(text: 'Reviews (${user.reviewsCount})'),
                  const Tab(text: 'My Lists'),
                  const Tab(text: 'Watchlist'),
                ],
              ),
              color: context.bg,
            ),
          ),
        ],

        // ── Tab Content ───────────────────────────────────────────────────
        body: TabBarView(
          controller: _tabController,
          children: [
            // Reviews
            reviewsAsync.when(
              loading: () => const _LoadingSliver(),
              error: (_, __) => const _EmptyState(icon: Icons.error_outline, message: 'Could not load reviews'),
              data: (reviews) => reviews.isEmpty
                  ? const _EmptyState(icon: Icons.rate_review_outlined, message: 'No reviews yet')
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: reviews.length,
                itemBuilder: (_, i) => _ProfileReviewCard(review: reviews[i]),
              ),
            ),

            // Lists
            listsAsync.when(
              loading: () => const _LoadingSliver(),
              error: (_, __) => const _EmptyState(icon: Icons.error_outline, message: 'Could not load lists'),
              data: (userLists) {
                final items = widget.isOwnProfile ? userLists.length + 1 : userLists.length;
                if (items == 0 || (items == 1 && widget.isOwnProfile && userLists.isEmpty)) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      if (widget.isOwnProfile) _CreateListTile(),
                      if (!widget.isOwnProfile)
                        const _EmptyState(icon: Icons.playlist_add_rounded, message: 'No lists yet'),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: items,
                  itemBuilder: (_, i) {
                    if (widget.isOwnProfile) {
                      if (i == 0) return _CreateListTile();
                      return _ProfileListCard(list: userLists[i - 1]);
                    }
                    return _ProfileListCard(list: userLists[i]);
                  },
                );
              },
            ),

            // Watchlist
            watchlistAsync.when(
              loading: () => const _LoadingSliver(),
              error: (_, __) => const _EmptyState(icon: Icons.error_outline, message: 'Could not load watchlist'),
              data: (watchlist) => watchlist.isEmpty
                  ? const _EmptyState(icon: Icons.bookmark_border_rounded, message: 'Watchlist is empty')
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: watchlist.length,
                itemBuilder: (_, i) => _ProfileWatchlistTile(item: watchlist[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky Tab Bar Delegate ──────────────────────────────────────────────────

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;
  const _StickyTabBarDelegate(this.tabBar, {required this.color});

  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: color, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) =>
      old.tabBar != tabBar || old.color != color;
}

// ─── App Bar Icon Button ──────────────────────────────────────────────────────

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final BuildContext context;
  const _AppBarIconBtn({required this.icon, required this.onTap, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.border),
        ),
        child: Icon(icon, size: 18, color: context.textSub),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isOwnProfile;
  final bool? following;
  final VoidCallback onFollow;
  final VoidCallback onEditAvatar;

  const _ProfileHeader({
    required this.user,
    required this.isOwnProfile,
    required this.following,
    required this.onFollow,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + Name row ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  GestureDetector(
                    onTap: isOwnProfile ? onEditAvatar : null,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _C.red.withValues(alpha: 0.4),
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: _C.red.withValues(alpha: 0.12),
                        backgroundImage: user.photoUrl.isNotEmpty
                            ? ImageHelper.getAvatarImage(user.photoUrl)
                            : null,
                        child: user.photoUrl.isEmpty
                            ? Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.outfit(
                            color: _C.red,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                            : null,
                      ),
                    ),
                  ),
                  if (isOwnProfile)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: onEditAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _C.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.bg,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _C.red.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 11),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 18),

              // Name, email, bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: GoogleFonts.outfit(
                        color: context.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: GoogleFonts.inter(
                        color: context.muted,
                        fontSize: 12,
                      ),
                    ),
                    if (user.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        user.bio,
                        style: GoogleFonts.inter(
                          color: context.textSub,
                          fontSize: 13,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Stats row ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.border),
              boxShadow: context.isDark
                  ? []
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCell(value: '${user.moviesWatchedCount}', label: 'Films'),
                _VerticalDivider(),
                _StatCell(value: '${user.reviewsCount}', label: 'Reviews'),
                _VerticalDivider(),
                _StatCell(value: '${user.followersCount}', label: 'Followers'),
                _VerticalDivider(),
                _StatCell(value: '${user.followingCount}', label: 'Following'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Follow button ────────────────────────────────────────────────
          if (!isOwnProfile && following != null)
            _FollowButton(following: following!, onTap: onFollow),

          // ── Favorite Genres ──────────────────────────────────────────────
          if (user.favoriteGenres.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionLabel(label: 'Favourite Genres'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.favoriteGenres
                  .map((g) => _GenreChip(label: g))
                  .toList(),
            ),
          ],

          // ── Top Movies ───────────────────────────────────────────────────
          if (user.topMovies.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionLabel(label: 'Top Movies'),
            const SizedBox(height: 12),
            SizedBox(
              height: 162,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: user.topMovies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final posterUrl = AppConstants.posterUrl(user.topMovies[i]);
                  final hasPoster = posterUrl.isNotEmpty && posterUrl.contains('image.tmdb');
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: hasPoster
                            ? Image.network(
                          posterUrl,
                          width: 88,
                          height: 132,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _TopMoviePlaceholder(rank: i + 1),
                        )
                            : _TopMoviePlaceholder(rank: i + 1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '#${i + 1}',
                        style: GoogleFonts.outfit(
                          color: _C.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Reusable Profile Sub-Widgets ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: _C.red,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: context.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: context.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: context.textSub,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: context.border);
  }
}

class _FollowButton extends StatelessWidget {
  final bool following;
  final VoidCallback onTap;
  const _FollowButton({required this.following, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: following ? context.surface : _C.red,
          foregroundColor: following ? context.textPrimary : Colors.white,
          elevation: 0,
          side: following ? BorderSide(color: context.border) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: following ? null : _C.red.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              following ? Icons.check_rounded : Icons.person_add_rounded,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              following ? 'Following' : 'Follow',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  const _GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _C.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.red.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: _C.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TopMoviePlaceholder extends StatelessWidget {
  final int rank;
  const _TopMoviePlaceholder({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 132,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: GoogleFonts.outfit(
            color: context.muted,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ─── Loading / Empty States ───────────────────────────────────────────────────

class _LoadingSliver extends StatelessWidget {
  const _LoadingSliver();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: _C.red, strokeWidth: 2.5));
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.surface,
              shape: BoxShape.circle,
              border: Border.all(color: context.border),
            ),
            child: Icon(icon, size: 36, color: context.muted),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: GoogleFonts.inter(
              color: context.textSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Cards ────────────────────────────────────────────────────────────────

class _ProfileReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ProfileReviewCard({required this.review});

  Color _ratingColor(double r) {
    if (r >= 8) return _C.green;
    if (r >= 6) return _C.amber;
    return _C.red;
  }

  @override
  Widget build(BuildContext context) {
    final rc = _ratingColor(review.rating);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border),
        boxShadow: context.isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rating badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rc.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: rc.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: rc, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: GoogleFonts.outfit(
                        color: rc,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.mediaTitle,
                  style: GoogleFonts.outfit(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 0.8, color: context.border),
          ),
          Text(
            review.reviewText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: context.textSub,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 13, color: _C.red.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text(
                '${review.likesCount}',
                style: GoogleFonts.inter(color: context.muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/list/create'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.red.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: _C.red, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a new list',
                    style: GoogleFonts.outfit(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Rank films, build collections, share with friends',
                    style: GoogleFonts.inter(
                      color: context.textSub,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.muted),
          ],
        ),
      ),
    );
  }
}

class _ProfileListCard extends ConsumerWidget {
  final CustomListModel list;
  const _ProfileListCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/list/${list.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
          boxShadow: context.isDark
              ? []
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Mini poster stack
            if (list.mediaItems.isNotEmpty)
              SizedBox(
                width: 86,
                height: 58,
                child: Stack(
                  children: list.mediaItems.take(3).toList().asMap().entries.map((e) {
                    final posterUrl = AppConstants.posterUrl(e.value.mediaPoster);
                    return Positioned(
                      left: e.key * 20.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: posterUrl.isNotEmpty
                            ? Image.network(
                          posterUrl,
                          width: 40,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40,
                            height: 58,
                            color: context.surface2,
                          ),
                        )
                            : Container(width: 40, height: 58, color: context.surface2),
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              Container(
                width: 40,
                height: 58,
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(Icons.movie_outlined, color: context.muted, size: 18),
              ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          list.name,
                          style: GoogleFonts.outfit(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!list.isPublic) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.lock_outline_rounded, color: context.muted, size: 13),
                      ],
                    ],
                  ),
                  if (list.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      list.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: context.textSub, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.surface2,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${list.mediaItems.length} ${list.mediaItems.length == 1 ? 'film' : 'films'}',
                      style: GoogleFonts.inter(
                        color: context.textSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: context.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileWatchlistTile extends ConsumerWidget {
  final WatchlistModel item;
  const _ProfileWatchlistTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posterUrl = AppConstants.posterUrl(item.mediaPoster);
    final isWatched = item.isWatched;
    final statusColor = isWatched ? _C.green : _C.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border),
        boxShadow: context.isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterUrl.isNotEmpty
                ? Image.network(
              posterUrl,
              width: 46,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _posterFallback(context),
            )
                : _posterFallback(context),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.mediaTitle,
                  style: GoogleFonts.outfit(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isWatched ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        size: 11,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isWatched ? 'Watched' : 'To Watch',
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isWatched)
            GestureDetector(
              onTap: () async {
                final uid = ref.read(currentUserProvider)?.uid ?? '';
                await ref.read(listsRepositoryProvider).markAsWatched(uid, item.mediaId);
                ref.invalidate(userWatchlistProvider(uid));
              },
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _C.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.green.withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.check_rounded, color: _C.green, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _posterFallback(BuildContext context) {
    return Container(
      width: 46,
      height: 68,
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.movie_rounded, color: context.muted, size: 20),
    );
  }
}

// ─── Edit Profile Sheet ───────────────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  final UserModel user;
  final VoidCallback onSaved;
  const _EditProfileSheet({required this.user, required this.onSaved});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _movieSearchCtrl;

  late String _photoUrl;
  bool _isUploadingPhoto = false;

  late List<String> _genres;
  late List<String> _topMoviePosters;

  bool _isSaving = false;
  bool _isSearchingMovies = false;
  List<Map<String, String>> _movieSearchResults = [];

  static const List<String> _allGenres = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime', 'Documentary',
    'Drama', 'Family', 'Fantasy', 'History', 'Horror', 'Music',
    'Mystery', 'Romance', 'Sci-Fi', 'Thriller', 'War', 'Western',
  ];

  @override
  void initState() {
    super.initState();
    _usernameCtrl  = TextEditingController(text: widget.user.username);
    _bioCtrl       = TextEditingController(text: widget.user.bio);
    _movieSearchCtrl = TextEditingController();
    _photoUrl      = widget.user.photoUrl;
    _genres        = List.from(widget.user.favoriteGenres);
    _topMoviePosters = List.from(widget.user.topMovies);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _movieSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
      imageQuality: 70,
    );
    if (picked == null) return;
    setState(() => _isUploadingPhoto = true);
    try {
      final file = File(picked.path);
      final storageRef = FirebaseStorage.instance
          .ref('profile_photos/${widget.user.uid}.jpg');
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();
      if (mounted) setState(() => _photoUrl = url);
    } catch (e) {
      try {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Profile photo updated successfully.'),
            backgroundColor: const Color(0xFF00C853),
            duration: const Duration(seconds: 3),
          ));
          setState(() => _photoUrl = base64String);
        }
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to process photo: $e2'),
            backgroundColor: const Color(0xFFE50914),
          ));
        }
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _movieSearchResults = []);
      return;
    }
    setState(() => _isSearchingMovies = true);
    try {
      final movies = await ref.read(moviesRepositoryProvider).searchMovies(query);
      setState(() {
        _movieSearchResults = movies.take(6).map((m) => {
          'id': m.id,
          'title': m.title,
          'poster': m.posterPath,
        }).toList();
      });
    } catch (_) {
      setState(() => _movieSearchResults = []);
    } finally {
      if (mounted) setState(() => _isSearchingMovies = false);
    }
  }

  Future<void> _save() async {
    if (_usernameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final updated = widget.user.copyWith(
        username: _usernameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        photoUrl: _photoUrl,
        favoriteGenres: _genres,
        topMovies: _topMoviePosters,
      );
      await ref.read(authRepositoryProvider).updateUserProfile(updated);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: _C.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.93),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            child: Row(
              children: [
                Text(
                  'Edit Profile',
                  style: GoogleFonts.outfit(
                    color: context.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _isSaving ? null : _save,
                  style: TextButton.styleFrom(
                    backgroundColor: _C.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    'Save',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 16, color: context.border),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 4, 20, bottom + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar ──────────────────────────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _C.red.withValues(alpha: 0.4), width: 2.5),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: _C.red.withValues(alpha: 0.1),
                              backgroundImage: _photoUrl.isNotEmpty
                                  ? ImageHelper.getAvatarImage(_photoUrl)
                                  : null,
                              child: _isUploadingPhoto
                                  ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: _C.red),
                              )
                                  : _photoUrl.isEmpty
                                  ? Text(
                                _usernameCtrl.text.isNotEmpty
                                    ? _usernameCtrl.text[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.outfit(
                                  color: _C.red,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: _C.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: context.surface, width: 2),
                                boxShadow: [
                                  BoxShadow(color: _C.red.withValues(alpha: 0.4), blurRadius: 6),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Tap to change photo',
                      style: GoogleFonts.inter(color: context.muted, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Username ────────────────────────────────────────────
                  _SheetLabel('Username'),
                  _SheetField(controller: _usernameCtrl, hint: 'Your display name'),
                  const SizedBox(height: 16),

                  // ── Bio ─────────────────────────────────────────────────
                  _SheetLabel('Bio'),
                  _SheetField(controller: _bioCtrl, hint: 'Tell people about yourself...', maxLines: 3),
                  const SizedBox(height: 28),

                  // ── Genres ──────────────────────────────────────────────
                  _SheetLabel('Favourite Genres'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allGenres.map((g) {
                      final selected = _genres.contains(g);
                      return GestureDetector(
                        onTap: () => setState(() {
                          selected ? _genres.remove(g) : _genres.add(g);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? _C.red
                                : context.surface2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? _C.red : context.border,
                            ),
                          ),
                          child: Text(
                            g,
                            style: GoogleFonts.inter(
                              color: selected ? Colors.white : context.textSub,
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // ── Top Movies ──────────────────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Top Movies',
                        style: GoogleFonts.outfit(
                          color: context.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.surface2,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_topMoviePosters.length}/5',
                          style: GoogleFonts.inter(color: context.textSub, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      if (_topMoviePosters.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _topMoviePosters.clear()),
                          child: Text(
                            'Clear all',
                            style: GoogleFonts.inter(color: context.muted, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_topMoviePosters.isNotEmpty) ...[
                    SizedBox(
                      height: 118,
                      child: ReorderableListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _topMoviePosters.length,
                        onReorder: (oldIdx, newIdx) {
                          setState(() {
                            if (newIdx > oldIdx) newIdx--;
                            final item = _topMoviePosters.removeAt(oldIdx);
                            _topMoviePosters.insert(newIdx, item);
                          });
                        },
                        itemBuilder: (_, i) {
                          final poster = _topMoviePosters[i];
                          return Container(
                            key: ValueKey('poster_${i}_$poster'),
                            width: 76,
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: poster.isNotEmpty
                                      ? Image.network(
                                    AppConstants.posterUrl(poster),
                                    width: 76,
                                    height: 114,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _editPlaceholder(context, i + 1),
                                  )
                                      : _editPlaceholder(context, i + 1),
                                ),
                                // Rank bar
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(9)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#${i + 1}',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Remove button
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _topMoviePosters.removeAt(i)),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded, size: 11, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_topMoviePosters.length < 5) ...[
                    TextField(
                      controller: _movieSearchCtrl,
                      style: TextStyle(color: context.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search a movie to add…',
                        hintStyle: TextStyle(color: context.muted),
                        filled: true,
                        fillColor: context.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: context.muted),
                        suffixIcon: _isSearchingMovies
                            ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _C.red),
                          ),
                        )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: _searchMovies,
                    ),
                    if (_movieSearchResults.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: context.surface2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.border),
                        ),
                        child: Column(
                          children: _movieSearchResults.map((m) {
                            final alreadyAdded = _topMoviePosters.contains(m['poster']);
                            return ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              leading: m['poster']!.isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  AppConstants.posterUrl(m['poster']!),
                                  width: 34,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.movie_rounded, color: context.muted, size: 28),
                                ),
                              )
                                  : Icon(Icons.movie_rounded, color: context.muted),
                              title: Text(
                                m['title']!,
                                style: GoogleFonts.inter(
                                  color: context.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: alreadyAdded
                                  ? const Icon(Icons.check_circle_rounded, color: _C.green, size: 20)
                                  : const Icon(Icons.add_circle_outline_rounded, color: _C.red, size: 20),
                              onTap: alreadyAdded
                                  ? null
                                  : () => setState(() {
                                if (_topMoviePosters.length < 5) {
                                  _topMoviePosters.add(m['poster']!);
                                }
                                _movieSearchCtrl.clear();
                                _movieSearchResults = [];
                              }),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editPlaceholder(BuildContext context, int rank) => Container(
    width: 76,
    height: 114,
    decoration: BoxDecoration(
      color: context.surface2,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Center(
      child: Text(
        '#$rank',
        style: GoogleFonts.outfit(color: context.muted, fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

// ─── Sheet Helpers ────────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: context.textSub,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  const _SheetField({required this.controller, this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: context.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: context.muted, fontSize: 14),
        filled: true,
        fillColor: context.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}