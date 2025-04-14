import 'package:flutter/material.dart';
import '../models/manhwa.dart';

class ManhwaDetailPopup extends StatelessWidget {
  final Manhwa manhwa;

  const ManhwaDetailPopup({super.key, required this.manhwa});

  @override
  Widget build(BuildContext context) {
    final title = manhwa.name;
    final imageUrl = manhwa.imageUrl.replaceFirst('.webp', 'l.webp');
    final synopsis = manhwa.synopsis;
    final rating = manhwa.rating;
    final status = manhwa.status;
    final genres = List<String>.from(manhwa.genres ?? []);
    final categories = List<String>.from(manhwa.categories ?? []);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.83,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Scrollbar(
          radius: const Radius.circular(8),
          thickness: 4,
          thumbVisibility: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54, // subtle dark overlay
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _chip("Rating: $rating", dark: true),
                          const SizedBox(height: 4), // spacing here
                          _chip("Status: $status", dark: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Genres:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: genres.map(_chip).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Categories:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: categories.map(_chip).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Synopsis:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(synopsis, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, {bool dark = false}) {
    return Chip(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: dark ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: dark ? Colors.black26 : Colors.purple[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
