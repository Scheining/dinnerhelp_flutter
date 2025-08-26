import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:go_router/go_router.dart';
import 'package:homechef/core/localization/app_localizations_extension.dart';
import 'package:homechef/screens/home_screen.dart';
import 'package:homechef/screens/search_screen.dart';
import 'package:homechef/screens/bookings_screen.dart';
import 'package:homechef/screens/messages_screen.dart';
import 'package:homechef/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Widget? child;
  
  const MainNavigationScreen({super.key, this.child});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  
  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    
    if (location == '/') {
      return 0;
    } else if (location.startsWith('/search')) {
      return 1;
    } else if (location.startsWith('/bookings')) {
      return 2;
    } else if (location.startsWith('/messages')) {
      return 3;
    } else if (location.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/bookings');
        break;
      case 3:
        context.go('/messages');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  // Define navigation items for awesome_bottom_bar
  List<TabItem> _navigationItems(BuildContext context) => [
    TabItem(
      icon: Icons.home_outlined,
      title: context.l10n.home,
    ),
    TabItem(
      icon: Icons.search_outlined,
      title: context.l10n.search,
    ),
    TabItem(
      icon: Icons.calendar_today_outlined,
      title: context.l10n.bookings,
    ),
    TabItem(
      icon: Icons.chat_bubble_outline,
      title: context.l10n.messages,
    ),
    TabItem(
      icon: Icons.person_outline,
      title: context.l10n.profile,
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
    final currentIndex = _getSelectedIndex(context);
    
    return Scaffold(
      extendBody: true, // Allow body content to extend behind navigation bar
      body: widget.child,
      bottomNavigationBar: BottomBarInspiredOutside(
        items: _navigationItems(context),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF252325), // Unified dark color for navigation
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        colorSelected: _getSelectedIconColor(context),
        indexSelected: currentIndex,
        onTap: (int index) => _onItemTapped(context, index),
        top: -32, // Float selected item above the navigation bar
        animated: true,
        itemStyle: ItemStyle.circle,
        chipStyle: ChipStyle(
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          background: _getSelectedBackgroundColor(context),
        ),
        iconSize: 24, // Standardize icon size
        height: 40, // Reduced height to minimize bottom space
        pad: 0, // Remove padding
      ),
    );
  }
}