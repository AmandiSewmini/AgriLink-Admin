import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Admin signed in: ${credential.user?.email}');
      return credential;
    } catch (e) {
      print(' Sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ Admin signed out');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
