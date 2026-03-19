import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../providers/currency_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final CurrencyProvider currencyProvider;

  const SettingsScreen({super.key, required this.currencyProvider});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminders = true;
  bool _budgetAlerts = NotificationService().isBudgetAlertsEnabled;
  bool _weeklyReports = false;

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = CurrencyProvider.currencies.where((c) {
              final q = searchQuery.toLowerCase();
              return c.code.toLowerCase().contains(q) ||
                  c.name.toLowerCase().contains(q) ||
                  c.symbol.contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary40,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Currency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      TextField(
                        style: const TextStyle(fontSize: 14),
                        onChanged: (v) => setSheetState(() => searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search currency...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          prefixIcon: Icon(Icons.search, color: AppColors.primary60),
                          filled: true,
                          fillColor: AppColors.primary5,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final currency = filtered[index];
                            final isSelected =
                                widget.currencyProvider.selected.code == currency.code;
                            return GestureDetector(
                              onTap: () {
                                widget.currencyProvider.setCurrency(currency);
                                Navigator.pop(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(color: AppColors.primary)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      currency.flag,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currency.code,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            currency.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      currency.symbol,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildNotificationsSection(),
              const SizedBox(height: 24),
              _buildGeneralSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'NOTIFICATIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary5,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary10),
            ),
            child: Column(
              children: [
                _buildToggleItem(
                  icon: Icons.alarm,
                  label: 'Daily Reminders',
                  value: _dailyReminders,
                  onChanged: (v) {
                    setState(() => _dailyReminders = v);
                    if (v) NotificationService().scheduleDailyReminders();
                    else NotificationService().clearDailyReminders();
                  },
                  showBorder: true,
                ),
                _buildToggleItem(
                  icon: Icons.warning_rounded,
                  label: 'Budget Alerts',
                  value: _budgetAlerts,
                  onChanged: (v) {
                    setState(() => _budgetAlerts = v);
                    NotificationService().isBudgetAlertsEnabled = v;
                  },
                  showBorder: true,
                ),
                _buildToggleItem(
                  icon: Icons.insights,
                  label: 'Weekly Reports',
                  value: _weeklyReports,
                  onChanged: (v) {
                    setState(() => _weeklyReports = v);
                    if (v) NotificationService().scheduleWeeklyReport();
                    else NotificationService().clearWeeklyReport();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    final currency = widget.currencyProvider.selected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'GENERAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary5,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary10),
            ),
            child: Column(
              children: [
                _buildCurrencyItem(
                  icon: Icons.payments,
                  label: 'Currency',
                  trailing: currency.displayLabel,
                  onTap: _showCurrencyPicker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: AppColors.primary10))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary20,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem({
    required IconData icon,
    required String label,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary20,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  trailing,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
