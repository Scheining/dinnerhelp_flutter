import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homechef/core/localization/app_localizations_extension.dart';
import 'package:homechef/data/repositories/booking_repository.dart';
import 'package:homechef/models/booking.dart';
import 'package:homechef/providers/booking_provider.dart';
import 'package:homechef/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRatingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  
  const BookingRatingScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<BookingRatingScreen> createState() => _BookingRatingScreenState();
}

class _BookingRatingScreenState extends ConsumerState<BookingRatingScreen> 
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late List<Animation<double>> _starAnimations;
  Booking? _booking;
  Map<String, dynamic>? _chefData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _starAnimations = List.generate(5, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });
    
    _animationController.forward();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Load booking details
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final booking = await bookingRepo.getBookingById(widget.bookingId);
      
      if (booking == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking ikke fundet')),
          );
          context.pop();
        }
        return;
      }
      
      // Check if booking is completed
      if (booking.status != BookingStatus.completed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Du kan kun bedømme gennemførte bookinger')),
          );
          context.pop();
        }
        return;
      }
      
      // Check if already reviewed
      final existingReview = await supabase
          .from('chef_ratings')
          .select()
          .eq('booking_id', widget.bookingId)
          .maybeSingle();
          
      if (existingReview != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Du har allerede bedømt denne booking')),
          );
          context.pop();
        }
        return;
      }
      
      // Load chef details
      final chefData = await supabase
          .from('chefs')
          .select('''
            id,
            profile_image_url,
            profiles!inner(
              first_name,
              last_name
            )
          ''')
          .eq('id', booking.chefId)
          .single();
      
      setState(() {
        _booking = booking;
        _chefData = chefData;
      });
    } catch (e) {
      debugPrint('Error loading booking details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fejl ved indlæsning: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vælg venligst en bedømmelse')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null || _booking == null) {
        throw Exception('Bruger eller booking ikke fundet');
      }
      
      // Insert review into chef_ratings table
      await supabase.from('chef_ratings').insert({
        'chef_id': _booking!.chefId,
        'user_id': user.id,
        'booking_id': widget.bookingId,
        'rating': _rating,
        'review': _reviewController.text.isNotEmpty ? _reviewController.text : null,
        'status': 'published',
      });
      
      // Update booking with rating
      await supabase.from('bookings').update({
        'user_rating': _rating,
        'user_review': _reviewController.text.isNotEmpty ? _reviewController.text : null,
      }).eq('id', widget.bookingId);
      
      // Update chef's average rating
      await _updateChefAverageRating(_booking!.chefId);
      
      if (mounted) {
        // Show success animation
        await _showSuccessAnimation();
        
        // Navigate back to bookings
        context.go('/bookings');
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fejl ved indsendelse: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  Future<void> _updateChefAverageRating(String chefId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Calculate average rating
      final ratingsResponse = await supabase
          .from('chef_ratings')
          .select('rating')
          .eq('chef_id', chefId)
          .eq('status', 'published');
      
      if (ratingsResponse.isNotEmpty) {
        final ratings = (ratingsResponse as List<dynamic>)
            .map((r) => r['rating'] as int)
            .toList();
        
        final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
        final totalReviews = ratings.length;
        
        // Update chef profile with average rating and total reviews
        await supabase.from('chefs').update({
          'average_rating': averageRating,
          'total_reviews': totalReviews,
        }).eq('id', chefId);
      }
    } catch (e) {
      debugPrint('Error updating chef average rating: $e');
    }
  }
  
  Future<void> _showSuccessAnimation() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Tak for din bedømmelse!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ).timeout(
      const Duration(seconds: 2),
      onTimeout: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    
    if (_booking == null || _chefData == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final chefName = '${_chefData!['profiles']['first_name']} ${_chefData!['profiles']['last_name']}';
    final chefImage = _chefData!['profile_image_url'];
    final bookingDate = '${_booking!.dateTime.day}/${_booking!.dateTime.month}/${_booking!.dateTime.year}';
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Spring over',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Chef info header
            if (chefImage != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(chefImage),
              )
            else
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  chefName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            Text(
              'Hvordan var din oplevelse med',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              chefName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              bookingDate,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            
            // Star rating selector
            Text(
              'Giv din bedømmelse',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return AnimatedBuilder(
                  animation: _starAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _starAnimations[index].value,
                      child: IconButton(
                        onPressed: () {
                          setState(() => _rating = index + 1);
                          // Animate stars on selection
                          _animationController.forward(from: 0.8);
                        },
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          size: 48,
                          color: index < _rating 
                              ? Colors.amber 
                              : theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                _getRatingText(_rating),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Review text field
            Text(
              'Del dine tanker (valgfrit)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _reviewController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Fortæl andre om din oplevelse...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit button
            CustomButton(
              text: _isSubmitting ? 'Sender...' : 'Giv bedømmelse',
              onPressed: _isSubmitting || _rating == 0 ? null : _submitReview,
              width: double.infinity,
              icon: Icons.star,
              isLoading: _isSubmitting,
            ),
            
            const SizedBox(height: 16),
            
            // Privacy notice
            Text(
              'Din bedømmelse vil være synlig for andre brugere',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Meget utilfreds';
      case 2:
        return 'Utilfreds';
      case 3:
        return 'OK';
      case 4:
        return 'Tilfreds';
      case 5:
        return 'Meget tilfreds';
      default:
        return '';
    }
  }
}