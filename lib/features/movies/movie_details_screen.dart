import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/movie_model.dart';
import '../../core/models/review_model.dart';
import '../../core/models/watchlist_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/image_helper.dart';

final _movieDetailProvider = FutureProvider.autoDispose.family<MovieModel, ({String id, bool isTv})>((ref, args) {
  return args.isTv
      ? ref.read(moviesRepositoryProvider).getTvShowDetails(args.id)
      : ref.read(moviesRepositoryProvider).getMovieDetails(args.id);
});

final _mediaReviewsProvider = FutureProvider.autoDispose.family<List<ReviewModel>, String>((ref, mediaId) {
  return ref.read(reviewsRepositoryProvider).getMediaReviews(mediaId);
});

final _ratingDistProvider = FutureProvider.autoDispose.family<Map<int, int>, String>((ref, mediaId) {
  return ref.read(reviewsRepositoryProvider).getRatingDistribution(mediaId);
});

final _avgRatingProvider = FutureProvider.autoDispose.family<double, String>((ref, mediaId) {
  return ref.read(reviewsRepositoryProvider).getAverageCommunityRating(mediaId);
});

class MovieDetailsScreen extends ConsumerWidget {
  final String mediaId;
  final bool isTv;

  const MovieDetailsScreen({super.key, required this.mediaId, this.isTv = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(_movieDetailProvider((id: mediaId, isTv: isTv)));
    final bg = context.bg;
    final subColor = context.textSecondary;

    return movieAsync.when(
      loading: () => Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: bg,
        body: Center(child: Text('Error loading details', style: GoogleFonts.inter(color: subColor))),
      ),
      data: (movie) => _MovieDetailsBody(movie: movie, isTv: isTv),
    );
  }
}

class _MovieDetailsBody extends ConsumerStatefulWidget {
  final MovieModel movie;
  final bool isTv;

  const _MovieDetailsBody({required this.movie, required this.isTv});

  @override
  ConsumerState<_MovieDetailsBody> createState() => _MovieDetailsBodyState();
}

class _MovieDetailsBodyState extends ConsumerState<_MovieDetailsBody> {
  bool _inWatchlist = false;

  @override
  void initState() {
    super.initState();
    _checkWatchlist();
  }

  Future<void> _checkWatchlist() async {
    final userId = ref.read(currentUserProvider)?.uid ?? '';
    final inList = await ref.read(listsRepositoryProvider).isInWatchlist(userId, widget.movie.id);
    if (mounted) setState(() => _inWatchlist = inList);
  }

