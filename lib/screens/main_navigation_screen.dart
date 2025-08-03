import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:homechef/screens/home_screen.dart';
import 'package:homechef/screens/search_screen.dart';
import 'package:homechef/screens/bookings_screen.dart';
import 'package:homechef/screens/messages_screen.dart';
import 'package:homechef/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    BookingsScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  // Define navigation items for awesome_bottom_bar
  List<TabItem> get _navigationItems => [
    const TabItem(
      icon: Icons.home_outlined,
      title: 'Home',
    ),
    const TabItem(
      icon: Icons.search_outlined,
      title: 'Search',
    ),
    const TabItem(
      icon: Icons.calendar_today_outlined,
      title: 'Bookings',
    ),
    const TabItem(
      icon: Icons.chat_bubble_outline,
      title: 'Messages',
    ),
    const TabItem(
      icon: Icons.person_outline,
      title: 'Profile',
    ),
  ];

  // Get the background color for selected/highlighted buttons based on theme
  Color _getSelectedBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.light) {
      // Light mode: Use primary teal color for background
      return Theme.of(context).colorScheme.primary; // #79CBC2
    } else {
      // Dark mode: Use Baltic Sea Dark color for background
      return const Color(0xFF292E31); // #292E31
    }
  }

  // Get the icon color for selected/highlighted buttons based on theme
  Color _getSelectedIconColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.light) {
      // Light mode: Use white icon on teal background
      return Colors.white;
    } else {
      // Dark mode: Use primary teal icon on dark background
      return Theme.of(context).colorScheme.primary; // #79CBC2
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body content to extend behind navigation bar
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.transparent, // Make background transparent
        child: SafeArea(
          child: BottomBarInspiredOutside(
            items: _navigationItems,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Match theme background
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            colorSelected: _getSelectedIconColor(context),
            indexSelected: _currentIndex,
            onTap: (int index) => setState(() {
              _currentIndex = index;
            }),
            top: -25, // Creates the deep outside effect
            animated: true,
            itemStyle: ItemStyle.circle,
            chipStyle: ChipStyle(
              notchSmoothness: NotchSmoothness.verySmoothEdge,
              background: _getSelectedBackgroundColor(context),
            ),
          ),
        ),
      ),
    );
  }
}