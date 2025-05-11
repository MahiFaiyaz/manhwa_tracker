import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget customChip(
  String label, {
  IconData? icon,
  bool shimmer = false,
  bool dark = false,
}) {
  final bgColor = dark ? Colors.black : Colors.deepPurple.shade200;
  final textColor = dark ? Colors.white : Colors.black;

  Widget? iconWidget;
  if (icon != null) {
    iconWidget = Icon(icon, size: 16, color: textColor);
  }

  return Chip(
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    label:
        shimmer
            ? Shimmer.fromColors(
              baseColor: textColor,
              highlightColor: Colors.deepPurple.shade100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, color: textColor)),
                  if (iconWidget != null) ...[
                    const SizedBox(width: 4),
                    iconWidget,
                  ],
                ],
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(fontSize: 14, color: textColor)),
                if (iconWidget != null) ...[
                  const SizedBox(width: 4),
                  iconWidget,
                ],
              ],
            ),
    backgroundColor: bgColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
