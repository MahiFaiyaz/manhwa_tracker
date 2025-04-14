import 'package:flutter/material.dart';

class ManhwaDetailPopup extends StatelessWidget {
  final Map<String, dynamic> manhwa;

  const ManhwaDetailPopup({super.key, required this.manhwa});

  @override
  Widget build(BuildContext context) {
    final title = manhwa["name"];
    final imageUrl = manhwa["image_url"];
    final synopsis = manhwa["synopsis"];
    final rating = manhwa["rating"];
    final status = manhwa["status"];
    final genres = List<String>.from(manhwa["genres"] ?? []);
    final categories = List<String>.from(manhwa["categories"] ?? []);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(synopsis, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip("Rating: $rating"),
                  _chip("Status: $status"),
                  ...genres.map(_chip),
                  ...categories.map(_chip),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      backgroundColor: Colors.purple[100],
      labelStyle: const TextStyle(fontSize: 12),
    );
  }
}
