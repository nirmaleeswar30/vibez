// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:vibe_together_app/screens/conversations_screen.dart';
import 'package:vibe_together_app/screens/create_post_screen.dart';
import 'package:vibe_together_app/screens/create_vibe_screen.dart'; // We will create this
import 'package:vibe_together_app/screens/groups_screen.dart';
import 'package:vibe_together_app/screens/search_screen.dart';
import 'package:vibe_together_app/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Start on the Home tab
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  // This function will show a choice dialog when the central button is pressed
  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('Create a Post'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
                  }),
              ListTile(
                leading: const Icon(Icons.celebration),
                title: const Text('Create a Vibe (Event)'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateVibeScreen())); // We'll create this screen
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swiping
        children: const [
          HomeScreen(), // Index 0: Home
          SearchScreen(),      // Index 1: Search
          Placeholder(),       // Index 2: This is a dummy for the center button
          GroupsScreen(),      // Index 3: Groups
          ConversationsScreen(), // Index 4: Chats
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.home, index: 0),
            _buildNavItem(icon: Icons.search, index: 1),
            // The center button which triggers the modal
            IconButton(
              icon: const Icon(Icons.vibration, size: 30.0),
              onPressed: () => _showCreateOptions(context),
              tooltip: "Vibe Together",
            ),
            _buildNavItem(icon: Icons.group_work, index: 3),
            _buildNavItem(icon: Icons.chat_bubble, index: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    return IconButton(
      icon: Icon(
        icon,
        color: _currentIndex == index ? Theme.of(context).primaryColor : Colors.grey,
      ),
      onPressed: () => _onTabTapped(index),
    );
  }
}