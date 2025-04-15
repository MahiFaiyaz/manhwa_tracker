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
    final chapters = switch (manhwa.chapters.toLowerCase()) {
      'more than 100' => '100+',
      'less than 100' => '< 100',
      _ => manhwa.chapters,
    };
    final yearReleased = manhwa.yearReleased;
    final genres = List<String>.from(manhwa.genres);
    final categories = List<String>.from(manhwa.categories);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.9,
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
                        child: Column(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _chip("Status: $status", dark: true),
                                _chip("Chapters: $chapters", dark: true),
                                _chip("Year: $yearReleased", dark: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _chip("Rating: $rating", isRating: true),
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

  Color _getRatingColor(String label) {
    switch (label.toLowerCase()) {
      case 'rating: highly recommended':
        return Colors.green.shade800;
      case 'rating: recommended':
        return Colors.green.shade600;
      case 'rating: good':
        return Colors.blue.shade400;
      case 'rating: decent':
        return Colors.grey.shade500;
      case 'rating: meh':
        return Colors.red.shade400;
      case 'rating: n/a':
        return Colors.black;
      default:
        return Colors.black; // fallback to default chip color
    }
  }

  Widget _chip(String label, {bool dark = false, bool isRating = false}) {
    final bgColor =
        isRating
            ? _getRatingColor(label)
            : (dark ? Colors.black26 : Colors.purple[100]);

    final textColor = dark ? Colors.white : Colors.black;

    return Chip(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
