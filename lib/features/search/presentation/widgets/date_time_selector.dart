import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';

class DateTimeSelector extends ConsumerStatefulWidget {
  const DateTimeSelector({super.key});

  @override
  ConsumerState<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends ConsumerState<DateTimeSelector> {
  DateTime? _selectedDate;
  String? _selectedTime;
  Duration? _selectedDuration;
  int? _numberOfGuests;

  final List<String> _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
    '21:00', '21:30', '22:00',
  ];

  final List<Duration> _durations = [
    const Duration(hours: 2),
    const Duration(hours: 3),
    const Duration(hours: 4),
    const Duration(hours: 5),
    const Duration(hours: 6),
  ];

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(searchFiltersProvider);
    _selectedDate = currentFilters.date;
    _selectedTime = currentFilters.startTime;
    _selectedDuration = currentFilters.duration;
    _numberOfGuests = currentFilters.numberOfGuests;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Hvornår skal du bruge en kok?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                      _selectedTime = null;
                      _selectedDuration = null;
                      _numberOfGuests = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    'Ryd',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selection
                  Text(
                    'Dato',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DateSelectionGrid(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Time Selection
                  Text(
                    'Starttidspunkt',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return FilterChip(
                        label: Text(time),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTime = selected ? time : null;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Duration Selection
                  Text(
                    'Varighed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durations.map((duration) {
                      final isSelected = _selectedDuration == duration;
                      final hours = duration.inHours;
                      return FilterChip(
                        label: Text('${hours}h'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDuration = selected ? duration : null;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Number of Guests
                  Text(
                    'Antal personer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _numberOfGuests != null && _numberOfGuests! > 1
                            ? () {
                                setState(() {
                                  _numberOfGuests = (_numberOfGuests ?? 2) - 1;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_numberOfGuests ?? 2}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      IconButton(
                        onPressed: _numberOfGuests != null && _numberOfGuests! < 20
                            ? () {
                                setState(() {
                                  _numberOfGuests = (_numberOfGuests ?? 2) + 1;
                                });
                              }
                            : () {
                                setState(() {
                                  _numberOfGuests = (_numberOfGuests ?? 2) + 1;
                                });
                              },
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _numberOfGuests = null;
                          });
                        },
                        child: const Text('Alle'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuller'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters
                      ref.read(searchFiltersProvider.notifier).updateDate(_selectedDate);
                      ref.read(searchFiltersProvider.notifier).updateStartTime(_selectedTime);
                      ref.read(searchFiltersProvider.notifier).updateDuration(_selectedDuration);
                      ref.read(searchFiltersProvider.notifier).updateNumberOfGuests(_numberOfGuests);
                      
                      Navigator.pop(context);
                    },
                    child: const Text('Anvend'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelectionGrid extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const _DateSelectionGrid({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Generate next 14 days
    final dates = List.generate(14, (index) {
      return today.add(Duration(days: index));
    });

    return Column(
      children: [
        // Quick options
        Row(
          children: [
            Expanded(
              child: _QuickDateChip(
                label: 'I dag',
                date: today,
                selectedDate: selectedDate,
                onSelected: onDateSelected,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickDateChip(
                label: 'I morgen',
                date: today.add(const Duration(days: 1)),
                selectedDate: selectedDate,
                onSelected: onDateSelected,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickDateChip(
                label: 'Denne weekend',
                date: _getNextWeekend(today),
                selectedDate: selectedDate,
                onSelected: onDateSelected,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Date grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            final isSelected = selectedDate != null &&
                selectedDate!.day == date.day &&
                selectedDate!.month == date.month &&
                selectedDate!.year == date.year;

            return InkWell(
              onTap: () => onDateSelected(isSelected ? null : date),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayOfWeekShort(date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Custom date picker button
        OutlinedButton.icon(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? today,
              firstDate: today,
              lastDate: today.add(const Duration(days: 365)),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text('Vælg anden dato'),
        ),
      ],
    );
  }

  String _getDayOfWeekShort(DateTime date) {
    const days = ['Man', 'Tir', 'Ons', 'Tor', 'Fre', 'Lør', 'Søn'];
    return days[date.weekday - 1];
  }

  DateTime _getNextWeekend(DateTime today) {
    // Get next Saturday
    final daysUntilSaturday = (6 - today.weekday) % 7;
    return today.add(Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday));
  }
}

class _QuickDateChip extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateTime? selectedDate;
  final Function(DateTime?) onSelected;

  const _QuickDateChip({
    required this.label,
    required this.date,
    required this.selectedDate,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedDate != null &&
        selectedDate!.day == date.day &&
        selectedDate!.month == date.month &&
        selectedDate!.year == date.year;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(selected ? date : null);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}