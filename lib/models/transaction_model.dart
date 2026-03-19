import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final double amount;
  final String currencySymbol;
  final String currencyCode;
  final IconData categoryIcon;
  final String categoryLabel;
  final DateTime date;
  final String? note;
  final String? attachmentPath;
  final bool isIncome;
  final DateTime createdAt;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.currencySymbol,
    required this.currencyCode,
    required this.categoryIcon,
    required this.categoryLabel,
    required this.date,
    this.note,
    this.attachmentPath,
    required this.isIncome,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currencySymbol': currencySymbol,
      'currencyCode': currencyCode,
      'categoryIconCodePoint': categoryIcon.codePoint,
      'categoryIconFontFamily': categoryIcon.fontFamily,
      'categoryIconFontPackage': categoryIcon.fontPackage,
      'categoryLabel': categoryLabel,
      'date': date.toIso8601String(),
      'note': note,
      'attachmentPath': attachmentPath,
      'isIncome': isIncome,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      currencySymbol: json['currencySymbol'],
      currencyCode: json['currencyCode'],
      categoryIcon: IconData(
        json['categoryIconCodePoint'],
        fontFamily: json['categoryIconFontFamily'],
        fontPackage: json['categoryIconFontPackage'],
      ),
      categoryLabel: json['categoryLabel'],
      date: DateTime.parse(json['date']),
      note: json['note'],
      attachmentPath: json['attachmentPath'],
      isIncome: json['isIncome'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
