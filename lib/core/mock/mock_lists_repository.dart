import '../models/custom_list_model.dart';
import '../models/watchlist_model.dart';
import '../repositories/lists_repository.dart';

class MockListsRepository implements ListsRepository {
  final List<WatchlistModel> _watchlist = [
    WatchlistModel(userId: 'user_1', mediaId: '438631', mediaTitle: 'Dune', mediaPoster: '/d5NXSklpcvkCmCWfTMC5NVJIUiF.jpg', mediaType: 'movie', isWatched: false, createdAt: DateTime.now().subtract(const Duration(days: 2))),
    WatchlistModel(userId: 'user_1', mediaId: '76600', mediaTitle: 'Avatar: The Way of Water', mediaPoster: '/t6HIqrRAclMCA60NsSmeqe9nus9.jpg', mediaType: 'movie', isWatched: true, watchedAt: DateTime.now().subtract(const Duration(days: 5)), createdAt: DateTime.now().subtract(const Duration(days: 10))),
    WatchlistModel(userId: 'user_1', mediaId: 'tv_66732', mediaTitle: 'Stranger Things', mediaPoster: '/49WJfeN0moxb9IPfGn8AIqMGskD.jpg', mediaType: 'tv', isWatched: false, createdAt: DateTime.now().subtract(const Duration(days: 1))),
  ];

  final List<CustomListModel> _lists = [
    CustomListModel(
      id: 'list_1',
      userId: 'user_1',
      username: 'alex_cinephile',
      name: 'Top Nolan Films',
      description: 'My definitive ranking of every Christopher Nolan film.',
      isPublic: true,
      mediaItems: [
        CustomListItem(mediaId: '27205', mediaTitle: 'Inception', mediaPoster: '/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg', mediaType: 'movie'),
        CustomListItem(mediaId: '157336', mediaTitle: 'Interstellar', mediaPoster: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg', mediaType: 'movie'),
        CustomListItem(mediaId: '872585', mediaTitle: 'Oppenheimer', mediaPoster: '/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg', mediaType: 'movie'),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    CustomListModel(
      id: 'list_2',
      userId: 'user_2',
      username: 'sara_watches',
      name: 'Best Horror of the Decade',
      description: 'Horror films that genuinely scared me.',
      isPublic: true,
      mediaItems: [
        CustomListItem(mediaId: '496243', mediaTitle: 'Parasite', mediaPoster: '/7IiTTgloROVKhWhzoXebK9joJeU.jpg', mediaType: 'movie'),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    CustomListModel(
      id: 'list_3',
      userId: 'user_1',
      username: 'alex_cinephile',
      name: 'Secret Watchlist',
      description: 'Private queue.',
      isPublic: false,
      mediaItems: [
        CustomListItem(mediaId: '539681', mediaTitle: 'Thor: Love and Thunder', mediaPoster: '/pIkRyD18kl4FhoCNQuWxWu5cBLM.jpg', mediaType: 'movie'),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<WatchlistModel>> getWatchlist(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _watchlist.where((w) => w.userId == userId).toList();
  }

  @override
  Future<void> addToWatchlist(WatchlistModel item) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _watchlist.removeWhere((w) => w.userId == item.userId && w.mediaId == item.mediaId);
    _watchlist.add(item);
  }

  @override
  Future<void> removeFromWatchlist(String userId, String mediaId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _watchlist.removeWhere((w) => w.userId == userId && w.mediaId == mediaId);
  }

  @override
  Future<void> markAsWatched(String userId, String mediaId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _watchlist.indexWhere((w) => w.userId == userId && w.mediaId == mediaId);
    if (idx != -1) {
      _watchlist[idx] = _watchlist[idx].copyWith(isWatched: true, watchedAt: DateTime.now());
    }
  }

  @override
  Future<bool> isInWatchlist(String userId, String mediaId) async {
    return _watchlist.any((w) => w.userId == userId && w.mediaId == mediaId);
  }

  @override
  Future<List<CustomListModel>> getUserLists(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _lists.where((l) => l.userId == userId).toList();
  }

  @override
  Future<List<CustomListModel>> getPublicLists() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _lists.where((l) => l.isPublic).toList();
  }

  @override
  Future<CustomListModel> getListById(String listId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _lists.firstWhere((l) => l.id == listId);
  }

  @override
  Future<void> createList(CustomListModel list) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _lists.add(list);
  }

  @override
  Future<void> updateList(CustomListModel list) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _lists.indexWhere((l) => l.id == list.id);
    if (idx != -1) _lists[idx] = list;
  }

  @override
  Future<void> deleteList(String listId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _lists.removeWhere((l) => l.id == listId);
  }
}
