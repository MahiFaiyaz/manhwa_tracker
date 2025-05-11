import 'package:flutter/material.dart';
import 'package:manhwa_tracker/widgets/manhwa_detail_popup.dart';
import '../models/manhwa.dart';

class ManhwaCard extends StatefulWidget {
  final Manhwa manhwa;
  final VoidCallback? onLibraryUpdate;
  final bool showLibraryBadge;

  const ManhwaCard({
    super.key,
    required this.manhwa,
    this.onLibraryUpdate,
    this.showLibraryBadge = true,
  });
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

  Widget _buildRatingBadge(String rating) {
    final stars = _getStarCountFromRating(rating);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            "$stars",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(Icons.star, color: Colors.black, size: 16),
        ],
      ),
    );
  }

  int _getStarCountFromRating(String rating) {
    switch (rating) {
      case 'Highly Recommended':
        return 5;
      case 'Recommended':
        return 4;
      case 'Good':
        return 3;
      case 'Decent':
        return 2;
      case 'Meh':
        return 1;
      default:
        return 0;
    }
  }

  Widget _buildLibraryBadge(String readingStatus) {
    if (readingStatus == 'not_read') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.bookmark_added, color: Colors.black, size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = localManhwa.name;
    final imageUrl = localManhwa.imageUrl;
    final rating = localManhwa.rating;
    // final status = localManhwa.status;

    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<Manhwa>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => ManhwaDetailPopup(manhwa: localManhwa),
        );
        if (result != null && mounted) {
          final updated = localManhwa.copyWith(
            readingStatus: result.readingStatus,
            currentChapter: result.currentChapter,
          );
          setState(() {
            localManhwa = updated;
          });
          widget.onLibraryUpdate?.call();
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
            Positioned(top: 0, left: 0, child: _buildRatingBadge(rating)),
            if (widget.showLibraryBadge)
              Positioned(
                top: 0,
                right: 0,
                child: _buildLibraryBadge(localManhwa.readingStatus),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
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
