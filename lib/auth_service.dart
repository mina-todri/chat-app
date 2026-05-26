import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserModel {
  final String name;
  final String uid;
  final String email;
  final String? profilePic;

  UserModel({
    required this.name,
    required this.uid,
    required this.email,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'email': email, "profilePic": profilePic};
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePic: data['profilePic'],
    );
  }
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  AuthService() {
    _googleSignIn.initialize(
      serverClientId:
          '434897272916-22hq4hpft4hm7iha7ganjugprj945j1a.apps.googleusercontent.com',
    );
  }
  Future<User> signUp(String email, String password, String name) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.user!.uid)
          .set(
          {...UserModel(name: name, uid: user.user!.uid, email: email).toMap(),
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),}
    );

      return user.user!;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User> signin(String email, String password) async {
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return user.user!;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential?> signinWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set(
            {...UserModel(
              name: user.displayName ?? "Username",
              uid: user.uid,
              email: user.email ?? "",
              profilePic: user.photoURL,
            ).toMap(),
              'isOnline': true,
              'lastSeen': FieldValue.serverTimestamp(),
              'createdAt': FieldValue.serverTimestamp(),
            },SetOptions(merge: true)
            );
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
