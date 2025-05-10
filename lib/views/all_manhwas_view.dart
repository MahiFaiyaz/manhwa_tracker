import 'package:flutter/material.dart';
import '../models/manhwa.dart';
import '../models/manhwa_filter.dart';
import '../services/api_services.dart';
import '../widgets/manhwa_card.dart';
import 'dart:async';
import '../widgets/shimmer_card.dart';

class AllManhwasView extends StatefulWidget {
  const AllManhwasView({super.key});

  @override
  State<AllManhwasView> createState() => _AllManhwasViewState();
}

class _AllManhwasViewState extends State<AllManhwasView> {
  List<Manhwa> allManhwas = [];
  bool isLoading = true;
  DateTime? lastRefreshed;
  Timer? cooldownTimer;
  int cooldownSecondsRemaining = 0;
  static const int cooldownDuration = 30; // 5 mins
  final TextEditingController _searchController = TextEditingController();
  List<Manhwa> filteredManhwas = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      isLoading = true;
      lastRefreshed = DateTime.now();
      cooldownSecondsRemaining = cooldownDuration;
    });

    final result = await fetchManhwas(
      filter: ManhwaFilter(),
      onFallback: _showSnackBar,
    );

    setState(() {
      allManhwas = result;
      filteredManhwas = allManhwas;
      isLoading = false;
    });

    cooldownTimer?.cancel(); // cancel any existing one
    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          cooldownSecondsRemaining = 0;
        });
      } else {
        setState(() {
          cooldownSecondsRemaining--;
        });
      }
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

  bool get canRefresh => cooldownSecondsRemaining == 0;

  void _search(String query) {
    final trimmed = query.toLowerCase().trim();
    setState(() {
      if (trimmed.isEmpty) {
        filteredManhwas = allManhwas;
      } else {
        filteredManhwas =
            allManhwas
                .where((m) => m.name.toLowerCase().contains(trimmed))
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('All Manhwas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onPressed: canRefresh ? _fetchAll : null,
              child: Row(
                children: [
                  const Icon(Icons.refresh),
                  const SizedBox(width: 8),
                  Text(
                    canRefresh
                        ? "Refresh"
                        : formatDuration(cooldownSecondsRemaining),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4),
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
