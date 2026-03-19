import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'providers/currency_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/breakdown_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final CurrencyProvider _currencyProvider = CurrencyProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _openAddTransaction() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionScreen(
              currencyProvider: _currencyProvider,
              transactionProvider: _transactionProvider,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_currencyProvider, _transactionProvider]),
      builder: (context, _) {
        final screens = [
          DashboardScreen(
            transactionProvider: _transactionProvider,
            currencyProvider: _currencyProvider,
            onViewAllHistory: () => _onTabChanged(2),
          ),
          BreakdownScreen(
            transactionProvider: _transactionProvider,
            currencyProvider: _currencyProvider,
            onCategoryTap: (categoryName, month) {
              _transactionProvider.setCategoryFilter(categoryName);
              _transactionProvider.setMonthFilter(month);
              _onTabChanged(2);
            },
          ),
          HistoryScreen(
            transactionProvider: _transactionProvider,
            currencyProvider: _currencyProvider,
          ),
          SettingsScreen(currencyProvider: _currencyProvider),
        ];

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppColors.glowMagentaStrong,
        ),
        child: FloatingActionButton(
          onPressed: _openAddTransaction,
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home, 'HOME'),
              _buildNavItem(1, Icons.bar_chart, 'INSIGHTS'),
              const SizedBox(width: 56), // Space for FAB
              _buildNavItem(2, Icons.history, 'HISTORY'),
              _buildNavItem(3, Icons.settings, 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
