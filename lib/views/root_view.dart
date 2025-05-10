import 'package:flutter/material.dart';
import 'home_view.dart';
import 'library_view.dart';
import 'all_manhwas_view.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  int _currentIndex = 1; // 0: Library, 1: Home, 2: All Manhwas
  final GlobalKey<LibraryViewState> _libraryKey = GlobalKey<LibraryViewState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      LibraryView(key: _libraryKey),
      const HomeView(),
      const AllManhwasView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0 && _currentIndex != 0) {
              // Refresh the library view when navigating to it
              _libraryKey.currentState?.refreshLibrary();
            }
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.black,
          selectedItemColor: Colors.deepPurple.shade300,
          unselectedItemColor: Colors.grey.shade500,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Library',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              label: 'All',
            ),
          ],
        ),
      ),
    );
  }
}
