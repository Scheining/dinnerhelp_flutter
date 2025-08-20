import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';

class SteppedDateTimeSelector extends ConsumerStatefulWidget {
  const SteppedDateTimeSelector({super.key});

  @override
  ConsumerState<SteppedDateTimeSelector> createState() => _SteppedDateTimeSelectorState();
}

class _SteppedDateTimeSelectorState extends ConsumerState<SteppedDateTimeSelector> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  String? _selectedTime;
  Duration? _selectedDuration;
  int? _numberOfGuests;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(searchFiltersProvider);
    _selectedDate = currentFilters.date;
    _selectedTime = currentFilters.startTime;
    _selectedDuration = currentFilters.duration;
    _numberOfGuests = currentFilters.numberOfGuests;
    
    // Determine initial step based on existing selections
    if (_selectedDate != null) _currentStep = 1;
    if (_selectedTime != null) _currentStep = 2;
    if (_selectedDuration != null) _currentStep = 3;
    if (_numberOfGuests != null) _currentStep = 3;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _applyFilters();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipStep() {
    if (_currentStep < 3) {
      _nextStep();
    } else {
      _applyFilters();
    }
  }

  void _applyFilters() {
    ref.read(searchFiltersProvider.notifier).updateDate(_selectedDate);
    ref.read(searchFiltersProvider.notifier).updateStartTime(_selectedTime);
    ref.read(searchFiltersProvider.notifier).updateDuration(_selectedDuration);
    ref.read(searchFiltersProvider.notifier).updateNumberOfGuests(_numberOfGuests);
    Navigator.pop(context);
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedDate != null;
      case 1:
        return _selectedTime != null;
      case 2:
        return _selectedDuration != null;
      case 3:
        return true; // Guest count is optional
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with close button and progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                    const Spacer(),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: _previousStep,
                        child: const Text('Tilbage'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DateSelectionStep(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                _TimeSelectionStep(
                  selectedTime: _selectedTime,
                  onTimeSelected: (time) {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                ),
                _DurationSelectionStep(
                  selectedDuration: _selectedDuration,
                  onDurationSelected: (duration) {
                    setState(() {
                      _selectedDuration = duration;
                    });
                  },
                ),
                _GuestSelectionStep(
                  numberOfGuests: _numberOfGuests,
                  onGuestCountChanged: (count) {
                    setState(() {
                      _numberOfGuests = count;
                    });
                  },
                ),
              ],
            ),
          ),

          // Bottom actions
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: _skipStep,
                  child: const Text(
                    'Spring over',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _canProceed ? _nextStep : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_currentStep == 3 ? 'Anvend' : 'Næste'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Step 1: Date Selection
class _DateSelectionStep extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const _DateSelectionStep({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hvornår skal du bruge en kok?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Tab selector for Dates/Months/Flexible
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Datoer',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'Måneder',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'Fleksibel',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Month and Year
          Text(
            _getMonthYear(today),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          // Calendar grid
          _buildCalendarGrid(context, today),

          const SizedBox(height: 16),

          // Date flexibility options
          Wrap(
            spacing: 12,
            children: [
              _buildDateOption(context, 'Præcis dato', true),
              _buildDateOption(context, '± 1 dag', false),
              _buildDateOption(context, '± 2 dage', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, DateTime today) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    // Monday = 1, Sunday = 7 in Dart's weekday, so we need to adjust for Monday start
    final startingWeekday = (firstDayOfMonth.weekday - 1) % 7; // 0 = Monday

    return Column(
      children: [
        // Weekday headers (Danish: Monday first)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'O', 'T', 'F', 'L', 'S']
              .map((day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Calendar days
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: daysInMonth + startingWeekday,
          itemBuilder: (context, index) {
            if (index < startingWeekday) {
              return const SizedBox();
            }

            final day = index - startingWeekday + 1;
            final date = DateTime(today.year, today.month, day);
            final isSelected = selectedDate != null &&
                selectedDate!.day == day &&
                selectedDate!.month == today.month &&
                selectedDate!.year == today.year;
            final isPast = date.isBefore(today);

            return InkWell(
              onTap: isPast ? null : () => onDateSelected(isSelected ? null : date),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black
                      : isPast
                          ? Colors.transparent
                          : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isPast
                              ? Colors.grey.shade400
                              : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateOption(BuildContext context, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      backgroundColor: Colors.white,
      selectedColor: Colors.black,
      checkmarkColor: Colors.white,
      side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  String _getMonthYear(DateTime date) {
    const months = [
      'Januar', 'Februar', 'Marts', 'April', 'Maj', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// Step 2: Time Selection
class _TimeSelectionStep extends StatelessWidget {
  final String? selectedTime;
  final Function(String?) onTimeSelected;

  const _TimeSelectionStep({
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hvad tid skal kokken starte?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vælg det tidspunkt hvor kokken skal ankomme',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 48),

          // Time display and picker
          Center(
            child: Column(
              children: [
                // Display selected time
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        selectedTime ?? '--:--',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 72,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selectedTime != null ? 'Starttidspunkt' : 'Ingen tid valgt',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Select time button
                FilledButton.icon(
                  onPressed: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime != null 
                        ? TimeOfDay(
                            hour: int.parse(selectedTime!.split(':')[0]),
                            minute: int.parse(selectedTime!.split(':')[1]),
                          )
                        : const TimeOfDay(hour: 18, minute: 0),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            timePickerTheme: TimePickerThemeData(
                              backgroundColor: Colors.white,
                              hourMinuteShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              dayPeriodShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    
                    if (pickedTime != null) {
                      final formattedTime = 
                        '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                      onTimeSelected(formattedTime);
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(selectedTime != null ? 'Skift tidspunkt' : 'Vælg tidspunkt'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                if (selectedTime != null) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => onTimeSelected(null),
                    child: const Text('Ryd valg'),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Quick time suggestions
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Populære tidspunkter',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['12:00', '17:00', '18:00', '19:00'].map((time) {
                  final isSelected = selectedTime == time;
                  return FilterChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (selected) {
                      onTimeSelected(selected ? time : null);
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.black,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Step 3: Duration Selection
class _DurationSelectionStep extends StatelessWidget {
  final Duration? selectedDuration;
  final Function(Duration?) onDurationSelected;

  const _DurationSelectionStep({
    required this.selectedDuration,
    required this.onDurationSelected,
  });

  final List<Duration> _durations = const [
    Duration(hours: 2),
    Duration(hours: 3),
    Duration(hours: 4),
    Duration(hours: 5),
    Duration(hours: 6),
    Duration(hours: 7),
    Duration(hours: 8),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hvor lang tid skal kokken være der?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inkluderer forberedelse, servering og oprydning',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          Column(
            children: _durations.map((duration) {
              final hours = duration.inHours;
              final isSelected = selectedDuration == duration;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => onDurationSelected(isSelected ? null : duration),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$hours timer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Step 4: Guest Count Selection
class _GuestSelectionStep extends StatelessWidget {
  final int? numberOfGuests;
  final Function(int?) onGuestCountChanged;

  const _GuestSelectionStep({
    required this.numberOfGuests,
    required this.onGuestCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentCount = numberOfGuests ?? 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Antal personer',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hvor mange personer skal kokken lave mad til?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 48),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '$currentCount',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentCount == 1 ? 'person' : 'personer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      onPressed: currentCount > 1
                          ? () => onGuestCountChanged(currentCount - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        fixedSize: const Size(56, 56),
                      ),
                    ),
                    const SizedBox(width: 32),
                    IconButton.filled(
                      onPressed: currentCount < 20
                          ? () => onGuestCountChanged(currentCount + 1)
                          : null,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        fixedSize: const Size(56, 56),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick selection options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [2, 4, 6, 8, 10, 12].map((count) {
              final isSelected = numberOfGuests == count;
              return FilterChip(
                label: Text('$count'),
                selected: isSelected,
                onSelected: (selected) {
                  onGuestCountChanged(selected ? count : null);
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.black,
                checkmarkColor: Colors.white,
                side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}