  Future<void> _toggleWatchlist() async {
    final userId = ref.read(currentUserProvider)?.uid ?? '';
    if (_inWatchlist) {
      await ref.read(listsRepositoryProvider).removeFromWatchlist(userId, widget.movie.id);
    } else {
      await ref.read(listsRepositoryProvider).addToWatchlist(WatchlistModel(
        userId: userId,
        mediaId: widget.movie.id,
        mediaTitle: widget.movie.title,
        mediaPoster: widget.movie.posterPath,
        mediaType: widget.isTv ? 'tv' : 'movie',
        createdAt: DateTime.now(),
      ));
    }
    if (mounted) setState(() => _inWatchlist = !_inWatchlist);
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final backdropUrl = AppConstants.backdropUrl(movie.backdropPath);
    final posterUrl = AppConstants.posterUrl(movie.posterPath, size: 'w500');
    final reviews = ref.watch(_mediaReviewsProvider(movie.id));
    final ratingDist = ref.watch(_ratingDistProvider(movie.id));
    final avgRating = ref.watch(_avgRatingProvider(movie.id));

    final bg = context.bg;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final textLabelColor = context.textSecondary;
    final timeColor = context.muted;
    final cardBg = context.surface;
    final borderCol = context.border;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // Backdrop App Bar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: bg,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _toggleWatchlist,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    _inWatchlist ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _inWatchlist ? const Color(0xFFE50914) : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  backdropUrl.isNotEmpty
                      ? Image.network(backdropUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _backdropPlaceholder(context))
                      : _backdropPlaceholder(context),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, bg],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Poster row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: posterUrl.isNotEmpty
                            ? Image.network(posterUrl, width: 100, height: 150, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _miniPosterPlaceholder(context, movie.title))
                            : _miniPosterPlaceholder(context, movie.title),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie.title, style: GoogleFonts.outfit(color: textColor, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                            const SizedBox(height: 8),
                            if (movie.releaseDate.isNotEmpty) Text(movie.releaseDate.split('-').first, style: GoogleFonts.inter(color: subColor, fontSize: 13)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: movie.genres.take(3).map((g) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: borderCol),
                                ),
                                child: Text(g, style: GoogleFonts.inter(color: textLabelColor, fontSize: 11)),
                              )).toList(),
                            ),
                            const SizedBox(height: 10),
                            if (movie.runtime > 0)
                              Row(children: [
                                Icon(Icons.access_time, color: subColor, size: 14),
                                const SizedBox(width: 4),
                                Text('${movie.runtime} min', style: GoogleFonts.inter(color: subColor, fontSize: 12)),
                              ]),
                            const SizedBox(height: 12),
                            // TMDB Rating
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  movie.rating.toStringAsFixed(1),
                                  style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text('/10', style: GoogleFonts.inter(color: subColor, fontSize: 12)),
                                const SizedBox(width: 8),
                                Text('(${movie.ratingCount} votes)', style: GoogleFonts.inter(color: timeColor, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.rate_review_rounded,
                          label: 'Write Review',
                          onTap: () => context.push('/review/write', extra: {
                            'mediaId': movie.id,
                            'mediaTitle': movie.title,
                            'mediaPoster': movie.posterPath,
                            'mediaType': widget.isTv ? 'tv' : 'movie',
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (movie.trailerUrl.isNotEmpty)
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.play_circle_outline_rounded,
                            label: 'Watch Trailer',
                            isSecondary: true,
                            onTap: () => _launchTrailer(movie.trailerUrl),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Overview
                  Text('Overview', style: GoogleFonts.outfit(color: textColor, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(movie.overview, style: GoogleFonts.inter(color: textLabelColor, fontSize: 14, height: 1.7)),
                  const SizedBox(height: 24),
                  // Director
                  if (movie.director.isNotEmpty) ...[
                    Text('Director', style: GoogleFonts.outfit(color: textColor, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.movie_creation_outlined, color: Color(0xFFE50914), size: 18),
                      const SizedBox(width: 8),
                      Text(movie.director, style: GoogleFonts.inter(color: textLabelColor, fontSize: 14)),
                    ]),
                    const SizedBox(height: 24),
                  ],
                  // Cast
                  if (movie.cast.isNotEmpty) ...[
                    Text('Cast', style: GoogleFonts.outfit(color: textColor, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movie.cast.length,
                        itemBuilder: (_, i) => _CastCard(cast: movie.cast[i]),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Community Ratings
                  Text('Community Rating', style: GoogleFonts.outfit(color: textColor, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  avgRating.when(
                    loading: () => const SizedBox(height: 20, child: LinearProgressIndicator()),
                    error: (_, __) => const SizedBox(),
                    data: (avg) => Row(
                      children: [
                        Text(avg.toStringAsFixed(1), style: GoogleFonts.outfit(color: const Color(0xFFE50914), fontSize: 36, fontWeight: FontWeight.w800)),
                        Text('/10', style: TextStyle(color: subColor, fontSize: 16)),
                        const SizedBox(width: 12),
                        const Icon(Icons.star_rounded, color: Color(0xFFE50914), size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ratingDist.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (dist) => _RatingDistributionChart(distribution: dist),
                  ),
                  const SizedBox(height: 24),
                  // Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews', style: GoogleFonts.outfit(color: textColor, fontSize: 17, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => context.push('/review/write', extra: {
                          'mediaId': movie.id, 'mediaTitle': movie.title, 'mediaPoster': movie.posterPath, 'mediaType': widget.isTv ? 'tv' : 'movie',
                        }),
                        child: Text('Write Review', style: GoogleFonts.inter(color: const Color(0xFFE50914), fontSize: 13)),
                      ),
                    ],
                  ),
                  reviews.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFFE50914)))),
                    error: (_, __) => const SizedBox(),
                    data: (reviewList) => reviewList.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(child: Text('No reviews yet. Be the first!', style: GoogleFonts.inter(color: subColor))),
                          )
                        : Column(
                            children: reviewList.map((r) => _ReviewTile(review: r)).toList(),
                          ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backdropPlaceholder(BuildContext context) {
    return Container(color: context.surface2);
  }

  Widget _miniPosterPlaceholder(BuildContext context, String title) {
    final placeholderBg = context.surface2;
    final iconColor = context.muted;

    return Container(
      width: 100, height: 150,
      color: placeholderBg,
      child: Center(child: Text(title.isNotEmpty ? title[0] : '?', style: TextStyle(color: iconColor, fontSize: 32, fontWeight: FontWeight.bold))),
    );
  }

  Future<void> _launchTrailer(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    try {
      // Directly call launchUrl without canLaunchUrl().
      // canLaunchUrl() for https:// returns false in release builds on Android 11+
      // unless the <queries> block is present in the manifest. Using launchUrl
      // directly is the url_launcher-recommended pattern for web URLs.
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open trailer. Please try again.')),
        );
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSecondary;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.isSecondary = false});

  @override
  Widget build(BuildContext context) {
    final btnBg = context.surface;
    final borderCol = context.border;
    final textColor = context.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSecondary ? null : const LinearGradient(colors: [Color(0xFFE50914), Color(0xFFFF9233)]),
          color: isSecondary ? btnBg : null,
          borderRadius: BorderRadius.circular(12),
          border: isSecondary ? Border.all(color: borderCol) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSecondary ? textColor : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(color: isSecondary ? textColor : Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _CastCard extends StatelessWidget {
  final CastMember cast;
  const _CastCard({required this.cast});

  @override
  Widget build(BuildContext context) {
    final placeholderBg = context.surface2;
    final textLabelColor = context.textPrimary;
    final placeholderTextColor = context.textSecondary;

    final profileUrl = AppConstants.profileUrl(cast.profilePath);
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: placeholderBg,
            backgroundImage: profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
            child: profileUrl.isEmpty ? Text(cast.name[0], style: TextStyle(color: placeholderTextColor, fontWeight: FontWeight.bold)) : null,
          ),
          const SizedBox(height: 4),
          Text(cast.name.split(' ').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: textLabelColor, fontSize: 10)),
        ],
      ),
    );
  }
}

