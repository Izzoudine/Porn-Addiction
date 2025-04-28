import 'package:flutter/material.dart';
import 'navigations/history.dart';
import 'navigations/home.dart';
import 'navigations/lessons.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<Navigation> {
  int _selectedIndex = 0;
  late PageController _pageController; // PageController to control page swiping

  static const List<Widget> _pages = [Home(), Lessons(), History()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Jump to the selected page
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController, // Use the controller for page navigation
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index; // Update selected index on swipe
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color.fromARGB(255, 26, 187, 31),
          selectedItemColor: const Color.fromARGB(255, 255, 49, 49),
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          items: [
            const BottomNavigationBarItem(
              /*Icons.home_filled

Icons.home_outlined

Icons.roofing

Icons.cottage */
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              //menu_book,auto_stories,book,psychology,lightbulb
              icon: Icon(Icons.school),
              label: 'Lessons',
            ),

            const BottomNavigationBarItem(
              // access_time
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
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
