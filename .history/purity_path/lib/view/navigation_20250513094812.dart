import 'package:flutter/material.dart';
import 'package:purity_path/utils/consts.dart';
import 'navigations/objectifs.dart';
import 'navigations/goals.dart';
//import 'navigations/home.dart';
import 'navigations/home2.dart';
import 'navigations/lessons.dart';
import 'navigations/profile.dart';

// Using AppConstants from previous code
class AppConstants {
  static const primaryColor = Color(0xFF3F51B5);
  static const accentColor = Color(0xFF00BCD4);
  static const cardShadow = Color(0x11000000);
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  late PageController _pageController;

  static const List<Widget> _pages = [
    Home(),
    Lessons(),
    GoalsPage(),
    Profile(),
   
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          physics: const ClampingScrollPhysics(),
          children: _pages.map((page) => _PageTransition(child: page)).toList(),
        ),
        bottomNavigationBar: _CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const _CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppConstants.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Color(AppColors.primary),
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        elevation: 0,
   items: const [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded), // softer, friendlier look
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.menu_book_outlined),
    activeIcon: Icon(Icons.menu_book), // more intuitive for lessons
    label: 'Lessons',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.flag_outlined),
    activeIcon: Icon(Icons.flag), // clearer symbol for "objectives"
    label: 'Goals',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.account_circle_outlined),
    activeIcon: Icon(Icons.account_circle), // more expressive than person
    label: 'Profile',
  ),
],
 ),
    );
  }
}

class _PageTransition extends StatelessWidget {
  final Widget child;

  const _PageTransition({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}