class _RatingDistributionChart extends StatelessWidget {
  final Map<int, int> distribution;
  const _RatingDistributionChart({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final subColor = context.textSecondary;
    final timeColor = context.muted;
    final progressBg = context.surface2;

    final maxVal = distribution.values.fold(0, (a, b) => a > b ? a : b);
    return Column(
      children: List.generate(10, (i) {
        final rating = 10 - i;
        final count = distribution[rating] ?? 0;
        final fraction = maxVal > 0 ? count / maxVal : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(width: 20, child: Text('$rating', style: GoogleFonts.inter(color: subColor, fontSize: 11))),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(height: 12, decoration: BoxDecoration(color: progressBg, borderRadius: BorderRadius.circular(6))),
                    FractionallySizedBox(
                      widthFactor: fraction,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00E676)]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 20, child: Text('$count', style: GoogleFonts.inter(color: timeColor, fontSize: 10))),
            ],
          ),
        );
      }),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final cardBg = context.surface;
    final borderCol = context.border;
    final textColor = context.textPrimary;
    final textBodyColor = context.textPrimary.withValues(alpha: 0.7);
    final timeColor = context.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE50914).withValues(alpha: 0.2),
                backgroundImage: review.userPhotoUrl.isNotEmpty ? ImageHelper.getAvatarImage(review.userPhotoUrl) : null,
                child: review.userPhotoUrl.isEmpty
                    ? Text(
                        review.username.isNotEmpty ? review.username[0].toUpperCase() : '?',
                        style: GoogleFonts.outfit(color: const Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 12),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(review.username, style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF00C853).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text('${review.rating} ★', style: GoogleFonts.outfit(color: const Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.reviewText, maxLines: 4, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: textBodyColor, fontSize: 13, height: 1.5)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.favorite_outline, size: 13, color: timeColor),
            const SizedBox(width: 4),
            Text('${review.likesCount}', style: GoogleFonts.inter(color: timeColor, fontSize: 11)),
            const SizedBox(width: 12),
            Icon(Icons.chat_bubble_outline, size: 13, color: timeColor),
            const SizedBox(width: 4),
            Text('${review.commentsCount}', style: GoogleFonts.inter(color: timeColor, fontSize: 11)),
          ]),
        ],
      ),
    );
  }
}



