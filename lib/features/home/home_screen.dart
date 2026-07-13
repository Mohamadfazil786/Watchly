import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/providers.dart';
import '../../core/models/movie_model.dart';
import '../../core/models/review_model.dart';
import '../../core/constants/app_constants.dart';
import '../reviews/review_comments_sheet.dart';

final _trendingProvider = FutureProvider<List<MovieModel>>((ref) {
  return ref.read(moviesRepositoryProvider).getTrendingMovies();
});

final _popularTvProvider = FutureProvider<List<MovieModel>>((ref) {
  return ref.read(moviesRepositoryProvider).getPopularTvShows();
});

final _popularReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final reviews = await ref.read(reviewsRepositoryProvider).getPopularReviews(limit: 6);
  final uid = ref.read(currentUserProvider)?.uid ?? '';
  if (uid.isNotEmpty) {
    for (final r in reviews) {
      ref.read(reviewsRepositoryProvider).isReviewLiked(uid, r.id).then((liked) {
        ref.read(reviewLikesProvider.notifier).setLiked(r.id, liked);
      });
    }
  }
  return reviews;
});

// ─── Design Tokens ───────────────────────────────────────────────────────────

class _C {
  // Dark palette
  static const darkBg        = Color(0xFF000000);
  static const darkSurface   = Color(0xFF15181C);
  static const darkSurface2  = Color(0xFF202327);
  static const darkBorder    = Color(0xFF2F3336);
  static const darkText      = Color(0xFFF7F9F9);
  static const darkSubtext   = Color(0xFF71767B);
  static const darkMuted     = Color(0xFF71767B);

  // Light palette
  static const lightBg       = Color(0xFFF5F0E8);
  static const lightSurface  = Color(0xFFFFFFFF);
  static const lightBorder   = Color(0xFFE8E2D8);
  static const lightText     = Color(0xFF1A1A2E);
  static const lightSubtext  = Color(0xFF6B6878);

  // Accent
  static const red           = Color(0xFFE50914);
  static const redDim        = Color(0xFF8B0000);
  static const gold          = Color(0xFFC8A96E);
  static const goldDim       = Color(0xFF7A6340);
  static const green         = Color(0xFF1DB954);
  static const amber         = Color(0xFFFF9500);
  static const purple        = Color(0xFF7B5EA7);
}

extension _ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg        => isDark ? _C.darkBg       : _C.lightBg;
  Color get surface   => isDark ? _C.darkSurface  : _C.lightSurface;
  Color get surface2  => isDark ? _C.darkSurface2 : const Color(0xFFF0EBE0);
  Color get border    => isDark ? _C.darkBorder   : _C.lightBorder;
  Color get textPrimary   => isDark ? _C.darkText     : _C.lightText;
  Color get textSecondary => isDark ? _C.darkSubtext  : _C.lightSubtext;
  Color get muted     => isDark ? _C.darkMuted    : const Color(0xFFBBB5A8);
}

