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
  static const int cooldownDuration = 300; // 5 mins

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
      allManhwas = result.manhwas;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('All Manhwas'),
        actions: [
          ElevatedButton(
            onPressed: canRefresh ? _fetchAll : null,
            child: Row(
              children: [
                const Icon(Icons.refresh),
                const SizedBox(width: 8),
                Text(
                  canRefresh
                      ? "Refresh"
                      : "Wait ${formatDuration(cooldownSecondsRemaining)}",
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? GridView.builder(
                itemCount: 18,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (context, index) => buildShimmerCard(),
              )
              : GridView.builder(
                itemCount: allManhwas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (context, index) {
                  final manhwa = allManhwas[index];
                  return ManhwaCard(manhwa: manhwa);
                },
              ),
    );
  }
}
