import 'package:flutter/material.dart';
import '../core/app_colors.dart';

Future<DateTime?> showMonthYearPickerSheet(BuildContext context, DateTime initialDate) async {
  int pickingYear = initialDate.year;
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                      onPressed: () { setModalState(() { pickingYear--; }); },
                    ),
                    Text(
                      pickingYear.toString(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                      onPressed: () { setModalState(() { pickingYear++; }); },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final monthNum = index + 1;
                    final isSelected = pickingYear == initialDate.year && monthNum == initialDate.month;
                    final now = DateTime.now();
                    final isThisMonth = pickingYear == now.year && monthNum == now.month;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, DateTime(pickingYear, monthNum));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : (isThisMonth ? AppColors.primary20 : AppColors.primary5),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? null : Border.all(color: AppColors.primary10),
                        ),
                        child: Text(
                          months[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected || isThisMonth ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
