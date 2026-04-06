import 'package:flutter/material.dart';
import 'package:go_grabit/home/home.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:go_grabit/screens/food_offers_screen.dart';
import 'package:go_grabit/screens/map_screen.dart';
import 'package:go_grabit/profile/profile_screen.dart';
import 'package:go_grabit/search_screen.dart';

/// This is the main screen of the app which contains the persistent bottom navigation bar.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // The list of pages to be displayed in the body.
  final List<Widget> _pages = [
    const Home(),
    const FoodOffersScreen(),
    const MapScreen(),
    // TODO: Replace with your actual Search screen
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves the state of each page when switching tabs.
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: const Color(0xffF2762E),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.local_offer),
            title: const Text("Offers"),
            selectedColor: const Color(0xffF2762E),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.location_on),
            title: const Text("Map"),
            selectedColor: const Color(0xffF2762E),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.search),
            title: const Text("Search"),
            selectedColor: const Color(0xffF2762E),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person_outline),
            title: const Text("Profile"),
            selectedColor: const Color(0xffF2762E),
          ),
        ],
      ),
    );
  }
}
