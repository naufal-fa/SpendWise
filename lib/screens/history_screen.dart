import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../widgets/transaction_tile.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/month_year_picker_sheet.dart';
import 'add_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  final TransactionProvider transactionProvider;
  final CurrencyProvider currencyProvider;

  const HistoryScreen({
    super.key,
    required this.transactionProvider,
    required this.currencyProvider,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.restaurant, 'label': 'Food'},
    {'icon': Icons.directions_car, 'label': 'Travel'},
    {'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'icon': Icons.payments, 'label': 'Bills'},
    {'icon': Icons.fitness_center, 'label': 'Health'},
    {'icon': Icons.movie, 'label': 'Entertainment'},
    {'icon': Icons.school, 'label': 'Education'},
    {'icon': Icons.home, 'label': 'Rent'},
    {'icon': Icons.phone_android, 'label': 'Phone'},
    {'icon': Icons.wifi, 'label': 'Internet'},
    {'icon': Icons.local_gas_station, 'label': 'Fuel'},
    {'icon': Icons.more_horiz, 'label': 'Other'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = widget.transactionProvider.groupedByDate;
    final hasTransactions = groupedData.isNotEmpty;
    final isSearching = widget.transactionProvider.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            if (!hasTransactions)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSearching ? Icons.search_off : Icons.receipt_long,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSearching ? 'No results found' : 'No transactions yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSearching 
                          ? 'Try adjusting your search terms'
                          : 'Tap + to add your first transaction',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SlidableAutoCloseBehavior(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100, top: 8),
                    itemCount: groupedData.length,
                    itemBuilder: (context, index) {
                      final dateLabel = groupedData.keys.elementAt(index);
                      final transactions = groupedData[dateLabel]!;
                      
                      return _buildDateGroup(
                        dateLabel,
                        transactions.map((tx) {
                          final sign = tx.isIncome ? '+' : '-';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Slidable(
                              key: ValueKey(tx.id),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.5,
                                children: [
                                  SlidableAction(
                                    padding: EdgeInsets.zero,
                                    onPressed: (_) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddTransactionScreen(
                                            currencyProvider: widget.currencyProvider,
                                            transactionProvider: widget.transactionProvider,
                                            existingTransaction: tx,
                                          ),
                                        ),
                                      );
                                    },
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                  SlidableAction(
                                    padding: EdgeInsets.zero,
                                    onPressed: (_) => widget.transactionProvider.removeTransaction(tx.id),
                                    backgroundColor: AppColors.dangerRed,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                ],
                              ),
                              child: TransactionTile(
                                icon: tx.categoryIcon,
                                title: tx.categoryLabel,
                                subtitle: tx.note?.isNotEmpty == true
                                    ? tx.note!
                                    : '${tx.isIncome ? 'Income' : 'Outcome'} • ${DateFormat('hh:mm a').format(tx.date)}',
                                amount: '$sign ${tx.currencySymbol}${NumberFormat('#,###').format(tx.amount)}',
                                isIncome: tx.isIncome,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMonth() async {
    final currentFilter = widget.transactionProvider.monthFilter ?? DateTime.now();
    final picked = await showMonthYearPickerSheet(context, currentFilter);
    if (picked != null) {
      widget.transactionProvider.setMonthFilter(picked);
    }
  }

  Widget _buildHeader() {
    final selectedMonth = widget.transactionProvider.monthFilter;
    final monthText = selectedMonth == null ? 'All Months' : DateFormat('MMM yyyy').format(selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    monthText,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (selectedMonth != null) 
            GestureDetector(
              onTap: () => widget.transactionProvider.setMonthFilter(null),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.dangerRed, size: 20),
              ),
            )
          else
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => widget.transactionProvider.setSearchQuery(value),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: TextStyle(color: AppColors.textMuted),
          prefixIcon: Icon(Icons.search, color: AppColors.primary60),
          filled: true,
          fillColor: AppColors.primary5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary20),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary20),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final provider = widget.transactionProvider;
    final typeFilter = provider.typeFilter;

    String typeLabel = 'Type';
    if (typeFilter == TransactionTypeFilter.expense) typeLabel = 'Expenses';
    if (typeFilter == TransactionTypeFilter.income) typeLabel = 'Income';

    final filters = [
      {
        'label': 'All',
        'active': !provider.hasActiveFilters,
        'onTap': () => provider.clearFilters(),
      },
      {
        'label': typeLabel,
        'active': typeFilter != TransactionTypeFilter.all,
        'icon': true,
        'onTap': () => _showTypePicker(),
      },
      {
        'label': provider.categoryFilter ?? 'Categories',
        'active': provider.categoryFilter != null,
        'icon': true,
        'onTap': () => _showCategoryPicker(),
      },
      {
        'label': (provider.minAmount != null || provider.maxAmount != null) ? 'Amount...' : 'Amount',
        'active': provider.minAmount != null || provider.maxAmount != null,
        'icon': true,
        'onTap': () => _showAmountPicker(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isActive = filter['active'] as bool;
            final label = filter['label'] as String;
            final hasIcon = filter['icon'] == true;
            final onTap = filter['onTap'] as VoidCallback;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.primary10,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : AppColors.primary,
                        ),
                      ),
                      if (hasIcon) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: isActive ? Colors.white : AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.clear_all, color: AppColors.primary),
                title: const Text('All Types', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  widget.transactionProvider.setTypeFilter(TransactionTypeFilter.all);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: AppColors.dangerRed),
                title: const Text('Expenses', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  widget.transactionProvider.setTypeFilter(TransactionTypeFilter.expense);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: AppColors.successNeon),
                title: const Text('Income', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  widget.transactionProvider.setTypeFilter(TransactionTypeFilter.income);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const Icon(Icons.clear_all, color: AppColors.primary),
                        title: const Text('All Categories', style: TextStyle(color: AppColors.textPrimary)),
                        onTap: () {
                          widget.transactionProvider.setCategoryFilter(null);
                          Navigator.pop(context);
                        },
                      );
                    }
                    final cat = _categories[index - 1];
                    return ListTile(
                      leading: Icon(cat['icon'] as IconData, color: AppColors.primary),
                      title: Text(cat['label'] as String, style: const TextStyle(color: AppColors.textPrimary)),
                      onTap: () {
                        widget.transactionProvider.setCategoryFilter(cat['label'] as String);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAmountPicker() {
    final minController = TextEditingController(text: widget.transactionProvider.minAmount?.toStringAsFixed(0) ?? '');
    final maxController = TextEditingController(text: widget.transactionProvider.maxAmount?.toStringAsFixed(0) ?? '');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Amount Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Min Amount',
                        labelStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.primary10,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Max Amount',
                        labelStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.primary10,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.transactionProvider.setAmountRange(null, null);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Clear Filter'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final min = double.tryParse(minController.text);
                        final max = double.tryParse(maxController.text);
                        widget.transactionProvider.setAmountRange(min, max);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply Range'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateGroup(String title, List<Widget> transactions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary60,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ...transactions,
        ],
      ),
    );
  }
}
