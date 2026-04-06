import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currencyCode = 'TL';
  double _exchangeRate = 34.0; // 1 USD = 34.0 TL

  CurrencyProvider() {
    _loadCurrency();
  }

  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencyCode == 'TL' ? '₺' : '\$';

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString('currency_code') ?? 'TL';
    _updateExchangeRate();
    notifyListeners();
  }

  void _updateExchangeRate() {
    if (_currencyCode == 'TL') {
      _exchangeRate = 34.0;
    } else {
      _exchangeRate = 1.0;
    }
  }

  Future<void> setCurrency(String code) async {
    _currencyCode = code;
    _updateExchangeRate();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', code);
    notifyListeners();
  }

  String convert(dynamic price) {
    double numericPrice = 0.0;
    if (price is String) {
      numericPrice = double.tryParse(price) ?? 0.0;
    } else if (price is num) {
      numericPrice = price.toDouble();
    }

    double convertedPrice = numericPrice * _exchangeRate;

    // Format to 2 decimal places if needed, or integer if whole number
    String formattedPrice = convertedPrice.toStringAsFixed(2);
    if (formattedPrice.endsWith('.00')) {
      formattedPrice = formattedPrice.substring(0, formattedPrice.length - 3);
    }

    return '$currencySymbol$formattedPrice';
  }
}
