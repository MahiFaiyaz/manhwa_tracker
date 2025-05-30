import 'package:flutter/material.dart';
import 'package:manhwa_tracker/dialog/loading_screen.dart';
import '../services/auth_services.dart';
import 'login_signup_view.dart';
import '../models/manhwa.dart';
import '../services/api_services.dart';
import '../widgets/manhwa_card.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => LibraryViewState();
}

class LibraryViewState extends State<LibraryView> {
  bool? _isLoggedIn;
  String? userEmail;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Manhwa> libraryManhwas = [];
  final ScrollController _scrollController = ScrollController();
  Map<String, GlobalKey> sectionKeys = {};
  String selectedStatus = 'to_read';
  String _searchQuery = '';
  final ScrollController _chipScrollController = ScrollController();
  final Map<String, GlobalKey> chipKeys = {};
  final GlobalKey _chipListKey = GlobalKey();
  bool _isJumpingToStatus = false;

  final statusOrder = [
    'to_read',
    'reading',
    'completed',
    'dropped',
    'on_hold',
    'not_read',
  ];
  final statusLabels = {
    'to_read': 'To Read',
    'reading': 'Reading',
    'completed': 'Completed',
    'dropped': 'Dropped',
    'on_hold': 'On Hold',
    'not_read': 'Not Read',
  };
  Map<String, List<Manhwa>> manhwasByStatus = {};

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final loggedIn = await isUserLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
    if (loggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        LoadingScreen.instance().show(
          context: context,
          text: "Loading Library...",
        );
        await _loadUserEmail();
        await _fetchLibrary();
      });
    }
  }

  Future<void> _loadUserEmail() async {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email;
    setState(() {
      userEmail = email;
    });
  }

  void refreshLibrary() {
    _fetchLibrary();
  }

  Future<void> _fetchLibrary() async {
    setState(() {
      isLoading = true;
    });
    LoadingScreen.instance().show(context: context, text: 'Loading Library...');
    try {
      final result = await fetchUserProgress();
      result.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      manhwasByStatus = {
        for (var status in statusOrder)
          status: result.where((m) => m.readingStatus == status).toList(),
      };

      // Determine the first non-empty section
      final firstNonEmpty = manhwasByStatus.entries.firstWhere(
        (entry) => entry.value.isNotEmpty,
        orElse: () => const MapEntry('not_read', []),
      );

      setState(() {
        libraryManhwas = result;
        isLoading = false;
        selectedStatus = firstNonEmpty.key;
      });

      // Jump to that section after the widgets build
      Future.delayed(const Duration(milliseconds: 100), () {
        _jumpToStatus(selectedStatus);
      });
    } catch (e) {
      _showSnackBar("Failed to load your library.");
      setState(() => isLoading = false);
    } finally {
      LoadingScreen.instance().hide();
    }
  }

  void _handleScroll() {
    for (final status in statusOrder) {
      final key = sectionKeys[status];
      if (key == null) continue;

      final context = key.currentContext;
      if (context == null) continue;

      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.localToGlobal(Offset.zero).dy < 186) {
        if (!_isJumpingToStatus && selectedStatus != status) {
          setState(() => selectedStatus = status);

          // Scroll chip into view
          Future.delayed(Duration.zero, () {
            final renderBox =
                chipKeys[status]?.currentContext?.findRenderObject()
                    as RenderBox?;
            final scrollBox =
                _chipListKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null && scrollBox != null) {
              final chipOffset =
                  renderBox.localToGlobal(Offset.zero, ancestor: scrollBox).dx;
              final chipWidth = renderBox.size.width;
              final scrollViewWidth = scrollBox.size.width;

              final targetOffset =
                  _chipScrollController.offset +
                  chipOffset +
                  chipWidth / 2 -
                  scrollViewWidth / 2;
              final clamped = targetOffset.clamp(
                0.0,
                _chipScrollController.position.maxScrollExtent,
              );

              _chipScrollController.animateTo(
                clamped,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    }
  }

  void _jumpToStatus(String status) {
    final key = sectionKeys[status];

    // Begin jump: activate flag
    setState(() {
      selectedStatus = status;
      _isJumpingToStatus = true;
    });

    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        alignment: -0.02,
      );
    }

    // Center the chip in view
    Future.delayed(Duration.zero, () {
      final renderBox =
          chipKeys[status]?.currentContext?.findRenderObject() as RenderBox?;
      final scrollBox =
          _chipListKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && scrollBox != null) {
        final chipOffset =
            renderBox.localToGlobal(Offset.zero, ancestor: scrollBox).dx;
        final chipWidth = renderBox.size.width;
        final scrollViewWidth = scrollBox.size.width;

        final targetOffset =
            _chipScrollController.offset +
            chipOffset +
            chipWidth / 2 -
            scrollViewWidth / 2;
        final clamped = targetOffset.clamp(
          0.0,
          _chipScrollController.position.maxScrollExtent,
        );

        _chipScrollController.animateTo(
          clamped,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }

      // Reset flag after scroll finishes
      Future.delayed(const Duration(milliseconds: 350), () {
        _isJumpingToStatus = false;
      });
    });
  }

  String formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          _fetchLibrary();
          _loadUserEmail();
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Library'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.deepPurple.shade300,
                side: BorderSide(
                  color:
                      isLoading
                          ? Colors.transparent
                          : Colors.deepPurple.shade300,
                  width: 2,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                minimumSize: const Size(0, 0),
              ),
              onPressed: isLoading ? null : _fetchLibrary,
              child: Row(
                children: [
                  const Icon(Icons.refresh),
                  const SizedBox(width: 8),
                  Text("Refresh"),
                ],
              ),
            ),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 44),
            child: Icon(
              Icons.person,
              color: Colors.deepPurple.shade300,
              size: 40,
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                LoadingScreen.instance().show(
                  context: context,
                  text: 'Logging out...',
                );
                await Supabase.instance.client.auth.signOut();
                LoadingScreen.instance().hide();
                if (mounted) {
                  setState(() => _isLoggedIn = false);
                  _showSnackBar("Logged out successfully.");
                }
              }
            },
            itemBuilder:
                (context) => [
                  if (userEmail != null)
                    PopupMenuItem(
                      enabled: false,
                      height: 16,
                      child: Text(
                        userEmail!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  const PopupMenuItem(
                    enabled: false,
                    height: 1,
                    child: Divider(thickness: 2),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    height: 16,
                    child: Text('Log Out'),
                  ),
                  // const PopupMenuItem(
                  //   value: 'auth_token',
                  //   height: 16,
                  //   child: Text('Get auth'),
                  // ),
                  // const PopupMenuItem(
                  //   value: 'refresh_token',
                  //   height: 16,
                  //   child: Text('get refresh'),
                  // ),
                ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 4,
              bottom: 8,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.only(bottom: 4),
            height: 40,
            child: ListView(
              key: _chipListKey, // ✅ assign key here
              controller: _chipScrollController,
              scrollDirection: Axis.horizontal,
              children:
                  manhwasByStatus.entries
                      .where((entry) {
                        final filtered =
                            entry.value
                                .where(
                                  (m) => m.name.toLowerCase().contains(
                                    _searchQuery,
                                  ),
                                )
                                .toList();
                        return filtered.isNotEmpty;
                      })
                      .map((entry) {
                        final status = entry.key;
                        final label = statusLabels[status]!;
                        final isSelected = selectedStatus == status;
                        final chipKey = chipKeys.putIfAbsent(
                          status,
                          () => GlobalKey(),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            key: chipKey, // ✅ assign key here
                            label: Text(label),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (_) => _jumpToStatus(status),
                            selectedColor: Colors.deepPurple.shade300,
                          ),
                        );
                      })
                      .toList(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (manhwasByStatus.values.every((list) => list.isEmpty))
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Text(
                          "Library is empty. Start tracking!",
                          style: TextStyle(color: Colors.white70, fontSize: 32),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...manhwasByStatus.entries.map((entry) {
                      final status = entry.key;
                      final key = GlobalKey();
                      final items =
                          entry.value
                              .where(
                                (m) =>
                                    m.name.toLowerCase().contains(_searchQuery),
                              )
                              .toList();

                      if (items.isEmpty) return const SizedBox.shrink();
                      sectionKeys[status] = key;

                      return Column(
                        key: key,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              statusLabels[status]!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GridView.builder(
                            itemCount: items.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 2 / 3,
                                ),
                            itemBuilder: (context, index) {
                              return ManhwaCard(
                                manhwa: items[index],
                                onLibraryUpdate: _fetchLibrary,
                                showLibraryBadge: false,
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
