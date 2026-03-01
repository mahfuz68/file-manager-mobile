// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String getFriendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email. Please check your email or register first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Try again later.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        case 'invalid-credential':
          return 'Invalid credential. Please check your Firebase configuration.';
        case 'operation-not-allowed':
          return 'Authentication method not enabled. Contact admin to enable email/password login.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password is too weak. Please use at least 6 characters.';
        default:
          return '${e.message}\n(Error code: ${e.code})';
      }
    } else if (e is Exception) {
      return e.toString();
    } else {
      return 'Unknown error occurred: $e';
    }
  }
}
