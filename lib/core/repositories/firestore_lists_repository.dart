import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/custom_list_model.dart';
import '../models/watchlist_model.dart';
import '../repositories/lists_repository.dart';

class FirestoreListsRepository implements ListsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Watchlist ───────────────────────────────────────────────────────────────

  @override
  Future<List<WatchlistModel>> getWatchlist(String userId) async {
    final snap = await _db
        .collection('watchlists')
        .where('userId', isEqualTo: userId)
        .get();
    final watchlist = snap.docs.map((d) => WatchlistModel.fromMap(d.data())).toList();
    watchlist.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return watchlist;
  }

  @override
  Future<void> addToWatchlist(WatchlistModel item) async {
    final docId = '${item.userId}_${item.mediaId}';
    await _db.collection('watchlists').doc(docId).set(item.toMap());
  }

  @override
  Future<void> removeFromWatchlist(String userId, String mediaId) async {
    final docId = '${userId}_$mediaId';
    await _db.collection('watchlists').doc(docId).delete();
  }

  @override
  Future<void> markAsWatched(String userId, String mediaId) async {
    final docId = '${userId}_$mediaId';
    await _db.collection('watchlists').doc(docId).update({
      'isWatched': true,
      'watchedAt': DateTime.now().toIso8601String(),
    });
    // Increment user's moviesWatchedCount
    await _db.collection('users').doc(userId).set({
      'moviesWatchedCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> isInWatchlist(String userId, String mediaId) async {
    final docId = '${userId}_$mediaId';
    final doc = await _db.collection('watchlists').doc(docId).get();
    return doc.exists;
  }

  // ─── Custom Lists ────────────────────────────────────────────────────────────

  @override
  Future<List<CustomListModel>> getUserLists(String userId) async {
    final snap = await _db
        .collection('lists')
        .where('userId', isEqualTo: userId)
        .get();
    final lists = snap.docs.map((d) => CustomListModel.fromMap(d.data())).toList();
    lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return lists;
  }

  @override
  Future<List<CustomListModel>> getPublicLists() async {
    final snap = await _db
        .collection('lists')
        .where('isPublic', isEqualTo: true)
        .limit(30)
        .get();
    final lists = snap.docs.map((d) => CustomListModel.fromMap(d.data())).toList();
    lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return lists;
  }

  @override
  Future<CustomListModel> getListById(String listId) async {
    final doc = await _db.collection('lists').doc(listId).get();
    if (!doc.exists) throw Exception('List not found: $listId');
    return CustomListModel.fromMap(doc.data()!);
  }

  @override
  Future<void> createList(CustomListModel list) async {
    await _db.collection('lists').doc(list.id).set(list.toMap());
  }

  @override
  Future<void> updateList(CustomListModel list) async {
    await _db.collection('lists').doc(list.id).update(list.toMap());
  }

  @override
  Future<void> deleteList(String listId) async {
    await _db.collection('lists').doc(listId).delete();
  }
}
