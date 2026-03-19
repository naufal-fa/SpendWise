import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class TransactionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.icon,
    this.iconBgColor = const Color(0x33F20DB9),
    this.iconColor = AppColors.primary,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isIncome = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary5,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary10),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? AppColors.successNeon : AppColors.primary,
                shadows: isIncome
                    ? [
                        Shadow(
                          color: AppColors.successNeon.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ]
                    : [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
