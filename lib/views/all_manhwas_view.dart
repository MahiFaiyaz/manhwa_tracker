import 'package:flutter/material.dart';
import '../models/manhwa.dart';
import '../models/manhwa_filter.dart';
import '../services/api_services.dart';
import '../widgets/manhwa_card.dart';
import 'dart:async';
import 'package:manhwa_tracker/dialog/loading_screen.dart';

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
  static const int cooldownDuration = 10;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      LoadingScreen.instance().show(
        context: context,
        text: "Loading Manhwas...",
      );
      await _fetchAll();
    });
  }

  Future<void> _fetchAll() async {
    setState(() {
      isLoading = true;
      lastRefreshed = DateTime.now();
      cooldownSecondsRemaining = cooldownDuration;
    });
    try {
      final result = await fetchManhwas(
        filter: ManhwaFilter(),
        onFallback: _showSnackBar,
      );

      setState(() {
        allManhwas = result;
        isLoading = false;
      });

      cooldownTimer?.cancel();
      cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (cooldownSecondsRemaining <= 1) {
          timer.cancel();
          setState(() => cooldownSecondsRemaining = 0);
        } else {
          setState(() => cooldownSecondsRemaining--);
        }
      });
    } catch (e) {
      _showSnackBar("Failed to load manhwas.");
      setState(() => isLoading = false);
    } finally {
      LoadingScreen.instance().hide();
    }
  }

  bool get canRefresh => cooldownSecondsRemaining == 0;

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text.trim().toLowerCase();
    final visibleManhwas =
        searchQuery.isEmpty
            ? allManhwas
            : allManhwas
                .where((m) => m.name.toLowerCase().contains(searchQuery))
                .toList();

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
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.deepPurple.shade300,
                side: BorderSide(
                  color:
                      canRefresh
                          ? Colors.deepPurple.shade300
                          : Colors.transparent,
                  width: 2,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                minimumSize: const Size(0, 0),
              ),
              onPressed:
                  canRefresh
                      ? () {
                        LoadingScreen.instance().show(
                          context: context,
                          text: "Loading Manhwas...",
                        );
                        _fetchAll();
                      }
                      : null,
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
                onChanged: (_) => setState(() {}), // rebuild to trigger filter
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
            if (visibleManhwas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Text(
                  "No results found.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  itemCount: visibleManhwas.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2 / 3,
                  ),
                  itemBuilder: (context, index) {
                    final manhwa = visibleManhwas[index];
                    return ManhwaCard(key: ValueKey(manhwa.id), manhwa: manhwa);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
