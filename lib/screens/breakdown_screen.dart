import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/month_year_picker_sheet.dart';

class BreakdownScreen extends StatefulWidget {
  final TransactionProvider transactionProvider;
  final CurrencyProvider currencyProvider;
  final void Function(String categoryLabel, DateTime month) onCategoryTap;

  const BreakdownScreen({
    super.key,
    required this.transactionProvider,
    required this.currencyProvider,
    required this.onCategoryTap,
  });

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  bool _showAllCategories = false;
  DateTime _selectedMonth = DateTime.now();

  Future<void> _pickMonth() async {
    final picked = await showMonthYearPickerSheet(context, _selectedMonth);
    if (picked != null && (picked.year != _selectedMonth.year || picked.month != _selectedMonth.month)) {
      setState(() {
        _selectedMonth = picked;
        _showAllCategories = false; // Reset toggle on month change
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Process data for the selected month
    final currentMonthExpenses = widget.transactionProvider.transactions.where((tx) =>
        !tx.isIncome &&
        tx.date.year == _selectedMonth.year &&
        tx.date.month == _selectedMonth.month).toList();

    double totalSpentThisMonth = 0;
    final Map<String, _CategoryData> categoryDataMap = {};

    for (var tx in currentMonthExpenses) {
      totalSpentThisMonth += tx.amount;
      if (!categoryDataMap.containsKey(tx.categoryLabel)) {
        categoryDataMap[tx.categoryLabel] = _CategoryData(
          label: tx.categoryLabel,
          icon: tx.categoryIcon,
          amount: 0,
          count: 0,
        );
      }
      categoryDataMap[tx.categoryLabel]!.amount += tx.amount;
      categoryDataMap[tx.categoryLabel]!.count += 1;
    }

    final topCategories = categoryDataMap.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _DonutChartWidget(
                categories: topCategories,
                totalSpent: totalSpentThisMonth,
                currencyProvider: widget.currencyProvider,
                selectedMonth: _selectedMonth,
              ),
              const SizedBox(height: 32),
              _buildCategoriesSection(topCategories, totalSpentThisMonth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    final monthText = isCurrentMonth ? 'This Month' : DateFormat('MMM yyyy').format(_selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary10,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics, color: AppColors.primary),
          ),
          Text(
            'Analysis ($monthText)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: _pickMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // Donut chart moved to _DonutChartWidget

  Widget _buildCategoriesSection(List<_CategoryData> categories, double totalSpent) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'No expenses this month',
                style: TextStyle(color: AppColors.textPrimary.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final currency = widget.currencyProvider.selected;
    final formatCurrency = NumberFormat('#,###');

    final displayCategories = _showAllCategories ? categories : categories.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showAllCategories ? 'All Categories' : 'Top Categories',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (categories.length > 5)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllCategories = !_showAllCategories;
                    });
                  },
                  child: Text(
                    _showAllCategories ? 'Back' : 'View All',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isTop = index == 0 && !_showAllCategories;
            final percentage = totalSpent > 0 ? (category.amount / totalSpent) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => widget.onCategoryTap(category.label, _selectedMonth),
                child: _buildCategoryItem(
                  icon: category.icon,
                  name: category.label,
                  amount: '${currency.symbol}${formatCurrency.format(category.amount)}',
                  percentage: percentage,
                  percentText: '${(percentage * 100).toStringAsFixed(1)}% OF TOTAL',
                  transactions: '${category.count} TRANSACTIONS',
                  isTop: isTop,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String name,
    required String amount,
    required double percentage,
    required String percentText,
    required String transactions,
    bool isTop = false,
  }) {
    return Container(
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
              color: isTop ? AppColors.primary : AppColors.primary20,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isTop
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isTop ? Colors.white : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 6,
                    backgroundColor: AppColors.primary10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTop
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: percentage * 2 + 0.2),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      percentText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      transactions,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartWidget extends StatefulWidget {
  final List<_CategoryData> categories;
  final double totalSpent;
  final CurrencyProvider currencyProvider;
  final DateTime selectedMonth;

  const _DonutChartWidget({
    Key? key,
    required this.categories,
    required this.totalSpent,
    required this.currencyProvider,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  State<_DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<_DonutChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final currency = widget.currencyProvider.selected;
    final formatCurrency = NumberFormat('#,###');

    final hasData = widget.categories.isNotEmpty;
    
    final List<Color> sectionColors = [
      AppColors.primary,
      AppColors.primary.withValues(alpha: 0.7),
      AppColors.primary.withValues(alpha: 0.4),
      AppColors.primary.withValues(alpha: 0.2),
      AppColors.primary.withValues(alpha: 0.1),
    ];

    List<PieChartSectionData> pieSections = [];
    if (hasData) {
      for (int i = 0; i < widget.categories.length; i++) {
        final category = widget.categories[i];
        final isTouched = i == touchedIndex;
        final double radius = isTouched ? 22.0 : (i == 0 ? 18.0 : 14.0);

        pieSections.add(
          PieChartSectionData(
            value: category.amount,
            color: sectionColors[i % sectionColors.length],
            radius: radius,
            showTitle: isTouched,
            title: isTouched ? '${((category.amount / widget.totalSpent) * 100).toStringAsFixed(0)}%' : '',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titlePositionPercentageOffset: 0.55,
          ),
        );
      }
    } else {
      pieSections.add(
        PieChartSectionData(
          value: 100,
          color: AppColors.primary.withValues(alpha: 0.1),
          radius: 14,
          showTitle: false,
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: 256,
        height: 256,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 80,
                startDegreeOffset: -90,
                sections: pieSections,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  touchedIndex == -1 ? 'Total Spent' : widget.categories[touchedIndex].label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  touchedIndex == -1 
                    ? '${currency.symbol}${formatCurrency.format(widget.totalSpent)}'
                    : '${currency.symbol}${formatCurrency.format(widget.categories[touchedIndex].amount)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  hasData 
                    ? (touchedIndex == -1 ? DateFormat('MMM yyyy').format(widget.selectedMonth) : '${((widget.categories[touchedIndex].amount / widget.totalSpent) * 100).toStringAsFixed(1)}% of total')
                    : 'No Data',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String label;
  final IconData icon;
  double amount;
  int count;

  _CategoryData({
    required this.label,
    required this.icon,
    required this.amount,
    required this.count,
  });
}
