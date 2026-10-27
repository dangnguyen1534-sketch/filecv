
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userChanges => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user!;

    await user.updateDisplayName(name.trim());

    // Gửi liên kết xác minh đến email.
    await user.sendEmailVerification();

    // Tạo hồ sơ ban đầu trong Firestore.
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'displayName': name.trim(),
      'email': email.trim(),
      'bio': '',
      'avatarUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    await user.sendEmailVerification();
  }

  Future<bool> reloadAndCheckVerification() async {
    await _auth.currentUser?.reload();

    final user = _auth.currentUser;

    return user != null && user.emailVerified;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
