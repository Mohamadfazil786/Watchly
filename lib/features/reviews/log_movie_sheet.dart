import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/movie_model.dart';
import '../../core/models/review_model.dart';
import '../../core/constants/app_constants.dart';

class LogMovieSheet extends ConsumerStatefulWidget {
  const LogMovieSheet({super.key});

  @override
  ConsumerState<LogMovieSheet> createState() => _LogMovieSheetState();
}

class _LogMovieSheetState extends ConsumerState<LogMovieSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _reviewCtrl = TextEditingController();
  
  bool _isSearching = false;
  bool _isSaving = false;
  bool _isGeneratingAi = false;
  
  List<MovieModel> _searchResults = [];
  MovieModel? _selectedMovie;
  double _rating = 7.0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await ref.read(moviesRepositoryProvider).searchMovies(query);
      setState(() => _searchResults = results);
    } catch (_) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _generateAiReview() async {
    if (_selectedMovie == null) return;
    setState(() => _isGeneratingAi = true);
    try {
      final draft = await ref.read(aiRepositoryProvider).generateReviewDraft(
        _selectedMovie!.title,
        _rating,
      );
      setState(() => _reviewCtrl.text = draft);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingAi = false);
    }
  }

  Future<void> _saveReview() async {
    if (_selectedMovie == null) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final newReview = ReviewModel(
        id: 'review_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        username: user.username,
        userPhotoUrl: user.photoUrl,
        mediaId: _selectedMovie!.id,
        mediaTitle: _selectedMovie!.title,
        mediaPoster: _selectedMovie!.posterPath,
        mediaType: _selectedMovie!.isTvShow ? 'tv' : 'movie',
        rating: _rating,
        reviewText: _reviewCtrl.text.trim(),
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(reviewsRepositoryProvider).writeReview(newReview);
      
      // Invalidate providers to refresh lists across screens
      ref.invalidate(reviewsRepositoryProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating logged successfully!'), backgroundColor: Color(0xFF00C853)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                if (_selectedMovie != null)
                  IconButton(
                    onPressed: () => setState(() => _selectedMovie = null),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                Text(
                  _selectedMovie == null ? 'Log a Movie' : 'Rate & Review',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
              child: _selectedMovie == null
                  ? _buildMovieSearchSection(isDark)
                  : _buildLogFormSection(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieSearchSection(bool isDark) {
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search movie or show to rate...',
            hintStyle: TextStyle(color: context.muted),
            filled: true,
            fillColor: context.surface2,
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914))),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (val) => _searchMovies(val),
        ),
        const SizedBox(height: 16),
        if (_searchResults.isEmpty && _searchCtrl.text.isNotEmpty && !_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'No matches found',
              style: GoogleFonts.inter(color: context.textSecondary),
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
          itemBuilder: (context, i) {
            final movie = _searchResults[i];
            final poster = AppConstants.posterUrl(movie.posterPath);
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: poster.isNotEmpty
                    ? Image.network(poster, width: 42, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallbackPoster())
                    : _fallbackPoster(),
              ),
              title: Text(
                movie.title,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimary),
              ),
              subtitle: Text(
                movie.releaseDate.length >= 4 ? movie.releaseDate.substring(0, 4) : movie.releaseDate,
                style: GoogleFonts.inter(fontSize: 12, color: context.textSecondary),
              ),
              onTap: () {
                setState(() {
                  _selectedMovie = movie;
                  _reviewCtrl.clear();
                  _rating = 7.0;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogFormSection(bool isDark) {
    final movie = _selectedMovie!;
    final poster = AppConstants.posterUrl(movie.posterPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Movie Card Info
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: poster.isNotEmpty
                  ? Image.network(poster, width: 70, height: 105, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallbackPoster())
                  : _fallbackPoster(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: context.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.releaseDate.length >= 4 ? movie.releaseDate.substring(0, 4) : movie.releaseDate,
                    style: GoogleFonts.inter(color: context.textSecondary, fontSize: 13),
                  ),
                  if (movie.overview.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      movie.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: context.textSecondary, fontSize: 11, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Rating Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Rating',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: context.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_rating.toStringAsFixed(1)} ★',
                style: GoogleFonts.outfit(color: const Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider.adaptive(
          value: _rating,
          min: 1.0,
          max: 10.0,
          divisions: 18, // 0.5 increments from 1 to 10
          activeColor: const Color(0xFFE50914),
          inactiveColor: context.border,
          onChanged: (val) => setState(() => _rating = val),
        ),
        const SizedBox(height: 20),
        
        // Review Section (Optional)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Write a Review',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: context.textPrimary),
                ),
                const SizedBox(width: 6),
                Text(
                  '(Optional)',
                  style: GoogleFonts.inter(color: context.muted, fontSize: 12),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _isGeneratingAi ? null : _generateAiReview,
              icon: _isGeneratingAi
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C63FF)))
                  : const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF6C63FF)),
              label: Text(
                'AI Draft',
                style: GoogleFonts.inter(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reviewCtrl,
          maxLines: 4,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: 'Share your thoughts on this movie...',
            hintStyle: TextStyle(color: context.muted),
            filled: true,
            fillColor: context.surface2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 28),
        
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                : Text(
                    'Log Rating & Review',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackPoster() {
    return Container(
      width: 42,
      height: 60,
      color: const Color(0xFF222129),
      child: const Icon(Icons.movie, color: Colors.white24, size: 20),
    );
  }
}

