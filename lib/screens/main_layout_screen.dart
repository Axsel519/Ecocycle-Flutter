import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import 'home_screen.dart';
import 'pickup_screen.dart';
import 'scan_screen.dart';
import 'rewards_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  String _authScreen = '';
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = jsonDecode(userStr);
      setState(() {
        _userRole = user['role'] ?? 'user';
      });
    } else {
      setState(() {
        _userRole = 'user';
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _authScreen = '';
    });
  }

  void _openLogin() => setState(() => _authScreen = 'login');
  void _openRegister() => setState(() => _authScreen = 'register');
  void _closeAuth() => setState(() => _authScreen = '');

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _userRole == 'admin';

    Widget currentBody;
    if (_authScreen == 'login') {
      currentBody = LoginScreen(
        onHeaderProfilePressed: _openLogin,
        onNavigateToRegister: _openRegister,
        onLoginSuccess: () {
          _checkRole();
          _closeAuth();
          _onTabTapped(0);
        },
      );
    } else if (_authScreen == 'register') {
      currentBody = RegisterScreen(
        onHeaderProfilePressed: _openLogin,
        onNavigateToLogin: _openLogin,
        onRegisterSuccess: () {
          _checkRole();
          _closeAuth();
          _onTabTapped(0);
        },
      );
    } else {
      final List<Widget> pages = [
        HomeScreen(
          onScanPressed: () => _onTabTapped(2),
          onPickupPressed: () => _onTabTapped(1),
          onProfilePressed: _openLogin,
          onUserDataChanged: _checkRole,
        ),
        PickupScreen(onHeaderProfilePressed: _openLogin, onUserDataChanged: _checkRole),
        ScanScreen(onHeaderProfilePressed: _openLogin, onUserDataChanged: _checkRole),
        RewardsScreen(onHeaderProfilePressed: _openLogin, onUserDataChanged: _checkRole),
        if (isAdmin)
          DashboardScreen(
            onScanWaste: () => _onTabTapped(2),
            onHeaderProfilePressed: _openLogin,
            onUserDataChanged: _checkRole,
          ),
      ];

      currentBody = IndexedStack(
        index: _currentIndex >= pages.length ? 0 : _currentIndex,
        children: pages,
      );
    }

    return Scaffold(
      body: currentBody,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex >= (isAdmin ? 5 : 4) ? 0 : _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping),
              label: 'Pickup',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner, size: 28),
              label: 'Scan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_outlined),
              activeIcon: Icon(Icons.card_giftcard),
              label: 'Rewards',
            ),
            if (isAdmin)
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
          ],
        ),
      ),
    );
  }
}