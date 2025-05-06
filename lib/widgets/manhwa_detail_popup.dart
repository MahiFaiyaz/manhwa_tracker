import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/manhwa.dart';
import 'custom_chip.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../services/api_services.dart';

class ManhwaDetailPopup extends StatefulWidget {
  final Manhwa manhwa;
  const ManhwaDetailPopup({super.key, required this.manhwa});

  @override
  State<ManhwaDetailPopup> createState() => _ManhwaDetailPopupState();
}

class _ManhwaDetailPopupState extends State<ManhwaDetailPopup> {
  double _mapRatingToStars(String? rating) {
    switch (rating) {
      case 'Highly Recommended':
        return 5.0;
      case 'Recommended':
        return 4.0;
      case 'Good':
        return 3.0;
      case 'Decent':
        return 2.0;
      case 'Meh':
        return 1.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.manhwa.name;
    final imageUrl = widget.manhwa.imageUrl.replaceFirst('.webp', 'l.webp');
    final synopsis = widget.manhwa.synopsis;
    final rating = widget.manhwa.rating;
    final status = widget.manhwa.status;
    final chapters = switch (widget.manhwa.chapters.toLowerCase()) {
      'more than 100' => '100+',
      'less than 100' => '< 100',
      _ => widget.manhwa.chapters,
    };
    final yearReleased = widget.manhwa.yearReleased;
    final genres = List<String>.from(widget.manhwa.genres);
    final categories = List<String>.from(widget.manhwa.categories);

    const readingStatusLabels = {
      'reading': 'Reading',
      'completed': 'Completed',
      'dropped': 'Dropped',
      'on_hold': 'On Hold',
      'not_read': 'Not Read',
      'to_read': 'To Read',
    };

    String readingLabel(Manhwa manhwa) {
      final label = readingStatusLabels[manhwa.readingStatus] ?? "Not Read";

      final showChapter = [
        "reading",
        "dropped",
        "on_hold",
      ].contains(manhwa.readingStatus);

      return (manhwa.currentChapter > 0 && showChapter)
          ? "$label: Ch ${manhwa.currentChapter}"
          : label;
    }

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
                        child: InkWell(
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Progress Update",
                              barrierColor: Colors.black38, // dark overlay
                              pageBuilder: (_, __, ___) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 6,
                                    sigmaY: 6,
                                  ), // blur strength
                                  child: Center(child: buildEditDialog()),
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: customChip(
                            readingLabel(widget.manhwa),
                            icon: Icons.edit,
                            shimmer: true,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: List.generate(5, (index) {
                              final starRating = _mapRatingToStars(rating);
                              final isFilled = index < starRating;
                              final starIcon = Icon(
                                isFilled ? Icons.star : Icons.star_border,
                                color: Colors.black,
                                size: 24,
                              );
                              return isFilled
                                  ? Shimmer.fromColors(
                                    baseColor: Colors.black,
                                    highlightColor: Colors.deepPurple.shade100,
                                    child: starIcon,
                                  )
                                  : starIcon;
                            }),
                          ),
                        ),
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
