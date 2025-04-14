import 'package:flutter/material.dart';
import 'package:manhwa_tracker/widgets/manhwa_detail_popup.dart';

class ManhwaCard extends StatelessWidget {
  final Map<String, dynamic> manhwa;

  const ManhwaCard({super.key, required this.manhwa});

  @override
  Widget build(BuildContext context) {
    final title = manhwa["name"] ?? "";
    final imageUrl = manhwa["image_url"] ?? "";
    final rating = manhwa["rating"] ?? "";
    final status = manhwa["status"] ?? "";

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => ManhwaDetailPopup(manhwa: manhwa),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // subtle dark overlay
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
