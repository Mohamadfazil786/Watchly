import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/movie_model.dart';
import '../../core/constants/app_constants.dart';

final popularTvShowsProvider = FutureProvider.autoDispose<List<MovieModel>>((ref) {
  return ref.read(moviesRepositoryProvider).getPopularTvShows();
});

class PopularTvShowsScreen extends ConsumerWidget {
  const PopularTvShowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tvShowsAsync = ref.watch(popularTvShowsProvider);
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final borderCol = context.border;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: subColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Popular TV Shows',
          style: GoogleFonts.outfit(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: borderCol,
          ),
        ),
      ),
      body: SafeArea(
        child: tvShowsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE50914)),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, color: subColor, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load TV shows',
                    style: GoogleFonts.outfit(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    err.toString(),
                    style: GoogleFonts.inter(color: subColor, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          data: (shows) {
            if (shows.isEmpty) {
              return Center(
                child: Text(
                  'No TV shows found',
                  style: GoogleFonts.inter(color: subColor),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: shows.length,
              itemBuilder: (ctx, i) {
                final show = shows[i];
                final posterUrl = AppConstants.posterUrl(show.posterPath);

                return GestureDetector(
                  onTap: () => context.push('/movie/${show.id}?tv=true'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: context.isDark ? 0.4 : 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: posterUrl.isNotEmpty
                                ? Image.network(
                                    posterUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _placeholder(context, show),
                                  )
                                : _placeholder(context, show),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        show.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 12),
                          const SizedBox(width: 3),
                          Text(
                            show.rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              color: subColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, MovieModel show) {
    return Container(
      color: context.surface2,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            show.title.isNotEmpty ? show.title : '?',
            maxLines: 3,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.muted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
