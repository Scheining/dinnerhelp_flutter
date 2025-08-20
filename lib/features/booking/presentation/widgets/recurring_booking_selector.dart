import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../providers/recurring_booking_providers.dart';

class RecurringBookingSelector extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final Function(RecurrencePattern?)? onPatternSelected;

  const RecurringBookingSelector({
    super.key,
    required this.initialDate,
    this.onPatternSelected,
  });

  @override
  ConsumerState<RecurringBookingSelector> createState() => _RecurringBookingSelectorState();
}

class _RecurringBookingSelectorState extends ConsumerState<RecurringBookingSelector> {
  bool enableRecurring = false;
  RecurrenceType selectedPattern = RecurrenceType.weekly;
  DateTime? endDate;
  List<DateTime> generatedOccurrences = [];
  List<DateTime> conflictingDates = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with toggle
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                AppSpacing.horizontalSpace12,
                Expanded(
                  child: Text(
                    'Gentag booking', // Repeat booking
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: enableRecurring,
                  onChanged: (value) {
                    setState(() {
                      enableRecurring = value;
                      if (!value) {
                        endDate = null;
                        generatedOccurrences = [];
                        conflictingDates = [];
                        widget.onPatternSelected?.call(null);
                      } else {
                        _generateOccurrences();
                      }
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
            AppSpacing.verticalSpace8,
            Text(
              'Vil du gentage denne booking regelmæssigt?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),

            if (enableRecurring) ...[
              AppSpacing.verticalSpace24,
              
              // Pattern Selection
              _buildPatternSelector(theme),
              AppSpacing.verticalSpace24,
              
              // End Date Selection
              _buildEndDateSelector(theme),
              AppSpacing.verticalSpace24,
              
              // Preview
              if (generatedOccurrences.isNotEmpty)
                _buildOccurrencePreview(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPatternSelector(ThemeData theme) {
    final patterns = [
      (RecurrenceType.weekly, 'Ugentligt', 'Hver uge'),
      (RecurrenceType.biWeekly, 'Hver 14. dag', 'Hver anden uge'),
      (RecurrenceType.every3Weeks, 'Hver 3. uge', 'Hver tredje uge'),
      (RecurrenceType.monthly, 'Månedligt', 'Hver måned'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gentagelsesmønster', // Recurrence pattern
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.verticalSpace12,
        
        ...patterns.map((pattern) {
          final type = pattern.$1;
          final title = pattern.$2;
          final subtitle = pattern.$3;
          final isSelected = selectedPattern == type;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedPattern = type;
                });
                _generateOccurrences();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected 
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
                      : null,
                ),
                child: Row(
                  children: [
                    Radio<RecurrenceType>(
                      value: type,
                      groupValue: selectedPattern,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPattern = value;
                          });
                          _generateOccurrences();
                        }
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                    AppSpacing.horizontalSpace12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEndDateSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Slut dato', // End date
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        AppSpacing.verticalSpace8,
        Text(
          'Maksimal periode: 6 måneder', // Maximum period: 6 months
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        AppSpacing.verticalSpace12,
        
        InkWell(
          onTap: () => _selectEndDate(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                AppSpacing.horizontalSpace12,
                Expanded(
                  child: Text(
                    endDate != null
                        ? DateFormat.yMMMd('da').format(endDate!)
                        : 'Vælg slutdato', // Select end date
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: endDate != null
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

  Widget _buildOccurrencePreview(ThemeData theme) {
    const maxPreviewItems = 8;
    final previewOccurrences = generatedOccurrences.take(maxPreviewItems).toList();
    final hasMoreOccurrences = generatedOccurrences.length > maxPreviewItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Forhåndsvisning', // Preview
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${generatedOccurrences.length} bookings',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpace12,
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              ...previewOccurrences.asMap().entries.map((entry) {
                final index = entry.key;
                final occurrence = entry.value;
                final isConflicting = conflictingDates.contains(occurrence);
                final isFirst = index == 0;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: index == previewOccurrences.length - 1 ? 0 : 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isFirst 
                              ? theme.colorScheme.primary
                              : isConflicting
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.horizontalSpace12,
                      Expanded(
                        child: Text(
                          DateFormat.yMMMEd('da').format(occurrence),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isConflicting
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface,
                            decoration: isConflicting ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (isFirst)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Første', // First
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (isConflicting && !isFirst)
                        Icon(
                          Icons.warning,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                    ],
                  ),
                );
              }),
              
              if (hasMoreOccurrences)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '... og ${generatedOccurrences.length - maxPreviewItems} flere',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Conflict warning
        if (conflictingDates.isNotEmpty) ...[
          AppSpacing.verticalSpace12,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.colorScheme.onErrorContainer,
                  size: 20,
                ),
                AppSpacing.horizontalSpace8,
                Expanded(
                  child: Text(
                    '${conflictingDates.length} dato(er) har konflikter og springes over',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final now = DateTime.now();
    final maxDate = widget.initialDate.add(const Duration(days: 180)); // 6 months
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? widget.initialDate.add(const Duration(days: 30)),
      firstDate: widget.initialDate.add(const Duration(days: 7)),
      lastDate: maxDate,
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

    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
      });
      _generateOccurrences();
    }
  }

  void _generateOccurrences() {
    if (!enableRecurring || endDate == null) return;

    final pattern = RecurrencePattern(
      type: selectedPattern,
      startDate: widget.initialDate,
      endDate: endDate,
    );

    setState(() {
      generatedOccurrences = pattern.generateOccurrences();
      // For demo purposes, simulate some conflicts
      conflictingDates = _simulateConflicts(generatedOccurrences);
    });

    // Notify parent about the pattern
    widget.onPatternSelected?.call(pattern);
  }

  List<DateTime> _simulateConflicts(List<DateTime> occurrences) {
    // This would normally check against actual bookings
    // For demo, randomly mark some dates as conflicting
    final conflicts = <DateTime>[];
    for (int i = 0; i < occurrences.length; i++) {
      // Simulate conflicts for every 5th occurrence after the first
      if (i > 0 && (i + 1) % 5 == 0) {
        conflicts.add(occurrences[i]);
      }
    }
    return conflicts;
  }
}