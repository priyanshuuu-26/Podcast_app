import 'package:flutter/material.dart';
import 'package:podcast_app/screens/category_tab/categories.dart';
import 'package:podcast_app/screens/favourites.dart';
import 'package:podcast_app/screens/home_tab/home_screen.dart';
import 'package:podcast_app/screens/profile_tab/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = const [
    HomeScreen(),
    CategoriesPage(),
    FavoritesPage(), 
    ProfilePage(),    
  ];
  
  // Initialized the PageController
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  // Dispose the controller when the screen is removed
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // When a tab is tapped tell the controller to jump to that page
  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Podcast App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        // 4. When the user swipes, update the selected index
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 0, 92, 135),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}