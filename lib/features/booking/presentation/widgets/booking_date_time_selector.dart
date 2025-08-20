import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../domain/entities/time_slot.dart';
import '../providers/booking_availability_providers.dart';

class BookingDateTimeSelector extends ConsumerStatefulWidget {
  final String chefId;
  final Duration minDuration;
  final int numberOfGuests;
  final Function(DateTime?)? onDateSelected;
  final Function(TimeSlot?)? onTimeSlotSelected;

  const BookingDateTimeSelector({
    super.key,
    required this.chefId,
    this.minDuration = const Duration(hours: 2),
    required this.numberOfGuests,
    this.onDateSelected,
    this.onTimeSlotSelected,
  });

  @override
  ConsumerState<BookingDateTimeSelector> createState() => _BookingDateTimeSelectorState();
}

class _BookingDateTimeSelectorState extends ConsumerState<BookingDateTimeSelector> {
  DateTime? selectedDate;
  TimeSlot? selectedTimeSlot;
  Duration selectedDuration = const Duration(hours: 3);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final availableTimeSlots = ref.watch(availableTimeSlotsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vælg dato og tidspunkt', // Select date and time
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            AppSpacing.verticalSpace16,
            
            // Date Selection
            _buildDateSelector(context, theme, l10n),
            AppSpacing.verticalSpace24,
            
            // Duration Selection
            _buildDurationSelector(context, theme),
            AppSpacing.verticalSpace24,
            
            // Time Slots
            if (selectedDate != null) ...[
              Text(
                'Tilgængelige tider', // Available times
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              AppSpacing.verticalSpace12,
              _buildTimeSlotSelector(context, theme, availableTimeSlots),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, ThemeData theme, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vælg dato', // Select date
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.verticalSpace8,
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                AppSpacing.horizontalSpace12,
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat.yMMMd('da').format(selectedDate!)
                        : 'Vælg en dato', // Select a date
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selectedDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector(BuildContext context, ThemeData theme) {
    final durations = [
      const Duration(hours: 2),
      const Duration(hours: 3),
      const Duration(hours: 4),
      const Duration(hours: 5),
      const Duration(hours: 6),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Varighed', // Duration
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.verticalSpace8,
        Wrap(
          spacing: AppSpacing.betweenChips,
          children: durations.map((duration) {
            final isSelected = selectedDuration == duration;
            return FilterChip(
              label: Text('${duration.inHours} timer'), // hours
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedDuration = duration;
                    selectedTimeSlot = null; // Reset time slot when duration changes
                  });
                  _loadAvailableTimeSlots();
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector(BuildContext context, ThemeData theme, AsyncValue<List<TimeSlot>> availableTimeSlots) {
    return availableTimeSlots.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Fejl ved indlæsning af tilgængelige tider', // Error loading available times
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      ),
      data: (timeSlots) {
        if (timeSlots.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Ingen tilgængelige tider for denne dato', // No available times for this date
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          );
        }

        return Wrap(
          spacing: AppSpacing.betweenChips,
          runSpacing: AppSpacing.betweenChips,
          children: timeSlots.map((timeSlot) {
            final isSelected = selectedTimeSlot == timeSlot;
            final isAvailable = timeSlot.isAvailable;
            final startTime = DateFormat.Hm().format(timeSlot.startTime);
            final endTime = DateFormat.Hm().format(timeSlot.endTime);

            return FilterChip(
              label: Text('$startTime - $endTime'),
              selected: isSelected,
              onSelected: isAvailable ? (selected) {
                setState(() {
                  selectedTimeSlot = selected ? timeSlot : null;
                });
                widget.onTimeSlotSelected?.call(selected ? timeSlot : null);
              } : null,
              backgroundColor: isAvailable 
                  ? theme.colorScheme.surface 
                  : theme.colorScheme.surfaceContainerHigh,
              selectedColor: theme.colorScheme.primaryContainer,
              disabledColor: theme.colorScheme.surfaceContainerHigh,
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: !isAvailable
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : isSelected 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: !isAvailable
                    ? theme.colorScheme.outline.withValues(alpha: 0.3)
                    : isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(hours: 2)); // Minimum 2 hours notice
    final lastDate = now.add(const Duration(days: 60)); // Maximum 60 days ahead

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('da', 'DK'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        selectedTimeSlot = null; // Reset time slot when date changes
      });
      widget.onDateSelected?.call(pickedDate);
      _loadAvailableTimeSlots();
    }
  }

  void _loadAvailableTimeSlots() {
    if (selectedDate != null) {
      ref.read(availableTimeSlotsProvider.notifier).getAvailableTimeSlots(
        chefId: widget.chefId,
        date: selectedDate!,
        duration: selectedDuration,
        numberOfGuests: widget.numberOfGuests,
      );
    }
  }
}