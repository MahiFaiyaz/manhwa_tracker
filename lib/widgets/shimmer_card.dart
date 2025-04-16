import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerCard() {
  return Shimmer.fromColors(
    baseColor: Colors.deepPurple.shade100,
    highlightColor: Colors.deepPurple.shade300,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}
