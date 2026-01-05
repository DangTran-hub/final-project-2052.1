import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream lắng nghe trạng thái đăng nhập (để tự động chuyển màn hình)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy ID Token hiện tại (để gọi API Backend)
  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  // Đăng nhập
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Thành công (không có lỗi)
    } on FirebaseAuthException catch (e) {
      return e.message; // Trả về thông báo lỗi
    }
  }

  // Đăng ký
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Tạo tài khoản Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Tạo hồ sơ người dùng trong Firestore
      if (userCredential.user != null) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user', // user hoặc admin
          'devices': [], // Danh sách thiết bị sở hữu (ban đầu rỗng)
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Đã xảy ra lỗi khi tạo hồ sơ người dùng: $e";
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
