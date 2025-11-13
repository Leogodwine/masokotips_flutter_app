import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 20,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(
            Icons.star_rounded,
            color: activeColor,
            size: size,
          );
        } else if (index == rating.floor() && rating % 1 > 0) {
          // Half star
          return Icon(
            Icons.star_half_rounded,
            color: activeColor,
            size: size,
          );
        } else {
          // Empty star
          return Icon(
            Icons.star_border_rounded,
            color: inactiveColor,
            size: size,
          );
        }
      }),
    );
  }
}
