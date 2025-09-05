import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../widgets/custom_button.dart';
import 'package:homechef/models/chef.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/selected_dish.dart';
import '../../domain/entities/custom_dish_request.dart';
import '../../domain/entities/recurrence_pattern.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  final Chef chef;
  final DateTime selectedDate;
  final TimeSlot selectedTimeSlot;
  final int numberOfGuests;
  final List<SelectedDish> selectedDishes;
  final CustomDishRequest? customDishRequest;
  final RecurrencePattern? recurringPattern;
  final Function() onConfirmBooking;

  const BookingSummaryScreen({
    super.key,
    required this.chef,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.numberOfGuests,
    required this.selectedDishes,
    this.customDishRequest,
    this.recurringPattern,
    required this.onConfirmBooking,
  });

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking oversigt'), // Booking summary
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalSpace16,
                  
                  // Chef info
                  _buildChefInfo(theme),
                  AppSpacing.verticalSpace24,
                  
                  // Booking details
                  _buildBookingDetails(theme),
                  AppSpacing.verticalSpace24,
                  
                  // Dishes
                  if (widget.selectedDishes.isNotEmpty || widget.customDishRequest != null)
                    _buildDishesSection(theme),
                  AppSpacing.verticalSpace24,
                  
                  // Recurring booking info
                  if (widget.recurringPattern != null)
                    _buildRecurringSection(theme),
                  AppSpacing.verticalSpace24,
                  
                  // Pricing breakdown
                  _buildPricingBreakdown(theme),
                  AppSpacing.verticalSpace32,
                ],
              ),
            ),
          ),
          
          // Bottom confirmation
          _buildBottomActions(theme),
        ],
      ),
    );
  }

  Widget _buildChefInfo(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            // Chef avatar
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(widget.chef.profileImage),
              backgroundColor: theme.colorScheme.primaryContainer,
              onBackgroundImageError: (error, stackTrace) {},
              child: widget.chef.profileImage.isEmpty
                  ? Icon(Icons.person, size: 35, color: theme.colorScheme.primary)
                  : null,
            ),
            AppSpacing.horizontalSpace16,
            
            // Chef details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chef.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  AppSpacing.verticalSpace4,
                  Text(
                    widget.chef.cuisineTypes.join(' • '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AppSpacing.verticalSpace8,
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      AppSpacing.horizontalSpace4,
                      Text(
                        '${widget.chef.rating} (${widget.chef.reviewCount})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.chef.hourlyRate.toStringAsFixed(0)} kr/time',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
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

  Widget _buildBookingDetails(ThemeData theme) {
    final duration = widget.selectedTimeSlot.duration;
    final formattedDate = DateFormat.yMMMEd('da').format(widget.selectedDate);
    final startTime = DateFormat.Hm().format(widget.selectedTimeSlot.startTime);
    final endTime = DateFormat.Hm().format(widget.selectedTimeSlot.endTime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking detaljer', // Booking details
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalSpace16,
            
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Dato',
              value: formattedDate,
              theme: theme,
            ),
            AppSpacing.verticalSpace12,
            
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Tid',
              value: '$startTime - $endTime',
              theme: theme,
            ),
            AppSpacing.verticalSpace12,
            
            _buildDetailRow(
              icon: Icons.timelapse,
              label: 'Varighed',
              value: '${duration.inHours} timer',
              theme: theme,
            ),
            AppSpacing.verticalSpace12,
            
            _buildDetailRow(
              icon: Icons.people,
              label: 'Personer',
              value: '${widget.numberOfGuests} personer',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        AppSpacing.horizontalSpace12,
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDishesSection(ThemeData theme) {
    final totalPreparationTime = widget.selectedDishes.fold(0, (sum, dish) => sum + dish.totalPreparationTimeMinutes) + 
        (widget.customDishRequest?.estimatedPreparationTimeMinutes ?? 0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Retter', // Dishes
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalPreparationTime min tilberedning',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpace16,
            
            // Selected dishes
            ...widget.selectedDishes.map((selectedDish) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: selectedDish.dish.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(selectedDish.dish.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: selectedDish.dish.imageUrl == null
                          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                          : null,
                    ),
                    child: selectedDish.dish.imageUrl == null
                        ? Icon(
                            Icons.restaurant,
                            color: theme.colorScheme.primary,
                            size: 24,
                          )
                        : null,
                  ),
                  AppSpacing.horizontalSpace12,
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedDish.dish.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (selectedDish.quantity > 1)
                              Text(
                                '×${selectedDish.quantity}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                        if (selectedDish.dish.description != null) ...[
                          AppSpacing.verticalSpace4,
                          Text(
                            selectedDish.dish.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )),
            
            // Custom dish
            if (widget.customDishRequest != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                    AppSpacing.horizontalSpace12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customDishRequest!.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          AppSpacing.verticalSpace4,
                          Text(
                            widget.customDishRequest!.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Tilpasset', // Custom
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringSection(ThemeData theme) {
    final pattern = widget.recurringPattern!;
    final occurrences = pattern.generateOccurrences();
    
    String patternDescription;
    switch (pattern.type) {
      case RecurrenceType.weekly:
        patternDescription = 'Ugentligt';
        break;
      case RecurrenceType.biWeekly:
        patternDescription = 'Hver 14. dag';
        break;
      case RecurrenceType.every3Weeks:
        patternDescription = 'Hver 3. uge';
        break;
      case RecurrenceType.monthly:
        patternDescription = 'Månedligt';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                AppSpacing.horizontalSpace12,
                Text(
                  'Gentaget booking', // Recurring booking
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpace16,
            
            _buildDetailRow(
              icon: Icons.sync,
              label: 'Mønster',
              value: patternDescription,
              theme: theme,
            ),
            AppSpacing.verticalSpace12,
            
            _buildDetailRow(
              icon: Icons.event_note,
              label: 'Antal bookings',
              value: '${occurrences.length} gange',
              theme: theme,
            ),
            AppSpacing.verticalSpace12,
            
            if (pattern.endDate != null)
              _buildDetailRow(
                icon: Icons.event_available,
                label: 'Slutter',
                value: DateFormat.yMMMd('da').format(pattern.endDate!),
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingBreakdown(ThemeData theme) {
    final duration = widget.selectedTimeSlot.duration;
    final hourlyRate = widget.chef.hourlyRate;
    final basePrice = hourlyRate * duration.inHours;
    final serviceFee = (basePrice * 0.1); // 10% service fee
    final tax = (basePrice + serviceFee) * 0.25; // 25% Danish VAT
    final totalPrice = basePrice + serviceFee + tax;
    
    final isRecurring = widget.recurringPattern != null;
    final occurrenceCount = isRecurring ? widget.recurringPattern!.generateOccurrences().length : 1;
    final totalRecurringPrice = totalPrice * occurrenceCount;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pris oversigt', // Price overview
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalSpace16,
            
            _buildPriceRow(
              label: '${hourlyRate.toStringAsFixed(0)} kr/time × ${duration.inHours} timer',
              value: '${basePrice.toStringAsFixed(0)} kr',
              theme: theme,
            ),
            
            _buildPriceRow(
              label: 'Servicefee (10%)',
              value: '${serviceFee.toStringAsFixed(0)} kr',
              theme: theme,
            ),
            
            _buildPriceRow(
              label: 'Moms (25%)',
              value: '${tax.toStringAsFixed(0)} kr',
              theme: theme,
            ),
            
            const Divider(),
            
            _buildPriceRow(
              label: isRecurring ? 'Total pr. booking' : 'Total',
              value: '${totalPrice.toStringAsFixed(0)} kr',
              theme: theme,
              isTotal: !isRecurring,
            ),
            
            if (isRecurring) ...[
              AppSpacing.verticalSpace8,
              _buildPriceRow(
                label: 'Total for $occurrenceCount bookings',
                value: '${totalRecurringPrice.toStringAsFixed(0)} kr',
                theme: theme,
                isTotal: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    required ThemeData theme,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                color: isTotal 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isTotal 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontSize: isTotal ? 16 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: AppSpacing.screenPaddingHorizontal.copyWith(
        top: AppSpacing.space16,
        bottom: AppSpacing.space24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Terms and conditions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Ved at bekræfte accepterer du vores betingelser. Booking kan annulleres gratis indtil 24 timer før.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          AppSpacing.verticalSpace16,
          
          // Confirm button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: _isConfirming ? 'Bekræfter...' : 'Bekræft booking',
              onPressed: _isConfirming ? null : _confirmBooking,
              variant: ButtonVariant.primary,
              isLoading: _isConfirming,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    setState(() {
      _isConfirming = true;
    });
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      widget.onConfirmBooking();
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved bekræftelse af booking: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }
}