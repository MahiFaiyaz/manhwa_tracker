import 'package:flutter/material.dart';
import 'manhwa_card.dart';
import '../models/manhwa.dart';

class ResultPopup extends StatelessWidget {
  final List<Manhwa> manhwas;
  const ResultPopup({super.key, required this.manhwas});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.83,
      child: Scrollbar(
        radius: const Radius.circular(8),
        thickness: 4,
        child: Padding(
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
              final manhwa = manhwas[index];
              return ManhwaCard(manhwa: manhwa);
            },
          ),
        ),
      ),
    );
  }
}
