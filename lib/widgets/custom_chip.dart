import 'package:flutter/material.dart';

Widget customChip(String label, {bool dark = false}) {
  final bgColor = dark ? Colors.black : Colors.deepPurple.shade200;

  final textColor = dark ? Colors.white : Colors.black;

  return Chip(
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    label: Text(label, style: TextStyle(fontSize: 14, color: textColor)),
    backgroundColor: bgColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
