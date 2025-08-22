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
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252325) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Header with close button and progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark 
                            ? Colors.grey.shade800.withOpacity(0.5)
                            : Colors.grey.shade100,
                      ),
                    ),
                    const Spacer(),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: _previousStep,
                        child: Text(
                          'Tilbage',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: isDark 
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF252325),
                        const Color(0xFF1A1A1A),
                      ]
                    : [
                        Colors.grey.shade50,
                        Colors.white,
                      ],
              ),
              border: Border(
                top: BorderSide(
                  color: isDark 
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: _skipStep,
                  child: Text(
                    'Spring over',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _canProceed ? _nextStep : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
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
class _DateSelectionStep extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const _DateSelectionStep({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_DateSelectionStep> createState() => _DateSelectionStepState();
}

class _DateSelectionStepState extends State<_DateSelectionStep> {
  int _selectedTabIndex = 0; // 0: Datoer, 1: Måneder, 2: Fleksibel

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 32),

          // Tab selector for Dates/Months/Flexible
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.grey.shade800.withOpacity(0.3)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                    ? Colors.grey.shade700.withOpacity(0.5)
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Datoer',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _selectedTabIndex == 0
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Måneder',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _selectedTabIndex == 1
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 2;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 2
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Fleksibel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _selectedTabIndex == 2
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey.shade600),
                          ),
                        ),
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
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 24),

          // Calendar grid
          if (_selectedTabIndex == 0)
            _buildCalendarGrid(context, today)
          else if (_selectedTabIndex == 1)
            _buildMonthsGrid(context)
          else
            _buildFlexibleOptions(context),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, DateTime today) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
            final isSelected = widget.selectedDate != null &&
                widget.selectedDate!.day == day &&
                widget.selectedDate!.month == today.month &&
                widget.selectedDate!.year == today.year;
            final isPast = date.isBefore(today);

            final isToday = day == DateTime.now().day && 
                today.month == DateTime.now().month && 
                today.year == DateTime.now().year;
            
            return InkWell(
              onTap: isPast ? null : () => widget.onDateSelected(isSelected ? null : date),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isToday
                          ? (isDark 
                              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                              : theme.colorScheme.primaryContainer)
                          : isPast
                              ? Colors.transparent
                              : (isDark 
                                  ? Colors.grey.shade800.withOpacity(0.3)
                                  : Colors.transparent),
                  borderRadius: BorderRadius.circular(20),
                  border: isToday && !isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isPast
                              ? (isDark ? Colors.white30 : Colors.grey.shade400)
                              : isToday
                                  ? theme.colorScheme.primary
                                  : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
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


  String _getMonthYear(DateTime date) {
    const months = [
      'Januar', 'Februar', 'Marts', 'April', 'Maj', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildMonthsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const months = [
      'Januar', 'Februar', 'Marts', 'April', 'Maj', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'December'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vælg måned',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final now = DateTime.now();
            final monthDate = DateTime(now.year, index + 1, 1);
            final isPast = monthDate.isBefore(DateTime(now.year, now.month, 1));
            
            return InkWell(
              onTap: isPast ? null : () {
                // Select first day of the month
                widget.onDateSelected(DateTime(now.year, index + 1, 1));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? (isPast 
                          ? Colors.grey.shade800.withOpacity(0.2)
                          : Colors.grey.shade800.withOpacity(0.5))
                      : (isPast 
                          ? Colors.grey.shade100
                          : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    months[index],
                    style: TextStyle(
                      color: isPast 
                          ? (isDark ? Colors.white30 : Colors.grey.shade400)
                          : (isDark ? Colors.white : Colors.black87),
                      fontWeight: FontWeight.w500,
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

  Widget _buildFlexibleOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fleksibel booking',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vis kokke der er tilgængelige i en periode',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white60 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        ..._buildFlexibleOptionTiles(context),
      ],
    );
  }

  List<Widget> _buildFlexibleOptionTiles(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    
    final options = [
      {
        'title': 'Denne weekend',
        'subtitle': 'Lørdag eller søndag',
        'icon': Icons.weekend,
      },
      {
        'title': 'Næste uge',
        'subtitle': 'Mandag til søndag',
        'icon': Icons.date_range,
      },
      {
        'title': 'Denne måned',
        'subtitle': _getMonthYear(now),
        'icon': Icons.calendar_month,
      },
      {
        'title': 'Næste 3 måneder',
        'subtitle': 'Fleksibel periode',
        'icon': Icons.calendar_view_month,
      },
    ];
    
    return options.map((option) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // For now, just select today as a placeholder
          widget.onDateSelected(DateTime.now());
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.grey.shade800.withOpacity(0.3)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark 
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  option['icon'] as IconData,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    )).toList();
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
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hvad tid skal kokken starte?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vælg det tidspunkt hvor kokken skal ankomme',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white60 : Colors.grey.shade600,
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
                    color: isDark 
                        ? Colors.grey.shade900.withOpacity(0.5)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark 
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        selectedTime ?? '--:--',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 72,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selectedTime != null ? 'Starttidspunkt' : 'Ingen tid valgt',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
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
                              backgroundColor: isDark ? const Color(0xFF252325) : Colors.white,
                              hourMinuteShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              dayPeriodShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hourMinuteTextColor: isDark ? Colors.white : Colors.black87,
                              hourMinuteColor: isDark 
                                  ? Colors.grey.shade800.withOpacity(0.5)
                                  : Colors.grey.shade100,
                              dayPeriodTextColor: isDark ? Colors.white : Colors.black87,
                              dayPeriodColor: isDark 
                                  ? Colors.grey.shade800.withOpacity(0.5)
                                  : Colors.grey.shade100,
                              dialHandColor: theme.colorScheme.primary,
                              dialBackgroundColor: isDark 
                                  ? Colors.grey.shade900.withOpacity(0.5)
                                  : Colors.grey.shade50,
                              dialTextColor: isDark ? Colors.white : Colors.black87,
                              entryModeIconColor: theme.colorScheme.primary,
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
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['12:00', '17:00', '18:00', '19:00'].map((time) {
                  final isSelected = selectedTime == time;
                  return GestureDetector(
                    onTap: () {
                      onTimeSelected(isSelected ? null : time);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark 
                                ? Colors.grey.shade800.withOpacity(0.5)
                                : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark 
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            time,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected 
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
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
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hvor lang tid skal kokken være der?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inkluderer forberedelse, servering og oprydning',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white60 : Colors.grey.shade600,
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
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : (isDark 
                              ? Colors.grey.shade800.withOpacity(0.5)
                              : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark 
                                ? Colors.grey.shade700
                                : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: isSelected 
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.grey.shade600),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$hours timer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected 
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 22,
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
    final isDark = theme.brightness == Brightness.dark;
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
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hvor mange personer skal kokken lave mad til?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Enhanced Guest Counter Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        theme.colorScheme.primaryContainer.withOpacity(0.15),
                        theme.colorScheme.primaryContainer.withOpacity(0.05),
                      ]
                    : [
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                        theme.colorScheme.primaryContainer.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Guest Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.people,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Counter Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Minus Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: currentCount > 1
                            ? () => onGuestCountChanged(currentCount - 1)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: currentCount > 1
                                ? (isDark 
                                    ? Colors.grey.shade800.withOpacity(0.5)
                                    : Colors.white)
                                : (isDark 
                                    ? Colors.grey.shade800.withOpacity(0.2)
                                    : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: currentCount > 1
                                  ? (isDark 
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: currentCount > 1
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white30 : Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ),
                    
                    // Number Display
                    Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            '$currentCount',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentCount == 1 ? 'person' : 'personer',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Plus Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: currentCount < 20
                            ? () => onGuestCountChanged(currentCount + 1)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: currentCount < 20
                                ? theme.colorScheme.primary
                                : (isDark 
                                    ? Colors.grey.shade800.withOpacity(0.2)
                                    : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.add,
                            color: currentCount < 20
                                ? Colors.white
                                : (isDark ? Colors.white30 : Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Quick selection options with better styling
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Populære valg',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [2, 4, 6, 8, 10].map((count) {
                  final isSelected = numberOfGuests == count;
                  return GestureDetector(
                    onTap: () => onGuestCountChanged(isSelected ? null : count),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark 
                                ? Colors.grey.shade800.withOpacity(0.5)
                                : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark 
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected 
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                          fontSize: 15,
                        ),
                      ),
                    ),
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