// ─── Home Screen ─────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user            = ref.watch(currentUserProvider);
    final trending        = ref.watch(_trendingProvider);
    final popularTv       = ref.watch(_popularTvProvider);
    final popularReviews  = ref.watch(_popularReviewsProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _CineAppBar(username: user?.username),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Featured Banner ──────────────────────────────────
                trending.when(
                  loading: () => _HeroSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (movies) => movies.isNotEmpty
                      ? _HeroBanner(movie: movies.first)
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                // ── Trending Movies ───────────────────────────────────────
                _SectionHeader(
                  label: 'Trending Now',
                  badge: 'MOVIES',
                  onSeeAll: () => context.push('/search'),
                ),
                const SizedBox(height: 14),
                trending.when(
                  loading: () => const _HorizontalSkeletons(),
                  error: (_, __) => const _ErrorTile(message: 'Could not load movies'),
                  data: (movies) => _MovieRail(movies: movies.skip(1).toList()),
                ),

                const SizedBox(height: 36),

                // ── Popular TV Shows ──────────────────────────────────────
                _SectionHeader(
                  label: 'Popular on TV',
                  badge: 'SERIES',
                  onSeeAll: () => context.push('/tv/popular'),
                ),
                const SizedBox(height: 14),
                popularTv.when(
                  loading: () => const _HorizontalSkeletons(),
                  error: (_, __) => const _ErrorTile(message: 'Could not load shows'),
                  data: (shows) => _MovieRail(movies: shows),
                ),

                const SizedBox(height: 36),

                // ── Popular Reviews ───────────────────────────────────────
                _SectionHeader(
                  label: 'Most Loved Reviews',
                  badge: 'COMMUNITY',
                  onSeeAll: () => context.push('/social'),
                ),
                const SizedBox(height: 14),
                popularReviews.when(
                  loading: () => const _VerticalSkeletons(),
                  error: (_, __) => const _ErrorTile(message: 'Could not load reviews'),
                  data: (reviews) => Column(
                    children: reviews
                        .take(4)
                        .map((r) => _ReviewCard(review: r))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _CineAppBar extends StatelessWidget {
  final String? username;
  const _CineAppBar({this.username});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return SliverAppBar(
      backgroundColor: context.bg,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      floating: true,
      snap: true,
      titleSpacing: 20,
      toolbarHeight: 64,
      title: Row(
        children: [
          // Logo mark
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE50914), Color(0xFF8B0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _C.red.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CineVerse',
                style: GoogleFonts.outfit(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
              if (username != null)
                Text(
                  '$greeting, $username',
                  style: GoogleFonts.inter(
                    color: context.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => context.push('/ai'),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 5),
                Text(
                  'AI',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: context.border.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final MovieModel movie;
  const _HeroBanner({required this.movie});

  @override
  Widget build(BuildContext context) {
    final posterUrl = AppConstants.posterUrl(movie.posterPath);

    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}?tv=${movie.isTvShow}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        height: 240,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: context.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDark ? 0.5 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop image
            if (posterUrl.isNotEmpty)
              Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _heroBgFallback(context),
              )
            else
              _heroBgFallback(context),

            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
            ),

            // Top-left badge
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '# 1  TODAY',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // Bottom info
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rating pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _C.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _C.gold.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: _C.gold, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating.toStringAsFixed(1),
                              style: GoogleFonts.outfit(
                                color: _C.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Watch button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'View Details',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _heroBgFallback(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDark
              ? [const Color(0xFF1A1D24), const Color(0xFF2A2E38)]
              : [const Color(0xFFE8E2D8), const Color(0xFFD4CEC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_rounded,
          size: 56,
          color: context.muted.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      height: 240,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final String badge;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.label,
    required this.badge,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Accent bar
          Container(
            width: 3,
            height: 18,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: _C.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  badge,
                  style: GoogleFonts.outfit(
                    color: _C.red,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: context.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: context.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all',
                    style: GoogleFonts.inter(
                      color: context.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.chevron_right_rounded, size: 14, color: context.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Movie Rail ───────────────────────────────────────────────────────────────

class _MovieRail extends StatelessWidget {
  final List<MovieModel> movies;
  const _MovieRail({required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (ctx, i) => _MovieCard(movie: movies[i], rank: i + 2),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;
  final int? rank;
  const _MovieCard({required this.movie, this.rank});

  @override
  Widget build(BuildContext context) {
    final posterUrl = AppConstants.posterUrl(movie.posterPath);

    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}?tv=${movie.isTvShow}'),
      child: Container(
        width: 126,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: posterUrl.isNotEmpty
                      ? Image.network(
                    posterUrl,
                    width: 126,
                    height: 172,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Placeholder(movie: movie),
                  )
                      : _Placeholder(movie: movie),
                ),
                // Rank badge (subtle, bottom-left corner)
                if (rank != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '#$rank',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: context.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),

            const SizedBox(height: 3),

            // Rating row
            Row(
              children: [
                const Icon(Icons.star_rounded, color: _C.gold, size: 12),
                const SizedBox(width: 3),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    color: context.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final MovieModel movie;
  const _Placeholder({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 172,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_rounded, size: 32, color: context.muted),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              movie.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: context.muted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton Loaders ─────────────────────────────────────────────────────────

class _HorizontalSkeletons extends StatelessWidget {
  const _HorizontalSkeletons();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          width: 126,
          height: 172,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _VerticalSkeletons extends StatelessWidget {
  const _VerticalSkeletons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
            (_) => Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          height: 108,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─── Error Tile ───────────────────────────────────────────────────────────────

class _ErrorTile extends StatelessWidget {
  final String message;
  const _ErrorTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.red.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: _C.red.withValues(alpha: 0.7), size: 18),
          const SizedBox(width: 10),
          Text(
            message,
            style: GoogleFonts.inter(
              color: _C.red.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Review Card ─────────────────────────────────────────────────────────────

class _ReviewCard extends ConsumerStatefulWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  bool? _liked;
  bool _likedInitially = false;

  @override
  void initState() {
    super.initState();
    final cachedLike = ref.read(reviewLikesProvider)[widget.review.id];
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
    final liked = await ref.read(reviewsRepositoryProvider).isReviewLiked(uid, widget.review.id);
    ref.read(reviewLikesProvider.notifier).setLiked(widget.review.id, liked);
    if (mounted) {
      setState(() {
        _liked = liked;
        _likedInitially = liked;
      });
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

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final ratingColor = _resolveRatingColor(review.rating);
    final initial = review.username.isNotEmpty
        ? review.username[0].toUpperCase()
        : '?';

    final isLiked = ref.watch(reviewLikesProvider)[review.id] ?? _liked ?? false;

    int displayLikesCount = review.likesCount;
    if (isLiked != _likedInitially) {
      displayLikesCount += isLiked ? 1 : -1;
    }
    if (displayLikesCount < 0) displayLikesCount = 0;

    final commentsAsync = ref.watch(reviewCommentsProvider(review.id));
    final displayCommentsCount = commentsAsync.value?.length ?? review.commentsCount;

    final posterUrl = AppConstants.posterUrl(review.mediaPoster);

    return GestureDetector(
      onTap: () => context.push('/review/detail', extra: review),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
          boxShadow: context.isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => context.push('/user/${review.userId}'),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _C.red.withValues(alpha: 0.7),
                          _C.redDim.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Name + media title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/user/${review.userId}'),
                        child: Text(
                          review.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Icon(
                            Icons.movie_creation_outlined,
                            size: 11,
                            color: context.muted,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              review.mediaTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: context.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Rating badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: ratingColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ratingColor.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: ratingColor, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                          color: ratingColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                thickness: 0.8,
                color: context.border,
              ),
            ),

            // Poster and text row
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
                    review.reviewText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: context.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 0.6,
              color: context.border,
            ),
            const SizedBox(height: 12),

            // Footer: likes + comments
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(isLiked),
                  child: _StatChip(
                    icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: isLiked ? const Color(0xFFE50914) : context.muted,
                    label: '$displayLikesCount',
                    context: context,
                    textColor: isLiked ? const Color(0xFFE50914) : null,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ReviewCommentsSheet(review: review),
                    );
                  },
                  child: _StatChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: context.muted,
                    label: '$displayCommentsCount',
                    context: context,
                  ),
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

  Color _resolveRatingColor(double rating) {
    if (rating >= 8) return _C.green;
    if (rating >= 6) return _C.amber;
    return _C.red;
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final BuildContext context;
  final Color? textColor;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.context,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textColor ?? context.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}