import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../widgets/transaction_tile.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';

class DashboardScreen extends StatelessWidget {
  final TransactionProvider transactionProvider;
  final CurrencyProvider currencyProvider;
  final VoidCallback onViewAllHistory;

  const DashboardScreen({
    super.key,
    required this.transactionProvider,
    required this.currencyProvider,
    required this.onViewAllHistory,
  });

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
              const SizedBox(height: 16),
              _buildBalanceCard(),
              const SizedBox(height: 32),
              _buildSpendingOverview(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary20,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary30),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SpendWise',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    double totalIncome = 0;
    double totalExpense = 0;
    
    // We calculate from ALL transactions directly to avoid active history filters messing it up
    for (var tx in transactionProvider.transactions) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    double totalBalance = totalIncome - totalExpense;
    
    final currency = currencyProvider.selected;
    final formatCurrency = NumberFormat('#,###');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFFB00885)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.glowMagenta,
        ),
        child: Stack(
          children: [
            // Decorative blurred circles
            Positioned(
              right: -32,
              top: -32,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              left: -16,
              bottom: -16,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL BALANCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${totalBalance < 0 ? '-' : ''}${currency.symbol}${formatCurrency.format(totalBalance.abs())}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: totalBalance < 0 ? AppColors.dangerRed : Colors.white,
                    letterSpacing: -1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INCOME',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${currency.symbol}${formatCurrency.format(totalIncome)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPENSES',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '-${currency.symbol}${formatCurrency.format(totalExpense)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingOverview() {
    final spendingThisWeek = List.filled(7, 0.0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find Monday of the current week (weekday 1 = Monday, 7 = Sunday)
    final monday = today.subtract(Duration(days: today.weekday - 1));
    
    double maxSpending = 0.0;

    for (var tx in transactionProvider.transactions) {
      if (!tx.isIncome) {
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final differenceFromMonday = txDate.difference(monday).inDays;
        
        // Index 0 is Monday, 6 is Sunday
        if (differenceFromMonday >= 0 && differenceFromMonday <= 6) {
          spendingThisWeek[differenceFromMonday] += tx.amount;
          if (spendingThisWeek[differenceFromMonday] > maxSpending) {
            maxSpending = spendingThisWeek[differenceFromMonday];
          }
        }
      }
    }

    final chartMaxY = maxSpending > 0 ? maxSpending * 1.2 : 100.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Spending Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary5,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primary,
                      tooltipRoundedRadius: 6,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (rod.toY == 0) return null; // hide tooltip if 0
                        return BarTooltipItem(
                          '${currencyProvider.selected.symbol}${NumberFormat('#,###').format(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                          final idx = value.toInt();
                          final isActive = idx == (today.weekday - 1); // today
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[idx],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(7, (index) {
                    return _makeBar(index, spendingThisWeek[index], index == (today.weekday - 1));
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, bool isActive) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isActive ? AppColors.primary : AppColors.primary20,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: false,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    // Note: this takes the un-filtered `transactions` and sorts them,
    // to prevent History filters from hiding Home recent activities.
    // So we don't use sortedTransactions from provider because it might have search/category filters active right now.
    final allSorted = [...transactionProvider.transactions];
    allSorted.sort((a, b) => b.date.compareTo(a.date));
    
    final recent = allSorted.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (allSorted.isNotEmpty)
                TextButton(
                  onPressed: onViewAllHistory,
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap the + button to add one',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ...recent.map((tx) {
              final sign = tx.isIncome ? '+' : '-';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TransactionTile(
                  icon: tx.categoryIcon,
                  title: tx.categoryLabel,
                  subtitle: tx.note?.isNotEmpty == true
                      ? tx.note!
                      : '${tx.isIncome ? 'Income' : 'Outcome'} • ${DateFormat('hh:mm a').format(tx.date)}',
                  amount: '$sign ${tx.currencySymbol}${NumberFormat('#,###').format(tx.amount)}',
                  isIncome: tx.isIncome,
                ),
              );
            }),
        ],
      ),
    );
  }
}
