import 'package:flutter/material.dart';

class QuantityProvider extends ChangeNotifier {
  int _currentQuantity = 1;
  List<double> _baseIngredientsAmounts = [];
  int get currentQuantity => _currentQuantity;
  void setBaseIngredientsAmounts(List<double> amounts) {
    _baseIngredientsAmounts = amounts;
    notifyListeners();
  }

  List<String>? get updateIngredientsAmounts {
    return _baseIngredientsAmounts
        .map<String>((amount) => (amount * _currentQuantity).toStringAsFixed(1))
        .toList();
  }

  void increment() {
    _currentQuantity++;
    notifyListeners();
  }

  void decrement() {
    if (_currentQuantity > 1) {
      _currentQuantity--;
      notifyListeners();
    }
  }
}
