import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProviders with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _storeName;
  String? _storeId;

  User? get user => _user;
  String? get storeName => _storeName;
  String? get storeId => _storeId;

  Future<void> fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('stores').doc(user.uid).get();
      _user = user;
      _storeId = userDoc.id;
      _storeName = userDoc['storeName']; // Fetch storeName
      notifyListeners();
    }
  }

  Future<void> signInAsAdmin(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signUpAsStoreOwner(
      String email, String password, String storeName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Add store details to Firestore
      await _firestore.collection('stores').doc(_user!.uid).set({
        'storeName': storeName,
        'ownerEmail': email,
        'createdAt': Timestamp.now(),
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign up store owner: $e');
    }
  }

  Future<void> signInAsStoreOwner(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      SnackBar(content: Text(e.toString()));
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
    notifyListeners();
  }
}
