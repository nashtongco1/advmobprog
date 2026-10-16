import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final response = await http
        .post(
          Uri.parse('$host/auth/login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'username': username,
            'password': password,
            'expiresInMins': 60,
          }),
        )
        .timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode == 200) {
      final data = Map<String, dynamic>.from(
        jsonDecode(response.body),
      );

      data['loginType'] = 'dummyjson';

      return data;
    }

    throw Exception(
      'Invalid username or password.',
    );
  }

  Future<firebase_auth.UserCredential> signIn(
    String email,
    String password,
  ) async {
    try {
      final credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Unable to load Firebase user.',
        );
      }

      await _loadFirestoreProfileToLocal(
        firebaseUser.uid,
      );

      await _saveFirebaseUserData(
        firebaseUser,
      );

      await _syncFirebaseUserToFirestore(
        firebaseUser,
      );

      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    }
  }

  Future<firebase_auth.UserCredential> createAccount({
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
    required String emailAddress,
    required String password,
  }) async {
    try {
      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Unable to create account.',
        );
      }

      await firebaseUser.updateDisplayName(
        username.trim(),
      );

      await firebaseUser.reload();

      final updatedUser =
          _auth.currentUser ?? firebaseUser;

      final prefs =
          await SharedPreferences.getInstance();

      await _saveFirebaseProfile(
        prefs: prefs,
        uid: updatedUser.uid,
        firstName: fName.trim(),
        lastName: lName.trim(),
        age: age,
        contactNo: contactNo.trim(),
      );

      await _saveFirebaseUserData(
        updatedUser,
      );

      await _firestore
          .collection('users')
          .doc(updatedUser.uid)
          .set(
        {
          'uid': updatedUser.uid,
          'firebaseUid': updatedUser.uid,
          'loginType': 'firebase',
          'username': username.trim(),
          'email':
              updatedUser.email ??
              emailAddress.trim(),
          'firstName': fName.trim(),
          'lastName': lName.trim(),
          'age': age,
          'contactNo': contactNo.trim(),
          'gender': '',
          'image':
              updatedUser.photoURL ?? '',
          'createdAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    }
  }

  Future<void> saveUserData(
    Map<String, dynamic> userData,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await _clearActiveSession(
      prefs,
    );

    await prefs.setInt(
      'id',
      userData['id'] ?? 0,
    );

    await prefs.setString(
      'loginType',
      userData['loginType'] ?? 'dummyjson',
    );

    await prefs.setString(
      'username',
      userData['username'] ?? '',
    );

    await prefs.setString(
      'email',
      userData['email'] ?? '',
    );

    await prefs.setString(
      'firstName',
      userData['firstName'] ?? '',
    );

    await prefs.setString(
      'lastName',
      userData['lastName'] ?? '',
    );

    await prefs.setInt(
      'age',
      userData['age'] ?? 0,
    );

    await prefs.setString(
      'contactNo',
      userData['phone'] ??
          userData['contactNo'] ??
          '',
    );

    await prefs.setString(
      'gender',
      userData['gender'] ?? '',
    );

    await prefs.setString(
      'image',
      userData['image'] ?? '',
    );

    final accessToken =
        userData['accessToken'] ??
        userData['token'] ??
        '';

    await prefs.setString(
      'accessToken',
      accessToken,
    );

    await prefs.setString(
      'refreshToken',
      userData['refreshToken'] ?? '',
    );
  }

  Future<void> _saveFirebaseProfile({
    required SharedPreferences prefs,
    required String uid,
    required String firstName,
    required String lastName,
    required int age,
    required String contactNo,
  }) async {
    await prefs.setString(
      'firebase_${uid}_firstName',
      firstName,
    );

    await prefs.setString(
      'firebase_${uid}_lastName',
      lastName,
    );

    await prefs.setInt(
      'firebase_${uid}_age',
      age,
    );

    await prefs.setString(
      'firebase_${uid}_contactNo',
      contactNo,
    );
  }

  Future<void> _loadFirestoreProfileToLocal(
    String uid,
  ) async {
    try {
      final document = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!document.exists) {
        return;
      }

      final data = document.data();

      if (data == null) {
        return;
      }

      final prefs =
          await SharedPreferences.getInstance();

      await _saveFirebaseProfile(
        prefs: prefs,
        uid: uid,
        firstName:
            data['firstName']?.toString() ?? '',
        lastName:
            data['lastName']?.toString() ?? '',
        age: data['age'] is int
            ? data['age'] as int
            : int.tryParse(
                  data['age']?.toString() ?? '',
                ) ??
                0,
        contactNo:
            data['contactNo']?.toString() ?? '',
      );
    } catch (_) {}
  }

  Future<void> _saveFirebaseUserData(
    firebase_auth.User? firebaseUser,
  ) async {
    if (firebaseUser == null) {
      throw Exception(
        'Unable to load Firebase user.',
      );
    }

    final prefs =
        await SharedPreferences.getInstance();

    final uid = firebaseUser.uid;

    final firstName =
        prefs.getString(
          'firebase_${uid}_firstName',
        ) ??
        '';

    final lastName =
        prefs.getString(
          'firebase_${uid}_lastName',
        ) ??
        '';

    final age =
        prefs.getInt(
          'firebase_${uid}_age',
        ) ??
        0;

    final contactNo =
        prefs.getString(
          'firebase_${uid}_contactNo',
        ) ??
        '';

    final token =
        await firebaseUser.getIdToken() ?? '';

    await _clearActiveSession(
      prefs,
    );

    await prefs.setInt(
      'id',
      0,
    );

    await prefs.setString(
      'loginType',
      'firebase',
    );

    await prefs.setString(
      'firebaseUid',
      uid,
    );

    await prefs.setString(
      'username',
      firebaseUser.displayName ?? '',
    );

    await prefs.setString(
      'email',
      firebaseUser.email ?? '',
    );

    await prefs.setString(
      'firstName',
      firstName,
    );

    await prefs.setString(
      'lastName',
      lastName,
    );

    await prefs.setInt(
      'age',
      age,
    );

    await prefs.setString(
      'contactNo',
      contactNo,
    );

    await prefs.setString(
      'gender',
      '',
    );

    await prefs.setString(
      'image',
      firebaseUser.photoURL ?? '',
    );

    await prefs.setString(
      'accessToken',
      token,
    );

    await prefs.setString(
      'refreshToken',
      firebaseUser.refreshToken ?? '',
    );
  }

  Future<void> _syncFirebaseUserToFirestore(
    firebase_auth.User firebaseUser,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final uid = firebaseUser.uid;

    final firstName =
        prefs.getString(
          'firebase_${uid}_firstName',
        ) ??
        prefs.getString('firstName') ??
        '';

    final lastName =
        prefs.getString(
          'firebase_${uid}_lastName',
        ) ??
        prefs.getString('lastName') ??
        '';

    final age =
        prefs.getInt(
          'firebase_${uid}_age',
        ) ??
        prefs.getInt('age') ??
        0;

    final contactNo =
        prefs.getString(
          'firebase_${uid}_contactNo',
        ) ??
        prefs.getString('contactNo') ??
        '';

    final documentReference =
        _firestore.collection('users').doc(uid);

    final existingDocument =
        await documentReference.get();

    final data = <String, dynamic>{
      'uid': uid,
      'firebaseUid': uid,
      'loginType': 'firebase',
      'username':
          firebaseUser.displayName ??
          prefs.getString('username') ??
          '',
      'email':
          firebaseUser.email ??
          prefs.getString('email') ??
          '',
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'contactNo': contactNo,
      'gender':
          prefs.getString('gender') ?? '',
      'image':
          firebaseUser.photoURL ??
          prefs.getString('image') ??
          '',
      'updatedAt':
          FieldValue.serverTimestamp(),
    };

    if (!existingDocument.exists) {
      data['createdAt'] =
          FieldValue.serverTimestamp();
    }

    await documentReference.set(
      data,
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<Map<String, dynamic>>
      getUserData() async {
    final prefs =
        await SharedPreferences.getInstance();

    final loginType =
        prefs.getString('loginType') ?? '';

    if (loginType == 'firebase' &&
        _auth.currentUser != null) {
      final firebaseUser =
          _auth.currentUser!;

      final uid = firebaseUser.uid;

      final token =
          await firebaseUser.getIdToken() ?? '';

      return {
        'id': 0,
        'firebaseUid': uid,
        'loginType': 'firebase',
        'username':
            firebaseUser.displayName ??
            prefs.getString('username') ??
            '',
        'email':
            firebaseUser.email ?? '',
        'firstName':
            prefs.getString(
              'firebase_${uid}_firstName',
            ) ??
            prefs.getString('firstName') ??
            '',
        'lastName':
            prefs.getString(
              'firebase_${uid}_lastName',
            ) ??
            prefs.getString('lastName') ??
            '',
        'age':
            prefs.getInt(
              'firebase_${uid}_age',
            ) ??
            prefs.getInt('age') ??
            0,
        'contactNo':
            prefs.getString(
              'firebase_${uid}_contactNo',
            ) ??
            prefs.getString('contactNo') ??
            '',
        'gender':
            prefs.getString('gender') ??
            '',
        'image':
            firebaseUser.photoURL ??
            prefs.getString('image') ??
            '',
        'accessToken': token,
        'refreshToken':
            firebaseUser.refreshToken ?? '',
      };
    }

    return {
      'id': prefs.getInt('id') ?? 0,
      'firebaseUid':
          prefs.getString('firebaseUid') ??
          '',
      'loginType': loginType,
      'username':
          prefs.getString('username') ?? '',
      'email':
          prefs.getString('email') ?? '',
      'firstName':
          prefs.getString('firstName') ?? '',
      'lastName':
          prefs.getString('lastName') ?? '',
      'age':
          prefs.getInt('age') ?? 0,
      'contactNo':
          prefs.getString('contactNo') ?? '',
      'gender':
          prefs.getString('gender') ?? '',
      'image':
          prefs.getString('image') ?? '',
      'accessToken':
          prefs.getString('accessToken') ??
          '',
      'refreshToken':
          prefs.getString('refreshToken') ??
          '',
    };
  }

  Future<User> getUser() async {
    final data = await getUserData();

    return User.fromJson(data);
  }

  Future<String> getLoginType() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('loginType') ??
        '';
  }

  Future<bool> isLoggedIn() async {
    final prefs =
        await SharedPreferences.getInstance();

    final loginType =
        prefs.getString('loginType') ?? '';

    if (loginType == 'firebase') {
      return _auth.currentUser != null;
    }

    final accessToken =
        prefs.getString('accessToken');

    return accessToken != null &&
        accessToken.isNotEmpty;
  }

  Future<void> updateUsername(
    String username,
  ) async {
    final trimmedUsername =
        username.trim();

    if (trimmedUsername.isEmpty) {
      throw Exception(
        'Username cannot be empty.',
      );
    }

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    try {
      await user.updateDisplayName(
        trimmedUsername,
      );

      await user.reload();

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'username',
        trimmedUsername,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'uid': user.uid,
          'firebaseUid': user.uid,
          'username': trimmedUsername,
          'email': user.email ?? '',
          'loginType': 'firebase',
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    }
  }

  Future<void>
      resetPasswordFromCurrentPassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;

    if (user == null ||
        user.email == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    if (currentPassword.isEmpty) {
      throw Exception(
        'Current password is required.',
      );
    }

    if (newPassword.length < 6) {
      throw Exception(
        'New password must be at least 6 characters.',
      );
    }

    try {
      final credential =
          firebase_auth.EmailAuthProvider
              .credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(
        credential,
      );

      await user.updatePassword(
        newPassword,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    }
  }

  Future<void> deleteAccount(
    String currentPassword,
  ) async {
    final user = _auth.currentUser;

    if (user == null ||
        user.email == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    if (currentPassword.isEmpty) {
      throw Exception(
        'Current password is required.',
      );
    }

    final uid = user.uid;

    try {
      final credential =
          firebase_auth.EmailAuthProvider
              .credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(
        credential,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .delete();

      await user.delete();

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove(
        'firebase_${uid}_firstName',
      );

      await prefs.remove(
        'firebase_${uid}_lastName',
      );

      await prefs.remove(
        'firebase_${uid}_age',
      );

      await prefs.remove(
        'firebase_${uid}_contactNo',
      );

      await _clearActiveSession(
        prefs,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();

    final prefs =
        await SharedPreferences.getInstance();

    await _clearActiveSession(
      prefs,
    );
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    final loginType =
        prefs.getString('loginType') ?? '';

    if (loginType == 'firebase') {
      await _auth.signOut();
    }

    await _clearActiveSession(
      prefs,
    );
  }

  Future<void> _clearActiveSession(
    SharedPreferences prefs,
  ) async {
    final keys = [
      'id',
      'loginType',
      'firebaseUid',
      'username',
      'email',
      'firstName',
      'lastName',
      'age',
      'contactNo',
      'gender',
      'image',
      'accessToken',
      'refreshToken',
    ];

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  String _firebaseErrorMessage(
    firebase_auth.FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account was found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'requires-recent-login':
        return 'Please sign in again before performing this action.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ??
            'Firebase authentication failed.';
    }
  }
}