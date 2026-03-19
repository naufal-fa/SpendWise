import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final CurrencyProvider currencyProvider;
  final TransactionProvider transactionProvider;
  final TransactionItem? existingTransaction;

  const AddTransactionScreen({
    super.key,
    required this.currencyProvider,
    required this.transactionProvider,
    this.existingTransaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isIncome = false;
  int _selectedCategory = 0;
  DateTime _selectedDate = DateTime.now();
  String? _attachmentPath;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

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
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _amountController.text = NumberFormat('#,###').format(tx.amount);
      _isIncome = tx.isIncome;
      _selectedDate = tx.date;
      if (tx.note != null) _noteController.text = tx.note!;
      _attachmentPath = tx.attachmentPath;
      
      final index = _categories.indexWhere((c) => c['label'] == tx.categoryLabel);
      if (index != -1) _selectedCategory = index;
    }
  }

  String get _formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) {
      return 'Today, ${DateFormat('dd MMM yyyy').format(_selectedDate)}';
    } else if (selected == yesterday) {
      return 'Yesterday, ${DateFormat('dd MMM yyyy').format(_selectedDate)}';
    }
    return DateFormat('EEEE, dd MMM yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── Date Picker ──
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.backgroundDark,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ── Photo Picker ──
  Future<void> _pickAttachment() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary40,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Add Attachment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _imagePicker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() => _attachmentPath = image.path);
                        }
                      },
                    ),
                    _buildPickerOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() => _attachmentPath = image.path);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary20),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Bottom Sheet ──
  void _showAllCategories() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.75,
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
                    'Select Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.85,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = index);
                            Navigator.pop(context);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.primary5,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.primary20,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? AppColors.glowMagenta
                                      : null,
                                ),
                                child: Icon(
                                  cat['icon'] as IconData,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary60,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat['label'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeToggle(),
                    _buildAmountInput(),
                    const SizedBox(height: 32),
                    _buildCategorySection(),
                    const SizedBox(height: 32),
                    _buildDateField(),
                    const SizedBox(height: 16),
                    _buildNoteField(),
                    const SizedBox(height: 24),
                    _buildAttachmentArea(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final title = widget.existingTransaction != null ? 'Edit Transaction' : 'Add Transaction';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 40), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isIncome ? AppColors.dangerRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isIncome
                      ? [
                          BoxShadow(
                            color: AppColors.dangerRed.withValues(alpha: 0.3),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Outcome',
                  style: TextStyle(
                    color: !_isIncome ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isIncome ? AppColors.successNeon : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isIncome
                      ? [
                          BoxShadow(
                            color: AppColors.successNeon.withValues(alpha: 0.3),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Income',
                  style: TextStyle(
                    color: _isIncome ? Colors.black : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    final symbol = widget.currencyProvider.selected.symbol;
    final color = _isIncome ? AppColors.successNeon : AppColors.dangerRed;
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'ENTER AMOUNT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary60,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IntrinsicWidth(
              child: Container(
                constraints: const BoxConstraints(minWidth: 60),
                child: TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: color,
                    shadows: [
                      Shadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: '',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CurrencyInputFormatter(),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategorySection() {
    // Show only the first 4 categories inline
    final inlineCategories = _categories.take(4).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _showAllCategories,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(inlineCategories.length, (index) {
            final cat = inlineCategories[index];
            final isSelected = _selectedCategory == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = index),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.primary5,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.primary20,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? AppColors.glowMagenta : null,
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: isSelected ? Colors.white : AppColors.primary60,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary5,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary20),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Note (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.edit_note, color: AppColors.primary),
            hintText: 'What was this for?',
            hintStyle: TextStyle(color: AppColors.textMuted),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentArea() {
    if (_attachmentPath != null) {
      // Show image preview with remove button
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary20, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(_attachmentPath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _attachmentPath = null),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary20),
                ),
                child: const Icon(Icons.close, color: AppColors.textPrimary, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    // Empty state — tap to add
    return GestureDetector(
      onTap: _pickAttachment,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.primary5,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary20,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_a_photo,
              size: 32,
              color: AppColors.primary40,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add receipt or photo',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount greater than 0'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final category = _categories[_selectedCategory];
    final currency = widget.currencyProvider.selected;

    final transaction = TransactionItem(
      id: widget.existingTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      currencySymbol: currency.symbol,
      currencyCode: currency.code,
      categoryIcon: category['icon'] as IconData,
      categoryLabel: category['label'] as String,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      attachmentPath: _attachmentPath,
      isIncome: _isIncome,
      createdAt: widget.existingTransaction?.createdAt,
    );

    if (widget.existingTransaction != null) {
      widget.transactionProvider.updateTransaction(transaction);
    } else {
      widget.transactionProvider.addTransaction(transaction);
    }
    
    Navigator.of(context).pop();
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark.withValues(alpha: 0.0),
            AppColors.backgroundDark.withValues(alpha: 0.95),
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _saveTransaction,
          icon: const Icon(Icons.check_circle),
          label: const Text('Save Transaction'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
            shadowColor: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');

    final number = int.parse(digitsOnly);
    final formatted = NumberFormat('#,###').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
