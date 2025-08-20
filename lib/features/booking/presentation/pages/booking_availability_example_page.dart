import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../providers/booking_availability_providers.dart';
import '../providers/recurring_booking_providers.dart';

/// Example page demonstrating how to use the BookingAvailabilityService system
/// This shows integration of all the services and providers
class BookingAvailabilityExamplePage extends ConsumerStatefulWidget {
  final String chefId;

  const BookingAvailabilityExamplePage({
    super.key,
    required this.chefId,
  });

  @override
  ConsumerState<BookingAvailabilityExamplePage> createState() =>
      _BookingAvailabilityExamplePageState();
}

class _BookingAvailabilityExamplePageState
    extends ConsumerState<BookingAvailabilityExamplePage> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  bool _isRecurring = false;
  RecurrenceType? _recurrenceType;

  @override
  void initState() {
    super.initState();
    // Set initial chef selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingSelectionProvider.notifier).selectChef(widget.chefId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingSelection = ref.watch(bookingSelectionProvider);
    final availableTimeSlots = ref.watch(availableTimeSlotsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Chef'),
        elevation: 1,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) {
          if (step <= _getMaxAllowedStep()) {
            setState(() {
              _currentStep = step;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Select Date & Guests'),
            content: _buildDateGuestsStep(bookingSelection),
            isActive: _currentStep >= 0,
            state: _getStepState(0, bookingSelection.selectedDate != null),
          ),
          Step(
            title: const Text('Choose Time Slot'),
            content: _buildTimeSlotStep(availableTimeSlots),
            isActive: _currentStep >= 1,
            state: _getStepState(1, bookingSelection.selectedTimeSlot != null),
          ),
          Step(
            title: const Text('Booking Options'),
            content: _buildBookingOptionsStep(),
            isActive: _currentStep >= 2,
            state: _getStepState(2, true),
          ),
          Step(
            title: const Text('Confirm Booking'),
            content: _buildConfirmationStep(bookingSelection),
            isActive: _currentStep >= 3,
            state: _getStepState(3, false),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(bookingSelection),
    );
  }

  Widget _buildDateGuestsStep(BookingSelectionState bookingSelection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        CalendarDatePicker(
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 180)),
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
            ref.read(bookingSelectionProvider.notifier).selectDate(date);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Number of Guests',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              onPressed: bookingSelection.guestCount > 1
                  ? () => ref.read(bookingSelectionProvider.notifier)
                      .setGuestCount(bookingSelection.guestCount - 1)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${bookingSelection.guestCount}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              onPressed: bookingSelection.guestCount < 20
                  ? () => ref.read(bookingSelectionProvider.notifier)
                      .setGuestCount(bookingSelection.guestCount + 1)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Duration',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Duration>(
          value: bookingSelection.duration,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(
              value: Duration(hours: 2),
              child: Text('2 hours'),
            ),
            DropdownMenuItem(
              value: Duration(hours: 3),
              child: Text('3 hours'),
            ),
            DropdownMenuItem(
              value: Duration(hours: 4),
              child: Text('4 hours'),
            ),
            DropdownMenuItem(
              value: Duration(hours: 5),
              child: Text('5 hours'),
            ),
          ],
          onChanged: (duration) {
            if (duration != null) {
              ref.read(bookingSelectionProvider.notifier).setDuration(duration);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlotStep(AsyncValue<List<TimeSlot>> availableTimeSlots) {
    return availableTimeSlots.when(
      data: (slots) {
        final availableSlots = slots.where((slot) => slot.isAvailable).toList();
        
        if (availableSlots.isEmpty) {
          return Column(
            children: [
              const Icon(Icons.schedule, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No time slots available for the selected date',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  ref.read(nextAvailableSlotProvider.notifier).getNextAvailableSlot(
                    chefId: widget.chefId,
                    afterDate: _selectedDate ?? DateTime.now(),
                    duration: ref.read(bookingSelectionProvider).duration,
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Find Next Available Slot'),
              ),
              _buildNextAvailableSlot(),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Time Slots for ${DateFormat.yMMMd().format(_selectedDate!)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableSlots.length,
              itemBuilder: (context, index) {
                final slot = availableSlots[index];
                final isSelected = _selectedTimeSlot == slot;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  child: ListTile(
                    title: Text(
                      '${DateFormat.jm().format(slot.startTime)} - ${DateFormat.jm().format(slot.endTime)}',
                    ),
                    subtitle: Text('Duration: ${slot.duration.inHours}h ${slot.duration.inMinutes % 60}m'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.radio_button_unchecked),
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = slot;
                      });
                      ref.read(bookingSelectionProvider.notifier).selectTimeSlot(slot);
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Column(
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading time slots: $error',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextAvailableSlot() {
    final nextSlot = ref.watch(nextAvailableSlotProvider);
    
    return nextSlot.when(
      data: (slot) {
        if (slot == null) {
          return const Text('No available slots found in the next 30 days');
        }
        
        return Card(
          color: Colors.blue.withOpacity(0.1),
          child: ListTile(
            leading: const Icon(Icons.lightbulb, color: Colors.blue),
            title: const Text('Suggested Next Available Slot'),
            subtitle: Text(
              '${DateFormat.yMMMd().format(slot.startTime)} at ${DateFormat.jm().format(slot.startTime)}',
            ),
            trailing: TextButton(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(
                    slot.startTime.year,
                    slot.startTime.month,
                    slot.startTime.day,
                  );
                  _selectedTimeSlot = slot;
                });
                ref.read(bookingSelectionProvider.notifier).selectDate(_selectedDate!);
                ref.read(bookingSelectionProvider.notifier).selectTimeSlot(slot);
              },
              child: const Text('Select'),
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _buildBookingOptionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Type',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Recurring Booking'),
          subtitle: const Text('Set up a regular schedule'),
          value: _isRecurring,
          onChanged: (value) {
            setState(() {
              _isRecurring = value;
              if (!value) {
                _recurrenceType = null;
              }
            });
          },
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          Text(
            'Recurrence Pattern',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<RecurrenceType>(
            value: _recurrenceType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select recurrence pattern',
            ),
            items: RecurrenceType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getRecurrenceTypeLabel(type)),
              );
            }).toList(),
            onChanged: (type) {
              setState(() {
                _recurrenceType = type;
              });
            },
          ),
          if (_recurrenceType != null) ...[
            const SizedBox(height: 16),
            _buildRecurringPreview(),
          ],
        ],
      ],
    );
  }

  Widget _buildRecurringPreview() {
    if (_recurrenceType == null || _selectedDate == null) {
      return const SizedBox();
    }

    final pattern = RecurrencePattern(
      type: _recurrenceType!,
      startDate: _selectedDate!,
      maxOccurrences: 8, // Show first 8 occurrences
    );

    final recurringGenerator = ref.watch(recurringPatternGeneratorProvider);

    // Generate occurrences when pattern changes
    ref.listen(recurringPatternGeneratorProvider, (_, __) {});
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringPatternGeneratorProvider.notifier).generateOccurrences(
        pattern: pattern,
        startDate: _selectedDate!,
      );
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurring Dates Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            recurringGenerator.when(
              data: (occurrences) {
                return Column(
                  children: occurrences.take(8).map((date) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.event, size: 20),
                      title: Text(
                        DateFormat.yMMMd().format(date),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text(
                'Error generating dates: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep(BookingSelectionState bookingSelection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Summary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Chef', 'Chef ${widget.chefId}'),
                _buildSummaryRow('Date', 
                  _selectedDate != null ? DateFormat.yMMMd().format(_selectedDate!) : 'Not selected'),
                _buildSummaryRow('Time', 
                  _selectedTimeSlot != null 
                    ? '${DateFormat.jm().format(_selectedTimeSlot!.startTime)} - ${DateFormat.jm().format(_selectedTimeSlot!.endTime)}'
                    : 'Not selected'),
                _buildSummaryRow('Guests', '${bookingSelection.guestCount}'),
                _buildSummaryRow('Duration', '${bookingSelection.duration.inHours}h ${bookingSelection.duration.inMinutes % 60}m'),
                if (_isRecurring && _recurrenceType != null) ...[
                  const Divider(),
                  _buildSummaryRow('Recurring', _getRecurrenceTypeLabel(_recurrenceType!)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canConfirmBooking(bookingSelection) ? _confirmBooking : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: Text(
              _isRecurring ? 'Create Recurring Booking' : 'Confirm Booking',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BookingSelectionState bookingSelection) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _canProceedToNextStep(bookingSelection)
                  ? () {
                      if (_currentStep < 3) {
                        setState(() {
                          _currentStep++;
                        });
                        _onStepChanged();
                      }
                    }
                  : null,
              child: Text(_currentStep == 3 ? 'Finish' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _onStepChanged() {
    if (_currentStep == 1 && _selectedDate != null) {
      // Load available time slots when moving to time slot step
      ref.read(availableTimeSlotsProvider.notifier).getAvailableTimeSlots(
        chefId: widget.chefId,
        date: _selectedDate!,
        duration: ref.read(bookingSelectionProvider).duration,
        numberOfGuests: ref.read(bookingSelectionProvider).guestCount,
      );
    }
  }

  bool _canProceedToNextStep(BookingSelectionState bookingSelection) {
    switch (_currentStep) {
      case 0:
        return bookingSelection.selectedDate != null;
      case 1:
        return bookingSelection.selectedTimeSlot != null;
      case 2:
        return true; // Options step is always valid
      case 3:
        return _canConfirmBooking(bookingSelection);
      default:
        return false;
    }
  }

  bool _canConfirmBooking(BookingSelectionState bookingSelection) {
    return bookingSelection.hasCompleteSelection &&
           (!_isRecurring || _recurrenceType != null);
  }

  int _getMaxAllowedStep() {
    if (_selectedDate == null) return 0;
    if (_selectedTimeSlot == null) return 1;
    return 3;
  }

  StepState _getStepState(int stepIndex, bool isCompleted) {
    if (stepIndex < _currentStep) {
      return isCompleted ? StepState.complete : StepState.disabled;
    } else if (stepIndex == _currentStep) {
      return StepState.editing;
    } else {
      return StepState.disabled;
    }
  }

  String _getRecurrenceTypeLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.biWeekly:
        return 'Every 2 weeks';
      case RecurrenceType.every3Weeks:
        return 'Every 3 weeks';
      case RecurrenceType.monthly:
        return 'Monthly';
    }
  }

  void _confirmBooking() {
    final bookingSelection = ref.read(bookingSelectionProvider);
    
    if (_isRecurring && _recurrenceType != null && _selectedDate != null) {
      // Create recurring booking
      final pattern = RecurrencePattern(
        type: _recurrenceType!,
        startDate: _selectedDate!,
        maxOccurrences: 12, // 1 year
      );

      final bookingRequest = bookingSelection.toBookingRequest(
        userId: 'current-user-id', // This should come from auth
      );

      if (bookingRequest != null) {
        ref.read(recurringBookingCreatorProvider.notifier).createRecurringSeries(
          bookingRequest: bookingRequest,
          pattern: pattern,
        );
      }
    } else {
      // Create single booking
      // Implementation would go here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Single booking created successfully!')),
      );
    }

    // Navigate back or show success
    Navigator.of(context).pop();
  }
}