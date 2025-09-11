import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  
  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        color: baseColor,
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: [
                  _animation.value - 0.3,
                  _animation.value,
                  _animation.value + 0.3,
                ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChefCardSkeleton extends StatelessWidget {
  final double width;
  final double height;
  
  const ChefCardSkeleton({
    super.key,
    this.width = 330,
    this.height = 420,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image skeleton
            SkeletonLoader(
              width: double.infinity,
              height: 180,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            
            const SizedBox(height: 48), // Space for profile image overlay
            
            // Content skeleton
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name skeleton
                    const SkeletonLoader(
                      width: 120,
                      height: 20,
                    ),
                    const SizedBox(height: 12),
                    
                    // Bio skeleton
                    const SkeletonLoader(
                      width: double.infinity,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    const SkeletonLoader(
                      width: double.infinity,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    const SkeletonLoader(
                      width: 200,
                      height: 14,
                    ),
                    
                    const Spacer(),
                    
                    // Bottom row skeleton
                    Row(
                      children: [
                        const SkeletonLoader(
                          width: 50,
                          height: 24,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        const SizedBox(width: 12),
                        const SkeletonLoader(
                          width: 80,
                          height: 24,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        const SizedBox(width: 6),
                        const SkeletonLoader(
                          width: 60,
                          height: 24,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DishCardSkeleton extends StatelessWidget {
  final double width;
  final double height;
  
  const DishCardSkeleton({
    super.key,
    this.width = 240,
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dish image skeleton
            SkeletonLoader(
              width: double.infinity,
              height: 180,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            
            // Content skeleton
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  const SkeletonLoader(
                    width: 140,
                    height: 18,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description skeleton
                  const SkeletonLoader(
                    width: double.infinity,
                    height: 14,
                  ),
                  const SizedBox(height: 6),
                  const SkeletonLoader(
                    width: 160,
                    height: 14,
                  ),
                  const SizedBox(height: 12),
                  
                  // Price and rating skeleton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLoader(
                        width: 60,
                        height: 20,
                      ),
                      SkeletonLoader(
                        width: 50,
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}