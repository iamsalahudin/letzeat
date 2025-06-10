import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> get favoriteItems => _favoriteIds;

  FavoriteProvider() {
    fetchFavorites();
  }

  void toggleFavorite(String recipeId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
      await _firestore.collection('favorites').doc(uid).update({
        'recipeIds': FieldValue.arrayRemove([recipeId]),
      });
    } else {
      _favoriteIds.add(recipeId);
      await _firestore.collection('favorites').doc(uid).set({
        'recipeIds': FieldValue.arrayUnion([recipeId]),
      }, SetOptions(merge: true));
    }

    notifyListeners();
  }

  bool isFavorite(String recipeId) {
    return _favoriteIds.contains(recipeId);
  }

  Future<void> fetchFavorites() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('favorites').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('recipeIds')) {
        _favoriteIds = List<String>.from(doc['recipeIds']);
      } else {
        _favoriteIds = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching favorites: $e');
      }
    }

    notifyListeners();
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}
