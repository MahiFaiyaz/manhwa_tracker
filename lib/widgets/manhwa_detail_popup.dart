import 'package:flutter/material.dart';
import '../models/manhwa.dart';
import 'custom_chip.dart';

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

    const readingStatusLabels = {
      'reading': 'Reading',
      'completed': 'Completed',
      'dropped': 'Dropped',
      'on_hold': 'On Hold',
      'not_read': 'Not Read',
      'to_read': 'To Read',
    };

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
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                customChip("Status: $status", dark: true),
                                customChip("Chapters: $chapters", dark: true),
                                customChip("Year: $yearReleased", dark: true),
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
                        child: customChip("Rating: $rating", dark: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        children: [
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              customChip("Rating: $rating"),
                              customChip(
                                "Reading: ${readingStatusLabels[manhwa.readingStatus]}",
                              ),
                              if (manhwa.currentChapter > 0)
                                customChip("Chapter: ${manhwa.currentChapter}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Genres:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: genres.map(customChip).toList(),
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
                  children: categories.map(customChip).toList(),
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
}
