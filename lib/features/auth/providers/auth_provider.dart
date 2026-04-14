import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';

// ── Firebase Auth stream ──
final firebaseAuthProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ── Firestore user document stream (only when logged in) ──
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final authAsync = ref.watch(firebaseAuthProvider);
  return authAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snap) {
        if (!snap.exists) return null;
        return AppUser.fromFirestore(snap);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ── Auth Actions ──
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Seed an empty user doc with hasCompletedOnboarding = false
    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'displayName': '',
      'hasCompletedOnboarding': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) return;
    // Re-authenticate before destructive action
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);
    await _db.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
