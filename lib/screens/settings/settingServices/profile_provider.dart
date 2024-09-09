import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _storeName;

  String? get storeName => _storeName;

  Future<void> fetchProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('stores').doc(user.uid).get();
      _storeName = userDoc['storeName'];
      notifyListeners();
    }
  }

  Future<void> updateProfile(String storeName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('stores').doc(user.uid).update({
        'storeName': storeName,
      });
      _storeName = storeName;
      notifyListeners();
    } else {
      throw Exception('No user is currently signed in.');
    }
  }
}
