import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final int maxStars;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber.shade600;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        IconData iconData;
        
        if (rating >= starValue) {
          iconData = Icons.star;
        } else if (rating >= starValue - 0.5) {
          iconData = Icons.star_half;
        } else {
          iconData = Icons.star_border;
        }
        
        return Icon(
          iconData,
          size: size,
          color: starColor,
        );
      }),
    );
  }
}