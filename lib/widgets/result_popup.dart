import 'package:flutter/material.dart';
import 'manhwa_card.dart'; // adjust import path

class ResultPopup extends StatelessWidget {
  const ResultPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    final manhwaList = List.generate(20, (index) {
      return {
        "name": "Manhwa $index",
        "image_url": "https://cdn.myanimelist.net/images/manga/2/129069.jpg",
      };
    });

    return SizedBox(
      height: height * 0.83,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          itemCount: manhwaList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2 / 3,
          ),
          itemBuilder: (context, index) {
            final manhwa = manhwaList[index];
            return ManhwaCard(
              title: manhwa["name"] ?? "",
              imageUrl: manhwa["image_url"] ?? "",
            );
          },
        ),
      ),
    );
  }
}
