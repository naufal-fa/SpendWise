import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Currency {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  String get displayLabel => '$code ($symbol)';
}

class CurrencyProvider extends ChangeNotifier {
  static const List<Currency> currencies = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    Currency(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah', flag: '🇮🇩'),
    Currency(code: 'KRW', symbol: '₩', name: 'South Korean Won', flag: '🇰🇷'),
    Currency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
    Currency(code: 'THB', symbol: '฿', name: 'Thai Baht', flag: '🇹🇭'),
    Currency(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit', flag: '🇲🇾'),
    Currency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', flag: '🇸🇬'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
    Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    Currency(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc', flag: '🇨🇭'),
    Currency(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal', flag: '🇸🇦'),
    Currency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', flag: '🇧🇷'),
  ];

  Currency _selected = currencies[0]; // Default: USD

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('selected_currency');
    if (savedCode != null) {
      final index = currencies.indexWhere((c) => c.code == savedCode);
      if (index != -1) {
        _selected = currencies[index];
        notifyListeners();
      }
    }
  }

  Currency get selected => _selected;

  Future<void> setCurrency(Currency currency) async {
    _selected = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', currency.code);
  }
}
