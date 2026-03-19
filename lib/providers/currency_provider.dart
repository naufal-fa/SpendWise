import 'package:flutter/material.dart';

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

  Currency get selected => _selected;

  void setCurrency(Currency currency) {
    _selected = currency;
    notifyListeners();
  }
}
