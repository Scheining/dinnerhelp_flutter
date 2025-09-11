import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final int maxStars;
  final bool showNumber;
  final MainAxisAlignment alignment;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.maxStars = 5,
    this.showNumber = false,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber.shade600;
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxStars, (index) {
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
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveRatingStars extends StatefulWidget {
  final int initialRating;
  final int maxRating;
  final double size;
  final Color? color;
  final Function(int) onRatingChanged;
  final bool enabled;
  
  const InteractiveRatingStars({
    super.key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 40,
    this.color,
    required this.onRatingChanged,
    this.enabled = true,
  });

  @override
  State<InteractiveRatingStars> createState() => _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<InteractiveRatingStars> 
    with SingleTickerProviderStateMixin {
  late int _rating;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateRating(int newRating) {
    if (!widget.enabled) return;
    
    setState(() {
      _rating = newRating;
    });
    
    widget.onRatingChanged(newRating);
    
    // Animate the selection
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final starColor = widget.color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final starValue = index + 1;
        final isSelected = starValue <= _rating;
        
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = isSelected && _animationController.isAnimating
                ? _scaleAnimation.value
                : 1.0;
            
            return Transform.scale(
              scale: scale,
              child: IconButton(
                onPressed: widget.enabled
                    ? () => _updateRating(starValue)
                    : null,
                icon: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  size: widget.size,
                  color: isSelected
                      ? starColor
                      : starColor.withOpacity(0.3),
                ),
                padding: const EdgeInsets.all(4),
              ),
            );
          },
        );
      }),
    );
  }
}

class RatingBadge extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double iconSize;
  final bool showTotal;
  final Color? backgroundColor;
  
  const RatingBadge({
    super.key,
    required this.rating,
    required this.totalReviews,
    this.iconSize = 14,
    this.showTotal = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (totalReviews == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: iconSize,
            color: Colors.amber,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          if (showTotal) ...[
            const SizedBox(width: 2),
            Text(
              '($totalReviews)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}