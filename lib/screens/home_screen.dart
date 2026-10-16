import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'cart_screen.dart';
import 'chat_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';

import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    this.username = '',
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageController
      _pageController =
      PageController();

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading:
              false,
          elevation: 2,
          title: _selectedIndex == 0
              ? Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  scale: 11.sp,
                )
              : CustomText(
                  text: _selectedIndex == 1
                      ? 'Chat'
                      : _selectedIndex == 2
                          ? 'Profile'
                          : 'Home',
                  fontSize: 20.sp,
                  fontWeight:
                      FontWeight.w600,
                ),
          actions: [
            IconButton(
              tooltip: 'Cart',
              icon: Icon(
                Icons.shopping_cart_outlined,
                size: 24.sp,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (
                      context,
                    ) {
                      return const CartScreen();
                    },
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Settings',
              icon: Icon(
                Icons.settings,
                size: 24.sp,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/settings',
                );
              },
            ),
          ],
        ),
        body: PageView(
          physics:
              const NeverScrollableScrollPhysics(),
          controller:
              _pageController,
          onPageChanged: (page) {
            setState(() {
              _selectedIndex =
                  page;
            });
          },
          children: const [
            ProductScreen(),
            ChatScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar:
            BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex:
              _selectedIndex,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.shop_2,
              ),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat_bubble,
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onTappedBar(
    int value,
  ) {
    setState(() {
      _selectedIndex = value;
    });

    _pageController.jumpToPage(
      value,
    );
  }
}