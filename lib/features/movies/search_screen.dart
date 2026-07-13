import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/movie_model.dart';
import '../../core/constants/app_constants.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _searchTypeProvider = StateProvider<String>((ref) => 'movie'); // 'movie' or 'tv'

final _searchResultsProvider = FutureProvider.autoDispose<List<MovieModel>>((ref) async {
  final query = ref.watch(_searchQueryProvider);
  final type = ref.watch(_searchTypeProvider);
  if (query.isEmpty) {
    return type == 'movie'
        ? ref.read(moviesRepositoryProvider).getTrendingMovies()
        : ref.read(moviesRepositoryProvider).getPopularTvShows();
  }
  return type == 'movie'
      ? ref.read(moviesRepositoryProvider).searchMovies(query)
      : ref.read(moviesRepositoryProvider).searchTvShows(query);
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchType = ref.watch(_searchTypeProvider);
    final results = ref.watch(_searchResultsProvider);
    final query = ref.watch(_searchQueryProvider);
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final cardBg = context.surface;
    final borderCol = context.border;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover',
                    style: GoogleFonts.outfit(color: textColor, fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor),
                      onChanged: (v) => ref.read(_searchQueryProvider.notifier).state = v,
                      decoration: InputDecoration(
                        hintText: 'Search movies & shows...',
                        hintStyle: GoogleFonts.inter(color: subColor, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        prefixIcon: Icon(Icons.search_rounded, color: subColor),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: subColor),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(_searchQueryProvider.notifier).state = '';
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _TypeChip(label: '🎬 Movies', value: 'movie', current: searchType),
                      const SizedBox(width: 10),
                      _TypeChip(label: '📺 TV Shows', value: 'tv', current: searchType),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                query.isEmpty ? (searchType == 'movie' ? 'Trending Movies' : 'Popular TV Shows') : 'Results for "$query"',
                style: GoogleFonts.inter(color: subColor, fontSize: 13),
              ),
            ),
            Expanded(
              child: results.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                error: (e, _) => Center(child: Text('Something went wrong', style: GoogleFonts.inter(color: subColor))),
                data: (movies) => movies.isEmpty
                    ? _EmptyState(query: query)
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: movies.length,
                        itemBuilder: (ctx, i) => _SearchMovieCard(movie: movies[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends ConsumerWidget {
  final String label;
  final String value;
  final String current;
  const _TypeChip({required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == current;
    final chipBg = context.surface;
    final chipBorder = context.border;

    return GestureDetector(
      onTap: () => ref.read(_searchTypeProvider.notifier).state = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE50914) : chipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFFE50914) : chipBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : context.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SearchMovieCard extends StatelessWidget {
  final MovieModel movie;
  const _SearchMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final posterUrl = AppConstants.posterUrl(movie.posterPath);
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}?tv=${movie.isTvShow}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: posterUrl.isNotEmpty
                  ? Image.network(
                      posterUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(color: textColor, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 11),
              const SizedBox(width: 2),
              Text(movie.rating.toStringAsFixed(1), style: GoogleFonts.inter(color: subColor, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: context.surface2,
      child: Center(
        child: Text(
          movie.title.isNotEmpty ? movie.title[0] : '?',
          style: TextStyle(color: context.muted, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, color: context.muted, size: 64),
          const SizedBox(height: 16),
          Text('No results for "$query"', style: GoogleFonts.outfit(color: context.textPrimary, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Try a different search term', style: GoogleFonts.inter(color: context.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
