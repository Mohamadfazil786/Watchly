import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/watchlist_model.dart';
import '../../core/constants/app_constants.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> with SingleTickerProviderStateMixin {
  late TabController _filterTabController;

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final watchlistAsync = ref.watch(userWatchlistProvider(uid));
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final iconColor = context.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('My Watchlist', style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _filterTabController,
            labelColor: const Color(0xFFE50914),
            unselectedLabelColor: subColor,
            indicatorColor: const Color(0xFFE50914),
            indicatorWeight: 2,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'To Watch'),
              Tab(text: 'Watched'),
            ],
          ),
          Expanded(
            child: watchlistAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
              error: (err, stack) => Center(
                child: Text(
                  'Failed to load watchlist: $err',
                  style: GoogleFonts.inter(color: subColor),
                ),
              ),
              data: (items) {
                return TabBarView(
                  controller: _filterTabController,
                  children: [
                    _buildWatchlistList(items),
                    _buildWatchlistList(items.where((i) => !i.isWatched).toList()),
                    _buildWatchlistList(items.where((i) => i.isWatched).toList()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final uid = ref.read(currentUserProvider)?.uid ?? '';
          if (uid.isNotEmpty) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _AddMovieSearchSheet(uid: uid),
            );
          }
        },
        backgroundColor: const Color(0xFFE50914),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Media', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildWatchlistList(List<WatchlistModel> items) {
    final subColor = context.textSecondary;
    final timeColor = context.muted;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, color: context.muted, size: 64),
            const SizedBox(height: 16),
            Text('No movies here', style: GoogleFonts.outfit(color: context.textSecondary, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Add movies or TV shows to get started', style: GoogleFonts.inter(color: timeColor, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final posterUrl = AppConstants.posterUrl(item.mediaPoster);
        final cardBg = context.surface;
        final borderCol = context.border;
        final textColor = context.textPrimary;
        final placeholderBg = context.surface2;
        final iconColor = context.muted;

        return Dismissible(
          key: Key('watchlist_${item.mediaId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
          ),
          confirmDismiss: (direction) async {
            final uid = ref.read(currentUserProvider)?.uid ?? 'user_1';
            await ref.read(listsRepositoryProvider).removeFromWatchlist(uid, item.mediaId);
            ref.invalidate(userWatchlistProvider(uid));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.mediaTitle} removed from watchlist'),
                  backgroundColor: context.surface,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            return true;
          },
          child: GestureDetector(
            onTap: () => context.push('/movie/${item.mediaId}?tv=${item.mediaType == 'tv'}'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: posterUrl.isNotEmpty
                        ? Image.network(
                            posterUrl,
                            width: 55,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 55,
                              height: 80,
                              color: placeholderBg,
                              child: Icon(Icons.movie_outlined, color: iconColor),
                            ),
                          )
                        : Container(
                            width: 55,
                            height: 80,
                            color: placeholderBg,
                            child: Icon(Icons.movie_outlined, color: iconColor),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.mediaTitle,
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (item.isWatched
                                        ? const Color(0xFF00C853)
                                        : const Color(0xFFFF9233))
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.isWatched ? '✓ Watched' : '⏳ To Watch',
                                style: GoogleFonts.inter(
                                  color: item.isWatched
                                      ? const Color(0xFF00C853)
                                      : const Color(0xFFFF9233),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.mediaType.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: subColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (!item.isWatched)
                        IconButton(
                          onPressed: () async {
                            final uid = ref.read(currentUserProvider)?.uid ?? 'user_1';
                            await ref.read(listsRepositoryProvider).markAsWatched(uid, item.mediaId);
                            ref.invalidate(userWatchlistProvider(uid));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Marked ${item.mediaTitle} as Watched'),
                                  backgroundColor: const Color(0xFF00C853).withValues(alpha: 0.8),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00C853)),
                          tooltip: 'Mark as Watched',
                        ),
                      IconButton(
                        onPressed: () async {
                          final uid = ref.read(currentUserProvider)?.uid ?? 'user_1';
                          await ref.read(listsRepositoryProvider).removeFromWatchlist(uid, item.mediaId);
                          ref.invalidate(userWatchlistProvider(uid));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.mediaTitle} removed from watchlist'),
                                backgroundColor: context.surface,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.delete_outline_rounded, color: subColor),
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Add Movie Search Bottom Sheet ──────────────────────────────────────────

class _AddMovieSearchSheet extends ConsumerStatefulWidget {
  final String uid;
  const _AddMovieSearchSheet({required this.uid});

  @override
  ConsumerState<_AddMovieSearchSheet> createState() => _AddMovieSearchSheetState();
}

class _AddMovieSearchSheetState extends ConsumerState<_AddMovieSearchSheet> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;
  List<Map<String, String>> _searchResults = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final movies = await ref.read(moviesRepositoryProvider).searchMovies(query);
      if (mounted) {
        setState(() {
          _searchResults = movies.take(6).map((m) => {
            'id': m.id,
            'title': m.title,
            'poster': m.posterPath,
            'type': m.isTvShow ? 'tv' : 'movie',
          }).toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _addToWatchlist(Map<String, String> movie) async {
    final item = WatchlistModel(
      userId: widget.uid,
      mediaId: movie['id']!,
      mediaTitle: movie['title']!,
      mediaPoster: movie['poster']!,
      mediaType: movie['type'] ?? 'movie',
      createdAt: DateTime.now(),
    );
    try {
      await ref.read(listsRepositoryProvider).addToWatchlist(item);
      ref.invalidate(userWatchlistProvider(widget.uid));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${movie['title']} added to watchlist'),
            backgroundColor: const Color(0xFF00C853),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Add to Watchlist',
                style: GoogleFonts.outfit(
                  color: context.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search movie or TV show...',
              hintStyle: TextStyle(color: context.textSecondary),
              filled: true,
              fillColor: context.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.search, color: context.textSecondary),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914)),
                      ),
                    )
                  : null,
            ),
            onChanged: _searchMovies,
          ),
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (ctx, i) {
                  final m = _searchResults[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: m['poster']!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              AppConstants.posterUrl(m['poster']!),
                              width: 36,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 36),
                            ),
                          )
                        : const Icon(Icons.movie, size: 36),
                    title: Text(
                      m['title']!,
                      style: GoogleFonts.inter(
                        color: context.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      m['type']!.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: context.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    trailing: const Icon(Icons.add_circle_outline, color: Color(0xFFE50914)),
                    onTap: () => _addToWatchlist(m),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}



