import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/custom_list_model.dart';
import '../../core/models/watchlist_model.dart';
import '../../core/constants/app_constants.dart';



class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final lists = ref.watch(userListsProvider(uid));
    final watchlist = ref.watch(userWatchlistProvider(uid));
    final bg = context.bg;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final headerBtnBg = context.surface;
    final headerBtnBorder = context.border;

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/list/create'),
        backgroundColor: const Color(0xFFE50914),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New List', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Lists', style: GoogleFonts.outfit(color: textColor, fontSize: 28, fontWeight: FontWeight.w800)),
                  IconButton(
                    onPressed: () => context.push('/watchlist'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: headerBtnBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: headerBtnBorder),
                      ),
                      child: const Icon(Icons.bookmark_rounded, color: Color(0xFFE50914), size: 20),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFE50914),
              unselectedLabelColor: subColor,
              indicatorColor: const Color(0xFFE50914),
              indicatorWeight: 2,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [Tab(text: 'My Lists'), Tab(text: 'Watchlist')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Custom Lists
                  lists.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                    error: (_, __) => Center(child: Text('Failed to load lists', style: TextStyle(color: subColor))),
                    data: (userLists) => userLists.isEmpty
                        ? _EmptyListsState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: userLists.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (ctx, i) => _ListCard(list: userLists[i]),
                          ),
                  ),
                  // Watchlist
                  watchlist.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                    error: (_, __) => Center(child: Text('Failed to load watchlist', style: TextStyle(color: subColor))),
                    data: (items) => items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_border_rounded, color: context.muted, size: 64),
                                const SizedBox(height: 16),
                                Text('Your watchlist is empty', style: GoogleFonts.inter(color: subColor, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Add movies to watch later', style: GoogleFonts.inter(color: context.muted, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) => _WatchlistTile(item: items[i]),
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

class _EmptyListsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final subColor = context.textSecondary;
    final timeColor = context.muted;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_add_rounded, color: context.muted, size: 64),
          const SizedBox(height: 16),
          Text('No lists yet', style: GoogleFonts.outfit(color: subColor, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Create your first list with the button below', style: GoogleFonts.inter(color: timeColor, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ListCard extends ConsumerWidget {
  final CustomListModel list;
  const _ListCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardBg = context.surface;
    final borderCol = context.border;
    final textColor = context.textPrimary;
    final subColor = context.textSecondary;
    final timeColor = context.muted;
    final placeholderBg = context.surface2;

    return GestureDetector(
      onTap: () => context.push('/list/${list.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            // Mini poster strip
            if (list.mediaItems.isNotEmpty)
              SizedBox(
                width: 80,
                height: 60,
                child: Stack(
                  children: list.mediaItems.take(3).toList().asMap().entries.map((entry) {
                    final item = entry.value;
                    final idx = entry.key;
                    final posterUrl = AppConstants.posterUrl(item.mediaPoster);
                    return Positioned(
                      left: idx * 18.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: posterUrl.isNotEmpty
                            ? Image.network(
                                posterUrl,
                                width: 40,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 40, height: 60, color: placeholderBg),
                              )
                            : Container(width: 40, height: 60, color: placeholderBg),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          list.name,
                          style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!list.isPublic) Icon(Icons.lock_outline, color: timeColor, size: 14),
                    ],
                  ),
                  if (list.description.isNotEmpty)
                    Text(list.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: subColor, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${list.mediaItems.length} ${list.mediaItems.length == 1 ? 'film' : 'films'}', style: GoogleFonts.inter(color: timeColor, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: timeColor),
          ],
        ),
      ),
    );
  }
}

class _WatchlistTile extends ConsumerWidget {
  final WatchlistModel item;
  const _WatchlistTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardBg = context.surface;
    final borderCol = context.border;
    final textColor = context.textPrimary;
    final placeholderBg = context.surface2;

    final posterUrl = AppConstants.posterUrl(item.mediaPoster);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterUrl.isNotEmpty
                ? Image.network(
                    posterUrl,
                    width: 48,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 48, height: 72, color: placeholderBg),
                  )
                : Container(width: 48, height: 72, color: placeholderBg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.mediaTitle, style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (item.isWatched ? const Color(0xFF00C853) : const Color(0xFFFF9233)).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item.isWatched ? '✓ Watched' : '⏳ To Watch',
                    style: GoogleFonts.inter(
                      color: item.isWatched ? const Color(0xFF00C853) : const Color(0xFFFF9233),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!item.isWatched)
            IconButton(
              onPressed: () async {
                final uid = ref.read(currentUserProvider)?.uid ?? '';
                await ref.read(listsRepositoryProvider).markAsWatched(uid, item.mediaId);
                // Invalidate both watchlist and user lists providers to refresh views
                ref.invalidate(userWatchlistProvider(uid));
              },
              icon: const Icon(Icons.check_circle_outline, color: Color(0xFF00C853)),
            ),
        ],
      ),
    );
  }
}



