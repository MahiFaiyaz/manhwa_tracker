import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'login_signup_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manhwa.dart';
import '../services/api_services.dart';
import '../widgets/manhwa_card.dart';
import '../widgets/shimmer_card.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  bool? _isLoggedIn;
  String? userEmail;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Manhwa> filteredManhwas = [];
  List<Manhwa> libraryManhwas = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await checkLoginStatus();
    if (_isLoggedIn == true) {
      await fetchLibrary();
      await loadUserEmail();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> checkLoginStatus() async {
    final loggedIn = await isUserLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

  Future<void> loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email');
    });
  }

  void handleLogout() async {
    await logoutUser();
    setState(() => _isLoggedIn = false);
  }

  Future<void> fetchLibrary() async {
    try {
      final result = await fetchUserProgress(
        onFallback: (msg) => _showSnackBar(msg),
      );
      setState(() {
        libraryManhwas = result;
        filteredManhwas = libraryManhwas;
        isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Failed to load your library.");
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _search(String query) {
    final trimmed = query.toLowerCase().trim();
    setState(() {
      if (trimmed.isEmpty) {
        filteredManhwas = libraryManhwas;
      } else {
        filteredManhwas =
            libraryManhwas
                .where((m) => m.name.toLowerCase().contains(trimmed))
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn!) {
      return LoginSignupView(
        onLoginSuccess: () {
          setState(() => _isLoggedIn = true);
          fetchLibrary(); // re-fetch after login
          loadUserEmail();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 44),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              onSelected: (value) {
                if (value == 'logout') handleLogout();
              },
              itemBuilder:
                  (context) => [
                    if (userEmail != null)
                      PopupMenuItem<String>(
                        height: 16,
                        enabled: false,
                        child: Text(
                          userEmail!,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    const PopupMenuItem<String>(
                      enabled: false,
                      height: 1,
                      padding: EdgeInsets.zero,
                      child: Divider(thickness: 2),
                    ),
                    const PopupMenuItem<String>(
                      height: 16,
                      value: 'logout',
                      child: Text('Log Out'),
                    ),
                  ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search titles...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? GridView.builder(
                        itemCount: 18,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 2 / 3,
                            ),
                        itemBuilder: (context, index) => buildShimmerCard(),
                      )
                      : GridView.builder(
                        itemCount: filteredManhwas.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 2 / 3,
                            ),
                        itemBuilder: (context, index) {
                          final manhwa = filteredManhwas[index];
                          return ManhwaCard(manhwa: manhwa);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
