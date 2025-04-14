import 'package:flutter/material.dart';
import 'package:manhwa_tracker/services/api_services.dart';
import 'manhwa_card.dart';

class ResultPopup extends StatelessWidget {
  const ResultPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: height * 0.83,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchManhwas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No results found."));
          }

          final manhwas = snapshot.data!;

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
                return ManhwaCard(
                  title: manhwa["name"] ?? "",
                  imageUrl: manhwa["image_url"] ?? "",
                );
              },
            ),
          );
        },
      ),
    );
  }
}
