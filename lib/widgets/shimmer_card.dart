import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerCard() {
  return Shimmer.fromColors(
    baseColor: Colors.purple[100]!,
    highlightColor: Colors.purple[300]!,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // const SizedBox(height: 6),
        // Container(
        //   height: 12,
        //   width: double.infinity,
        //   color: Colors.white,
        //   margin: const EdgeInsets.only(top: 4),
        // ),
      ],
    ),
  );
}
