import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homechef/models/carousel_item.dart';
import 'package:homechef/supabase/supabase_config.dart';

class ImageCarousel extends StatefulWidget {
  final List<CarouselItem> items;
  final double height;
  final String bucketName;

  const ImageCarousel({
    super.key,
    required this.items,
    this.height = 200,
    this.bucketName = 'carousel-images',
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  late int _currentPage;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  
  // Create a very large number for "infinite" scrolling
  static const int _virtualCount = 10000;

  @override
  void initState() {
    super.initState();
    // Start in the middle of our virtual list, but ensure we start at index 0
    final middleBase = _virtualCount ~/ 2;
    _currentPage = middleBase - (middleBase % widget.items.length);
    _currentIndex = 0;
    _pageController = PageController(initialPage: _currentPage);
    
    // Start auto-scroll after a delay to ensure PageController is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
      _preloadImages();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isUserInteracting && 
          mounted && 
          _pageController.hasClients &&
          widget.items.isNotEmpty) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _preloadImages() {
    // Preload all images to improve UX
    for (final item in widget.items) {
      final imageUrl = item.imageUrl.startsWith('http') 
          ? item.imageUrl 
          : SupabaseConfig.getPublicImageUrl(widget.bucketName, item.imageUrl);
      
      if (!_isSvgImage(imageUrl)) {
        precacheImage(NetworkImage(imageUrl), context);
      }
    }
  }

  bool _isSvgImage(String url) {
    return url.toLowerCase().contains('.svg') || 
           url.toLowerCase().endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanDown: (_) {
                setState(() {
                  _isUserInteracting = true;
                });
                _stopAutoScroll();
              },
              onPanEnd: (_) {
                setState(() {
                  _isUserInteracting = false;
                });
                // Resume auto-scroll after 3 seconds
                Future.delayed(const Duration(seconds: 3), () {
                  if (!_isUserInteracting && mounted) {
                    _startAutoScroll();
                  }
                });
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                    _currentIndex = page % widget.items.length;
                  });
                },
                itemCount: _virtualCount,
                itemBuilder: (context, index) {
                  final actualIndex = index % widget.items.length;
                  final item = widget.items[actualIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CarouselCard(
                      item: item,
                      bucketName: widget.bucketName,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          CarouselIndicator(
            itemCount: widget.items.length,
            currentIndex: _currentIndex,
          ),
        ],
      ),
    );
  }
}

class CarouselCard extends StatelessWidget {
  final CarouselItem item;
  final String bucketName;

  const CarouselCard({
    super.key,
    required this.item,
    required this.bucketName,
  });

  bool _isSvgImage(String url) {
    return url.toLowerCase().contains('.svg') || 
           url.toLowerCase().endsWith('.svg');
  }

  Widget _buildImageWidget(String imageUrl) {
    // Check if it's an SVG file
    if (_isSvgImage(imageUrl)) {
      // Use SvgPicture.network with proper error handling
      return SvgPicture.network(
        imageUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (BuildContext context) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    // For non-SVG images, use Image.network
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      headers: {
        'Accept': 'image/*',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  color: Colors.grey.shade600,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check console for details',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.grey.shade600,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use direct URL if it starts with http, otherwise use Supabase storage
    final imageUrl = item.imageUrl.startsWith('http') 
        ? item.imageUrl 
        : SupabaseConfig.getPublicImageUrl(bucketName, item.imageUrl);


    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWidget(imageUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class CarouselIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const CarouselIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}