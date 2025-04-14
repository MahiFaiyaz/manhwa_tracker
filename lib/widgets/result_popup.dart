import 'package:flutter/material.dart';
import 'package:manhwa_tracker/widgets/shimmer_card.dart';
import 'manhwa_card.dart';
import 'package:manhwa_tracker/services/api_services.dart';

class ResultPopup extends StatelessWidget {
  final List<String> genres;
  final List<String> categories;
  final List<String> status;
  final List<String> ratings;

  const ResultPopup({
    super.key,
    required this.genres,
    required this.categories,
    required this.status,
    required this.ratings,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: height * 0.83,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchManhwas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ✨ Show shimmer placeholders
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.builder(
                itemCount: 15,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (context, index) => buildShimmerCard(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final manhwas = snapshot.data ?? [];

          if (manhwas.isEmpty) {
            return const Center(child: Text("No results found."));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GridView.builder(
              itemCount: manhwas.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2 / 3,
              ),
              itemBuilder: (context, index) {
                final manhwa = manhwas[index]["manhwa"];
                return ManhwaCard(manhwa: manhwa);
              },
            ),
          );
        },
      ),
    );
  }
}
