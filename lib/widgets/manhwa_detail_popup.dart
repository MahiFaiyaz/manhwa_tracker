import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/manhwa.dart';
import 'custom_chip.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../services/api_services.dart';
import '../dialog/loading_screen.dart';

class ManhwaDetailPopup extends StatefulWidget {
  final Manhwa manhwa;
  const ManhwaDetailPopup({super.key, required this.manhwa});

  @override
  State<ManhwaDetailPopup> createState() => _ManhwaDetailPopupState();
}

class _ManhwaDetailPopupState extends State<ManhwaDetailPopup> {
  late Manhwa localManhwa;
  @override
  void initState() {
    super.initState();
    localManhwa = widget.manhwa;
  }

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
    final title = localManhwa.name;
    final imageUrl = localManhwa.imageUrl.replaceFirst('.webp', 'l.webp');
    final synopsis = localManhwa.synopsis;
    final rating = localManhwa.rating;
    final status = localManhwa.status;
    final chapters = switch (localManhwa.chapters.toLowerCase()) {
      'more than 100' => '100+',
      'less than 100' => '< 100',
      _ => localManhwa.chapters,
    };
    final yearReleased = localManhwa.yearReleased;
    final genres = List<String>.from(localManhwa.genres);
    final categories = List<String>.from(localManhwa.categories);

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

    Widget buildEditDialog({required void Function(Manhwa) onSave}) {
      String readingStatus =
          localManhwa.readingStatus == 'not_read'
              ? 'reading'
              : localManhwa.readingStatus;
      int currentChapter = localManhwa.currentChapter;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black.withAlpha((0.8 * 255).toInt()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Update Progress",
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.black.withAlpha((0.95 * 255).toInt()),
                  decoration: const InputDecoration(
                    labelText: 'Reading Status',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(),
                  ),
                  value: readingStatus,
                  items:
                      readingStatusLabels.entries
                          .where((entry) => entry.key != 'not_read')
                          .map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          })
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => readingStatus = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: currentChapter.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      4,
                    ), // max 4 digits → up to 9999
                  ],

                  decoration: const InputDecoration(
                    labelText: 'Current Chapter',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) setState(() => currentChapter = parsed);
                  },
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.black.withAlpha(
                              (0.8 * 255).toInt(),
                            ),
                            title: const Text(
                              "Delete Progress",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              "Are you sure you want to delete this from your library?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed != true) return; // cancel

                      LoadingScreen.instance().show(
                        context: context,
                        text: "Deleting progress...",
                      );
                      final success = await deleteProgress(localManhwa.id);

                      if (success) {
                        setState(() {
                          localManhwa = localManhwa.copyWith(
                            readingStatus: 'not_read',
                            currentChapter: 0,
                          );
                        });
                        LoadingScreen.instance().hide();
                        if (context.mounted) {
                          Navigator.pop(context, {
                            'readingStatus': readingStatus,
                            'currentChapter': currentChapter,
                          });
                        }
                        onSave(localManhwa);
                      } else {
                        LoadingScreen.instance().hide();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to delete progress"),
                            ),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Delete"),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Show loading screen
                      LoadingScreen.instance().show(
                        context: context,
                        text: "Updating progress...",
                      );

                      // Make api call
                      final success = await submitProgress(
                        manhwaId: localManhwa.id,
                        chapter: currentChapter,
                        readingStatus: readingStatus,
                      );
                      // if success, update and close loading screen and popup
                      if (success) {
                        setState(() {
                          localManhwa = localManhwa.copyWith(
                            readingStatus: readingStatus,
                            currentChapter: currentChapter,
                          );
                        });
                        LoadingScreen.instance().hide();
                        if (context.mounted) {
                          Navigator.pop(context, {
                            'readingStatus': readingStatus,
                            'currentChapter': currentChapter,
                          });
                        }
                        onSave(localManhwa);
                      } else {
                        LoadingScreen.instance().hide();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to update progress"),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          );
        },
      );
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
                          onTap: () async {
                            final result =
                                await showGeneralDialog<Map<String, dynamic>>(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: "Progress Update",
                                  barrierColor: Colors.black38,
                                  pageBuilder: (_, __, ___) {
                                    return BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 6,
                                        sigmaY: 6,
                                      ),
                                      child: Center(
                                        child: buildEditDialog(
                                          onSave: (updatedManhwa) {
                                            Navigator.pop(
                                              context,
                                              updatedManhwa,
                                            ); // this will pop the bottom sheet
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );

                            // After the dialog is closed
                            if (result != null && mounted) {
                              setState(() {
                                localManhwa = localManhwa.copyWith(
                                  readingStatus:
                                      result['readingStatus'] as String,
                                  currentChapter:
                                      result['currentChapter'] as int,
                                );
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: customChip(
                            readingLabel(localManhwa),
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
