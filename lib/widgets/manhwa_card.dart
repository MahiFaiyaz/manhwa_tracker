import 'package:flutter/material.dart';
import 'package:manhwa_tracker/widgets/manhwa_detail_popup.dart';
import '../models/manhwa.dart';

class ManhwaCard extends StatefulWidget {
  final Manhwa manhwa;

  const ManhwaCard({super.key, required this.manhwa});
  @override
  State<ManhwaCard> createState() => _ManhwaCardState();
}

class _ManhwaCardState extends State<ManhwaCard> {
  late Manhwa localManhwa;

  @override
  void initState() {
    super.initState();
    localManhwa = widget.manhwa;
  }

  @override
  Widget build(BuildContext context) {
    final title = localManhwa.name;
    final imageUrl = localManhwa.imageUrl;
    final rating = localManhwa.rating;
    final status = localManhwa.status;

    return GestureDetector(
      onTap: () async {
        final updated = await showModalBottomSheet<Manhwa>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => ManhwaDetailPopup(manhwa: localManhwa),
        );
        if (updated != null) {
          setState(() {
            localManhwa = updated;
          });
        }
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
                  color: Colors.black54, // subtle dark overlay
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
