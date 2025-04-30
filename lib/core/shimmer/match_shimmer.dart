import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class MatchShimmer extends StatelessWidget {
  const MatchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(width: 50, height: 50, color: Colors.white),
            Column(
              children: [
                Container(width: 60, height: 20, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 80, height: 14, color: Colors.white),
              ],
            ),
            Container(width: 50, height: 50, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
