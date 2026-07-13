import '../models/custom_list_model.dart';
import '../models/watchlist_model.dart';

abstract class ListsRepository {
  // Watchlist
  Future<List<WatchlistModel>> getWatchlist(String userId);
  Future<void> addToWatchlist(WatchlistModel item);
  Future<void> removeFromWatchlist(String userId, String mediaId);
  Future<void> markAsWatched(String userId, String mediaId);
  Future<bool> isInWatchlist(String userId, String mediaId);

  // Custom Lists
  Future<List<CustomListModel>> getUserLists(String userId);
  Future<List<CustomListModel>> getPublicLists();
  Future<CustomListModel> getListById(String listId);
  Future<void> createList(CustomListModel list);
  Future<void> updateList(CustomListModel list);
  Future<void> deleteList(String listId);
}
