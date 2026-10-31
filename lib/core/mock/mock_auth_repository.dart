import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;
  final _streamController = _AuthStreamController();

  static final List<UserModel> _users = [
    UserModel(
      uid: 'user_1',
      email: 'alex@watchly.app',
      username: 'alex_cinephile',
      bio: 'Movies are my religion. Cinema is my church.',
      photoUrl: '',
      favoriteGenres: ['Sci-Fi', 'Thriller', 'Drama'],
      followersCount: 248,
      followingCount: 112,
      reviewsCount: 87,
      moviesWatchedCount: 342,
      topMovies: ['inception', 'interstellar', 'dune', '2001', 'blade_runner'],
      favoriteTvShows: ['breaking_bad', 'dark', 'mindhunter'],
      createdAt: DateTime(2024, 1, 15),
    ),
    UserModel(
      uid: 'user_2',
      email: 'sara@watchly.app',
      username: 'sara_watches',
      bio: 'Horror & comedy lover. Always looking for hidden gems.',
      photoUrl: '',
      favoriteGenres: ['Horror', 'Comedy', 'Romance'],
      followersCount: 510,
      followingCount: 89,
      reviewsCount: 134,
      moviesWatchedCount: 567,
      topMovies: ['hereditary', 'midsommar', 'get_out', 'parasite', 'the_witch'],
      favoriteTvShows: ['white_lotus', 'succession', 'fleabag'],
      createdAt: DateTime(2023, 8, 3),
    ),
    UserModel(
      uid: 'user_3',
      email: 'kai@watchly.app',
      username: 'kai_reviews',
      bio: 'Nolan fanboy. Kubrick worshipper. Aspiring director.',
      photoUrl: '',
      favoriteGenres: ['Drama', 'Action', 'Fantasy'],
      followersCount: 193,
      followingCount: 220,
      reviewsCount: 52,
      moviesWatchedCount: 201,
      topMovies: ['the_dark_knight', 'memento', 'oppenheimer', 'tenet', 'prestige'],
      favoriteTvShows: ['peaky_blinders', 'band_of_brothers', 'chernobyl'],
      createdAt: DateTime(2024, 3, 22),
    ),
  ];

  MockAuthRepository() {
    _currentUser = _users[0]; // Pre-login as first mock user
    Future.microtask(() => _streamController._emit(_currentUser));
  }

  @override
  Stream<UserModel?> get authStateChanges => _streamController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('User not found'),
    );
    _currentUser = user;
    _streamController._emit(_currentUser);
    return user;
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final newUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      username: username,
      createdAt: DateTime.now(),
    );
    _users.add(newUser);
    _currentUser = newUser;
    _streamController._emit(_currentUser);
    return newUser;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    _currentUser = _users[0];
    _streamController._emit(_currentUser);
    return _users[0];
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = null;
    _streamController._emit(null);
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _users.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _users.indexWhere((u) => u.uid == user.uid);
    if (idx != -1) {
      _users[idx] = user;
      if (_currentUser?.uid == user.uid) {
        _currentUser = user;
        _streamController._emit(_currentUser);
      }
    }
  }

  @override
  Stream<UserModel?> watchUserProfile(String uid) {
    // Mock: emit from in-memory list once; re-emits happen via authStateChanges
    return Stream.fromFuture(getUserProfile(uid));
  }
}


class _AuthStreamController {
  UserModel? _lastValue;
  final List<void Function(UserModel?)> _listeners = [];

  Stream<UserModel?> get stream async* {
    yield _lastValue;
    await for (final event in _broadcastStream) {
      yield event;
    }
  }

  final _controller = _SimpleStreamController<UserModel?>();
  Stream<UserModel?> get _broadcastStream => _controller.stream;

  void _emit(UserModel? user) {
    _lastValue = user;
    _controller._add(user);
  }
}

class _SimpleStreamController<T> {
  final List<void Function(T)> _listeners = [];
  bool _closed = false;

  Stream<T> get stream => Stream.multi((controller) {
    void listener(T value) => controller.add(value);
    _listeners.add(listener);
    controller.onCancel = () => _listeners.remove(listener);
  });

  void _add(T value) {
    if (!_closed) {
      for (final l in List.from(_listeners)) {
        l(value);
      }
    }
  }
}
