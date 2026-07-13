import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  UserModel? _currentUser;

  FirebaseAuthRepository();

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        return null;
      }
      try {
        final userDoc = await _db.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          _currentUser = UserModel.fromMap(userDoc.data()!);
          return _currentUser;
        } else {
          // If Firestore document does not exist, create a default one
          final now = DateTime.now();
          final newUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
            bio: '',
            photoUrl: firebaseUser.photoURL ?? '',
            favoriteGenres: [],
            followersCount: 0,
            followingCount: 0,
            reviewsCount: 0,
            moviesWatchedCount: 0,
            topMovies: [],
            favoriteTvShows: [],
            createdAt: now,
          );
          await _db.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
          _currentUser = newUser;
          return newUser;
        }
      } catch (e) {
        // Safe fallback in case of Firestore permissions/network issues
        return UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
          bio: '',
          photoUrl: firebaseUser.photoURL ?? '',
          favoriteGenres: [],
          followersCount: 0,
          followingCount: 0,
          reviewsCount: 0,
          moviesWatchedCount: 0,
          topMovies: [],
          favoriteTvShows: [],
          createdAt: DateTime.now(),
        );
      }
    });
  }

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final userDoc = await _db.collection('users').doc(uid).get();
    
    if (userDoc.exists) {
      final user = UserModel.fromMap(userDoc.data()!);
      _currentUser = user;
      return user;
    } else {
      // Fallback if auth exists but profile does not
      final now = DateTime.now();
      final user = UserModel(
        uid: uid,
        email: email.trim().toLowerCase(),
        username: credential.user!.displayName ?? email.split('@').first,
        bio: '',
        photoUrl: '',
        favoriteGenres: [],
        followersCount: 0,
        followingCount: 0,
        reviewsCount: 0,
        moviesWatchedCount: 0,
        topMovies: [],
        favoriteTvShows: [],
        createdAt: now,
      );
      await _db.collection('users').doc(uid).set(user.toMap());
      _currentUser = user;
      return user;
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String username, String password) async {
    // Create the Firebase Auth user FIRST so that all subsequent Firestore
    // operations are executed as an authenticated user. Querying Firestore
    // before authentication causes a permission-denied error if security rules
    // require request.auth != null.
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    // Now that the user is authenticated, check for username uniqueness.
    final existingUsername = await _db
        .collection('users')
        .where('username', isEqualTo: username.trim())
        .limit(1)
        .get();

    if (existingUsername.docs.isNotEmpty) {
      // Username taken — delete the just-created auth user to keep state clean.
      await credential.user!.delete();
      throw Exception('This username is already taken.');
    }

    final now = DateTime.now();

    final user = UserModel(
      uid: uid,
      email: email.trim().toLowerCase(),
      username: username.trim(),
      bio: '',
      photoUrl: '',
      favoriteGenres: [],
      followersCount: 0,
      followingCount: 0,
      reviewsCount: 0,
      moviesWatchedCount: 0,
      topMovies: [],
      favoriteTvShows: [],
      createdAt: now,
    );

    await _db.collection('users').doc(uid).set(user.toMap());
    _currentUser = user;
    return user;
  }
  @override
  Future<UserModel> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    if (AppConfig.googleServerClientId.isEmpty) {
      throw Exception('Google Sign-In requires googleServerClientId to be configured in AppConfig. Please see the console logs.');
    }
    await googleSignIn.initialize(
      serverClientId: AppConfig.googleServerClientId,
    );
    final googleUser = await googleSignIn.authenticate();
    final auth = googleUser.authentication;

    final firebase_auth.OAuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: null,
      idToken: auth.idToken,
    );

    final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
    final uid = userCredential.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      final now = DateTime.now();
      final user = UserModel(
        uid: uid,
        email: googleUser.email,
        username: googleUser.displayName ?? googleUser.email.split('@').first,
        bio: '',
        photoUrl: googleUser.photoUrl ?? '',
        favoriteGenres: [],
        followersCount: 0,
        followingCount: 0,
        reviewsCount: 0,
        moviesWatchedCount: 0,
        topMovies: [],
        favoriteTvShows: [],
        createdAt: now,
      );
      await _db.collection('users').doc(uid).set(user.toMap());
      _currentUser = user;
      return user;
    } else {
      final user = UserModel.fromMap(doc.data()!);
      _currentUser = user;
      return user;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    // Fire-and-forget: do NOT await GoogleSignIn.signOut().
    // Awaiting it blocks the UI for several seconds, especially when the
    // user signed in with email/password and GoogleSignIn was never
    // fully initialised in this session.
    GoogleSignIn.instance.signOut().catchError((_) {});
    _currentUser = null;
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    if (_currentUser?.uid == user.uid) {
      _currentUser = user;
    }
  }

  @override
  Stream<UserModel?> watchUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final user = UserModel.fromMap(snap.data()!);
      // Keep the in-memory cache in sync when watching the logged-in user
      if (_currentUser?.uid == uid) _currentUser = user;
      return user;
    });
  }
}

