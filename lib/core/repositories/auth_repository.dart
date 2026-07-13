import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  
  UserModel? get currentUser;

  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  Future<UserModel> signUpWithEmailAndPassword(String email, String username, String password);

  Future<UserModel> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<UserModel?> getUserProfile(String uid);

  Future<void> updateUserProfile(UserModel user);

  /// Returns a real-time stream of the user document so counters
  /// (followers, reviews, films watched) update live in the UI.
  Stream<UserModel?> watchUserProfile(String uid);
}
