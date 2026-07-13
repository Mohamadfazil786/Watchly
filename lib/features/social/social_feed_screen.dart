import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/review_model.dart';
import '../../core/models/notification_model.dart';
import '../../core/utils/image_helper.dart';
import '../../core/constants/app_constants.dart';
import '../reviews/review_comments_sheet.dart';

final _socialFeedProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final reviews = await ref.read(reviewsRepositoryProvider).getPopularReviews(limit: 20);
  final uid = ref.read(currentUserProvider)?.uid ?? '';
  if (uid.isNotEmpty) {
    for (final review in reviews) {
      ref.read(reviewsRepositoryProvider).isReviewLiked(uid, review.id).then((liked) {
        ref.read(reviewLikesProvider.notifier).setLiked(review.id, liked);
      });
    }
  }
  return reviews;
});

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // When Activity tab is selected, mark all notifications as read
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid != null && uid.isNotEmpty) {
        ref.read(notificationRepositoryProvider).markAllAsRead(uid);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(_socialFeedProvider);
    final notifications = ref.watch(notificationsStreamProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider).value ?? 0;
    final bg = context.bg;
    final isDark = context.isDark;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final headerBtnBg = context.surface2;
    final headerBtnBorder = context.border;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Social',
                    style: GoogleFonts.outfit(
                        color: textColor, fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: () => context.push('/users/search'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: headerBtnBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: headerBtnBorder),
                      ),
                      child: Icon(Icons.person_search_rounded,
                          color: context.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFE50914),
              unselectedLabelColor: subColor,
              indicatorColor: const Color(0xFFE50914),
              indicatorWeight: 2,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                const Tab(text: 'Reviews'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Activity'),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Reviews Feed ─────────────────────────────────────────────
                  feed.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFE50914))),
                    error: (_, __) =>
                        Center(child: Text('Failed to load', style: TextStyle(color: subColor))),
                    data: (reviews) => reviews.isEmpty
                        ? _EmptyState(
                            icon: Icons.rate_review_outlined,
                            title: 'No reviews yet',
                            subtitle: 'Be the first to review a movie!',
                            isDark: isDark,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: reviews.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (ctx, i) => _ReviewFeedCard(review: reviews[i]),
                          ),
                  ),

                  // ── Activity (Notifications) ──────────────────────────────────
                  notifications.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFE50914))),
                    error: (_, __) =>
                        Center(child: Text('Failed to load', style: TextStyle(color: subColor))),
                    data: (notifs) => notifs.isEmpty
                        ? _EmptyState(
                            icon: Icons.notifications_none_rounded,
                            title: 'No notifications yet',
                            subtitle:
                                'When someone follows you or reviews a movie, you\'ll see it here.',
                            isDark: isDark,
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: notifs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) => _NotificationTile(
                              notification: notifs[i],
                              isDark: isDark,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notification Tile ────────────────────────────────────────────────────────

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  final bool isDark;

  const _NotificationTile({required this.notification, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardBg = context.surface;
    final borderCol = context.border;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final timeColor = context.muted;

    final isUnread = !notification.isRead;

    final IconData icon = notification.type == 'follow'
        ? Icons.person_add_rounded
        : notification.type == 'review'
            ? Icons.rate_review_rounded
            : Icons.notifications_rounded;

    final Color iconColor = notification.type == 'follow'
        ? const Color(0xFF6C63FF)
        : notification.type == 'review'
            ? const Color(0xFFE50914)
            : const Color(0xFFFFD700);

    return GestureDetector(
      onTap: () {
        if (isUnread) {
          ref.read(notificationRepositoryProvider).markAsRead(notification.id);
        }
        if (notification.type == 'follow' || notification.type == 'review') {
          context.push('/user/${notification.senderId}');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? (context.surface)
              : cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? const Color(0xFF6C63FF).withValues(alpha: 0.35)
                : borderCol,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with type-icon overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: iconColor.withValues(alpha: 0.15),
                  backgroundImage: notification.senderPhotoUrl.isNotEmpty ? ImageHelper.getAvatarImage(notification.senderPhotoUrl) : null,
                  child: notification.senderPhotoUrl.isEmpty
                      ? Text(
                          notification.senderUsername.isNotEmpty
                              ? notification.senderUsername[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.outfit(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: _buildMessageSpans(notification.message, textColor, subColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: GoogleFonts.inter(color: timeColor, fontSize: 11),
                  ),
                ],
              ),
            ),

            // Unread indicator dot
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Bold the @username part of the message
  List<TextSpan> _buildMessageSpans(String message, Color textColor, Color subColor) {
    final regex = RegExp(r'@\w+');
    final spans = <TextSpan>[];
    int last = 0;
    for (final match in regex.allMatches(message)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: message.substring(last, match.start),
          style: GoogleFonts.inter(color: subColor, fontSize: 13),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: GoogleFonts.inter(
            color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
      ));
      last = match.end;
    }
    if (last < message.length) {
      spans.add(TextSpan(
        text: message.substring(last),
        style: GoogleFonts.inter(color: subColor, fontSize: 13),
      ));
    }
    return spans;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE50914).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFE50914), size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: context.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Review Feed Card ─────────────────────────────────────────────────────────

class _ReviewFeedCard extends ConsumerStatefulWidget {
  final ReviewModel review;
  const _ReviewFeedCard({required this.review});

  @override
  ConsumerState<_ReviewFeedCard> createState() => _ReviewFeedCardState();
}

class _ReviewFeedCardState extends ConsumerState<_ReviewFeedCard>
    with SingleTickerProviderStateMixin {
  bool? _liked;
  bool _likedInitially = false;
  late ReviewModel _review;
  late AnimationController _heartController;
  late Animation<double> _heartAnim;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
    _heartController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _heartAnim = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    final cachedLike = ref.read(reviewLikesProvider)[_review.id];
    if (cachedLike != null) {
      _liked = cachedLike;
      _likedInitially = cachedLike;
    } else {
      _checkLiked();
    }
  }

  Future<void> _checkLiked() async {
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    if (uid.isEmpty) return;
    final liked = await ref.read(reviewsRepositoryProvider).isReviewLiked(uid, _review.id);
    ref.read(reviewLikesProvider.notifier).setLiked(_review.id, liked);
    if (mounted) {
      setState(() {
        _liked = liked;
        _likedInitially = liked;
      });
    }
  }

  Future<void> _toggleLike() async {
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    if (uid.isEmpty) return;

    final isLiked = ref.read(reviewLikesProvider)[_review.id] ?? _liked ?? false;
    _heartController.forward(from: 0);

    ref.read(reviewLikesProvider.notifier).setLiked(_review.id, !isLiked);

    try {
      if (isLiked) {
        await ref.read(reviewsRepositoryProvider).unlikeReview(uid, _review.id);
      } else {
        await ref.read(reviewsRepositoryProvider).likeReview(uid, _review.id);
      }
    } catch (_) {
      ref.read(reviewLikesProvider.notifier).setLiked(_review.id, isLiked);
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = context.surface;
    final borderCol = context.border;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final textBodyColor = context.textPrimary.withOpacity(0.85);

    final ratingColor = _review.rating >= 8
        ? const Color(0xFF00C853)
        : _review.rating >= 6
            ? const Color(0xFFFF9233)
            : const Color(0xFFE50914);

    final isLiked = ref.watch(reviewLikesProvider)[_review.id] ?? _liked ?? false;

    int displayLikesCount = _review.likesCount;
    if (isLiked != _likedInitially) {
      displayLikesCount += isLiked ? 1 : -1;
    }
    if (displayLikesCount < 0) displayLikesCount = 0;

    final commentsAsync = ref.watch(reviewCommentsProvider(_review.id));
    final displayCommentsCount = commentsAsync.value?.length ?? _review.commentsCount;

    final posterUrl = AppConstants.posterUrl(_review.mediaPoster);

    return GestureDetector(
      onTap: () => context.push('/review/detail', extra: _review),
      onDoubleTap: _toggleLike,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Row
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/user/${_review.userId}'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE50914).withValues(alpha: 0.2),
                    backgroundImage: _review.userPhotoUrl.isNotEmpty ? ImageHelper.getAvatarImage(_review.userPhotoUrl) : null,
                    child: _review.userPhotoUrl.isEmpty
                        ? Text(
                            _review.username.isNotEmpty ? _review.username[0].toUpperCase() : '?',
                            style: GoogleFonts.outfit(
                                color: const Color(0xFFE50914), fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/user/${_review.userId}'),
                        child: Text(
                          _review.username,
                          style: GoogleFonts.inter(
                              color: textColor, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'reviewed ${_review.mediaTitle}',
                        style: GoogleFonts.inter(color: subColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ratingColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_review.rating.toStringAsFixed(1)} ★',
                    style: GoogleFonts.outfit(
                        color: ratingColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content row with movie poster & review text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _posterFallback(context),
                        )
                      : _posterFallback(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _review.reviewText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: textBodyColor, fontSize: 13, height: 1.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: borderCol, height: 1, thickness: 0.6),
            const SizedBox(height: 12),

            // Footer row: interactive like, comment, and date
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedBuilder(
                    animation: _heartAnim,
                    builder: (_, child) =>
                        Transform.scale(scale: _heartAnim.value, child: child),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isLiked ? const Color(0xFFE50914) : subColor,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$displayLikesCount',
                          style: GoogleFonts.inter(
                              color: isLiked ? const Color(0xFFE50914) : subColor,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ReviewCommentsSheet(review: _review),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, color: subColor, size: 16),
                      const SizedBox(width: 4),
                      Text('$displayCommentsCount',
                          style: GoogleFonts.inter(color: subColor, fontSize: 13)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(_review.createdAt),
                  style: GoogleFonts.inter(color: subColor, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterFallback(BuildContext context) {
    return Container(
      width: 50,
      height: 75,
      color: context.surface2,
      child: Icon(Icons.movie_rounded, size: 24, color: context.muted),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

