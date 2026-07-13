import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/review_model.dart';
import '../../core/models/comment_model.dart';
import '../../core/models/movie_model.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/image_helper.dart';

final mediaDetailsProvider = FutureProvider.autoDispose.family<MovieModel, ({String id, bool isTv})>((ref, args) {
  return args.isTv
      ? ref.read(moviesRepositoryProvider).getTvShowDetails(args.id)
      : ref.read(moviesRepositoryProvider).getMovieDetails(args.id);
});

class ReviewDetailsScreen extends ConsumerStatefulWidget {
  final ReviewModel review;
  const ReviewDetailsScreen({super.key, required this.review});

  @override
  ConsumerState<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends ConsumerState<ReviewDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _checkLikedState();
  }

  Future<void> _checkLikedState() async {
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    if (uid.isNotEmpty) {
      final isLiked = await ref.read(reviewsRepositoryProvider).isReviewLiked(uid, widget.review.id);
      ref.read(reviewLikesProvider.notifier).setLiked(widget.review.id, isLiked);
    }
  }

  Future<void> _toggleLike(bool currentlyLiked) async {
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    if (uid.isEmpty) return;

    ref.read(reviewLikesProvider.notifier).setLiked(widget.review.id, !currentlyLiked);

    try {
      if (currentlyLiked) {
        await ref.read(reviewsRepositoryProvider).unlikeReview(uid, widget.review.id);
      } else {
        await ref.read(reviewsRepositoryProvider).likeReview(uid, widget.review.id);
      }
    } catch (_) {
      ref.read(reviewLikesProvider.notifier).setLiked(widget.review.id, currentlyLiked);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isSubmittingComment = true;
    });

    final comment = CommentModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      reviewId: widget.review.id,
      userId: user.uid,
      username: user.username,
      userPhotoUrl: user.photoUrl,
      commentText: text,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(reviewsRepositoryProvider).addComment(comment);
      _commentController.clear();
      ref.invalidate(reviewCommentsProvider(widget.review.id));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final isTv = review.mediaType == 'tv';
    final mediaAsync = ref.watch(mediaDetailsProvider((id: review.mediaId, isTv: isTv)));
    final commentsAsync = ref.watch(reviewCommentsProvider(review.id));
    final likedMap = ref.watch(reviewLikesProvider);
    final isLiked = likedMap[review.id] ?? false;

    final bg = context.bg;
    final surface = context.surface;
    final surface2 = context.surface2;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final borderCol = context.border;
    final ratingColor = review.rating >= 8
        ? const Color(0xFF00C853)
        : review.rating >= 6
        ? const Color(0xFFFF9233)
        : const Color(0xFFE50914);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Collapsible App Bar with Backdrop Image (no blur, clean gradient)
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: bg,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Sharp movie backdrop, no blur
                        if (review.mediaPoster.isNotEmpty)
                          Image.network(
                            AppConstants.posterUrl(review.mediaPoster, size: 'w780'),
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(color: Colors.black);
                            },
                            errorBuilder: (_, __, ___) => _backdropFallback(),
                          )
                        else
                          _backdropFallback(),
                        // Soft vignette gradient only — no blur
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.55, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.25),
                                Colors.transparent,
                                bg,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Movie Info & Poster Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Poster
                        Container(
                          width: 95,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: review.mediaPoster.isNotEmpty
                                ? Image.network(
                              AppConstants.posterUrl(review.mediaPoster, size: 'w500'),
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: surface2,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFFE50914),
                                      strokeWidth: 2,
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: surface2,
                                child: Icon(Icons.movie_rounded, color: subColor, size: 36),
                              ),
                            )
                                : Container(
                              color: surface2,
                              child: Icon(Icons.movie_rounded, color: subColor, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Movie Title and Metadata
                        Expanded(
                          child: mediaAsync.when(
                            loading: () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: 140, height: 16, color: surface2),
                                const SizedBox(height: 8),
                                Container(width: 80, height: 12, color: surface2),
                                const SizedBox(height: 8),
                                Container(width: 60, height: 20, color: surface2),
                              ],
                            ),
                            error: (_, __) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.mediaTitle,
                                  style: GoogleFonts.outfit(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isTv ? 'TV Show' : 'Movie',
                                  style: GoogleFonts.inter(color: subColor, fontSize: 13),
                                ),
                              ],
                            ),
                            data: (media) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  media.title,
                                  style: GoogleFonts.outfit(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${media.releaseDate.length >= 4 ? media.releaseDate.substring(0, 4) : media.releaseDate}  •  ${media.genres.join(', ')}',
                                  style: GoogleFonts.inter(
                                    color: subColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            media.rating.toStringAsFixed(1),
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFFFD700),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
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
                  ),
                ),

                // Reviewer Info Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFE50914).withValues(alpha: 0.15),
                              backgroundImage: review.userPhotoUrl.isNotEmpty ? ImageHelper.getAvatarImage(review.userPhotoUrl) : null,
                              child: review.userPhotoUrl.isEmpty
                                  ? Text(
                                review.username.isNotEmpty ? review.username[0].toUpperCase() : '?',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFE50914),
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.username,
                                    style: GoogleFonts.inter(
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Reviewed on ${_formatDate(review.createdAt)}',
                                    style: GoogleFonts.inter(
                                      color: subColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: ratingColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ratingColor.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                '${review.rating.toStringAsFixed(1)} ★',
                                style: GoogleFonts.outfit(
                                  color: ratingColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Divider(color: borderCol, height: 1),
                        const SizedBox(height: 18),

                        // Review Full Text
                        Text(
                          review.reviewText,
                          style: GoogleFonts.inter(
                            color: textColor.withValues(alpha: 0.9),
                            fontSize: 15,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(color: borderCol, height: 1),
                        const SizedBox(height: 14),

                        // Interactive Reactions (Likes & Comments headers)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _toggleLike(isLiked),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isLiked ? const Color(0xFFE50914).withValues(alpha: 0.1) : surface2,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isLiked ? const Color(0xFFE50914).withValues(alpha: 0.3) : borderCol,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isLiked ? const Color(0xFFE50914) : subColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${review.likesCount + (isLiked && widget.review.likesCount == 0 ? 1 : 0)} Likes',
                                      style: GoogleFonts.inter(
                                        color: isLiked ? const Color(0xFFE50914) : textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: surface2,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderCol),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, color: subColor, size: 16),
                                  const SizedBox(width: 6),
                                  commentsAsync.when(
                                    loading: () => Text('Comments', style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                                    error: (_, __) => Text('Comments', style: GoogleFonts.inter(color: textColor, fontSize: 13)),
                                    data: (comments) => Text(
                                      '${comments.length} Comments',
                                      style: GoogleFonts.inter(
                                        color: textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Comments Heading
                        Text(
                          'Comments',
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Comments List Section
                commentsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Text('Failed to load comments: $e', style: GoogleFonts.inter(color: subColor)),
                    ),
                  ),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                          child: Column(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, color: subColor.withValues(alpha: 0.5), size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'No comments yet',
                                style: GoogleFonts.outfit(color: textColor.withValues(alpha: 0.8), fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Be the first to share your thoughts!',
                                style: GoogleFonts.inter(color: subColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final comment = comments[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderCol),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFFE50914).withValues(alpha: 0.1),
                                    backgroundImage: comment.userPhotoUrl.isNotEmpty ? ImageHelper.getAvatarImage(comment.userPhotoUrl) : null,
                                    child: comment.userPhotoUrl.isEmpty
                                        ? Text(
                                      comment.username.isNotEmpty ? comment.username[0].toUpperCase() : '?',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFE50914),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              comment.username,
                                              style: GoogleFonts.inter(
                                                color: textColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              _timeAgo(comment.createdAt),
                                              style: GoogleFonts.inter(
                                                color: subColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.commentText,
                                          style: GoogleFonts.inter(
                                            color: textColor.withValues(alpha: 0.85),
                                            fontSize: 13,
                                            height: 1.45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: comments.length,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),

          // Sticky add comment bar at the bottom
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: surface,
              border: Border(top: BorderSide(color: borderCol)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface2,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderCol),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: textColor, fontSize: 14),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: GoogleFonts.inter(color: subColor, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmittingComment
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 2),
                  ),
                )
                    : IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFFE50914)),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backdropFallback() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.movie_filter_rounded, size: 60, color: Colors.white24),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}