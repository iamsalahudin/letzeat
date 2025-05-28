import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favoriteItems => _favoriteIds;

  FavoriteProvider() {
    fetchFavorites();
  }

  void toggleFavorite(DocumentSnapshot product) async {
    String itemId = product.id;
    if (_favoriteIds.contains(itemId)) {
      _favoriteIds.remove(itemId);
      await removeFavorite(itemId);
    } else {
      _favoriteIds.add(itemId);
      await addFavorite(itemId);
    }
    notifyListeners();
  }

  bool isFavorite(DocumentSnapshot product) {
    return _favoriteIds.contains(product.id);
  }

  Future<void> addFavorite(String itemId) async {
    try {
      await _firestore.collection('favorites').doc(itemId).set({
        'isFavorite': true,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding favorite: $e');
      }
    }
  }

  Future<void> removeFavorite(String itemId) async {
    try {
      await _firestore.collection('favorites').doc(itemId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing favorite: $e');
      }
    }
  }

  Future<void> fetchFavorites() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('favorites').get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
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
