import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_modification.dart';
import '../../../core/constants/spacing.dart';

class ModificationRequestForm extends ConsumerStatefulWidget {
  final String bookingId;
  final DateTime currentBookingDate;
  final int currentGuestCount;
  final List<String> currentDishes;
  final String? currentSpecialRequests;
  final Function(BookingModificationRequest) onSubmit;
  final VoidCallback? onCancel;

  const ModificationRequestForm({
    Key? key,
    required this.bookingId,
    required this.currentBookingDate,
    required this.currentGuestCount,
    required this.currentDishes,
    this.currentSpecialRequests,
    required this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<ModificationRequestForm> createState() => _ModificationRequestFormState();
}

class _ModificationRequestFormState extends ConsumerState<ModificationRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  // Form state
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  int? _selectedGuestCount;
  List<String> _selectedDishes = [];
  bool _isEmergencyRequest = false;
  
  // UI state
  bool _showDeadlineWarning = false;
  Duration? _timeUntilDeadline;
  
  // Available modification types
  final Map<ChangeType, bool> _changeTypes = {
    ChangeType.dateTime: false,
    ChangeType.guestCount: false,
    ChangeType.dishes: false,
    ChangeType.specialRequests: false,
  };

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _calculateDeadlineWarning();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    _selectedDate = widget.currentBookingDate;
    _selectedStartTime = TimeOfDay.fromDateTime(widget.currentBookingDate);
    _selectedEndTime = TimeOfDay.fromDateTime(
      widget.currentBookingDate.add(const Duration(hours: 3)),
    );
    _selectedGuestCount = widget.currentGuestCount;
    _selectedDishes = List.from(widget.currentDishes);
    _specialRequestsController.text = widget.currentSpecialRequests ?? '';
  }

  void _calculateDeadlineWarning() {
    final now = DateTime.now();
    final deadline = widget.currentBookingDate.subtract(const Duration(hours: 24));
    
    if (now.isAfter(deadline)) {
      _showDeadlineWarning = true;
      _timeUntilDeadline = widget.currentBookingDate.difference(now);
    } else {
      _timeUntilDeadline = deadline.difference(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Booking'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          TextButton(
            onPressed: _canSubmit() ? _submitForm : null,
            child: const Text('Submit Request'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deadline warning
              if (_showDeadlineWarning) _buildDeadlineWarning(theme),
              
              const SizedBox(height: Spacing.medium),
              
              // Modification types selection
              _buildModificationTypesSection(theme),
              
              const SizedBox(height: Spacing.large),
              
              // Date and time modification
              if (_changeTypes[ChangeType.dateTime] == true)
                _buildDateTimeSection(theme),
              
              // Guest count modification
              if (_changeTypes[ChangeType.guestCount] == true)
                _buildGuestCountSection(theme),
              
              // Dishes modification
              if (_changeTypes[ChangeType.dishes] == true)
                _buildDishesSection(theme),
              
              // Special requests modification
              if (_changeTypes[ChangeType.specialRequests] == true)
                _buildSpecialRequestsSection(theme),
              
              const SizedBox(height: Spacing.large),
              
              // Reason for modification
              _buildReasonSection(theme),
              
              const SizedBox(height: Spacing.medium),
              
              // Emergency request checkbox
              if (_showDeadlineWarning) _buildEmergencyCheckbox(theme),
              
              const SizedBox(height: Spacing.large),
              
              // Submit button
              _buildSubmitButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineWarning(ThemeData theme) {
    final isWithin24Hours = _timeUntilDeadline != null && 
                           _timeUntilDeadline!.inHours <= 24;
    
    return Container(
      padding: const EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: isWithin24Hours 
            ? theme.colorScheme.error.withOpacity(0.1)
            : theme.colorScheme.tertiary.withOpacity(0.1),
        border: Border.all(
          color: isWithin24Hours 
              ? theme.colorScheme.error
              : theme.colorScheme.tertiary,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isWithin24Hours ? Icons.warning : Icons.info,
            color: isWithin24Hours 
                ? theme.colorScheme.error
                : theme.colorScheme.tertiary,
          ),
          const SizedBox(width: Spacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWithin24Hours 
                      ? 'Late Modification Request'
                      : 'Modification Deadline',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWithin24Hours 
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWithin24Hours
                      ? 'Your booking is in ${_timeUntilDeadline!.inHours} hours. Late modifications may incur additional fees and require chef approval.'
                      : 'You have ${_timeUntilDeadline!.inHours} hours to modify your booking without additional fees.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModificationTypesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to modify?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.small),
        Text(
          'Select the aspects of your booking you\'d like to change:',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: Spacing.medium),
        ...ChangeType.values.map((type) => CheckboxListTile(
          title: Text(_getChangeTypeDisplayName(type)),
          subtitle: Text(_getChangeTypeDescription(type)),
          value: _changeTypes[type],
          onChanged: (value) {
            setState(() {
              _changeTypes[type] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        )),
      ],
    );
  }

  Widget _buildDateTimeSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Date & Time',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.medium),
            
            // Date picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(_formatDate(_selectedDate!)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _pickDate,
              contentPadding: EdgeInsets.zero,
            ),
            
            const Divider(),
            
            // Time pickers
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Start Time'),
                    subtitle: Text(_selectedStartTime!.format(context)),
                    onTap: () => _pickTime(true),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time_filled),
                    title: const Text('End Time'),
                    subtitle: Text(_selectedEndTime!.format(context)),
                    onTap: () => _pickTime(false),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCountSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of Guests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.medium),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current: ${widget.currentGuestCount} guests',
                  style: theme.textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _selectedGuestCount! > 1 ? () {
                        setState(() => _selectedGuestCount = _selectedGuestCount! - 1);
                      } : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.medium,
                        vertical: Spacing.small,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedGuestCount.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _selectedGuestCount! < 20 ? () {
                        setState(() => _selectedGuestCount = _selectedGuestCount! + 1);
                      } : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
            
            if (_selectedGuestCount != widget.currentGuestCount) ...[
              const SizedBox(height: Spacing.small),
              Container(
                padding: const EdgeInsets.all(Spacing.small),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedGuestCount! > widget.currentGuestCount
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: Spacing.small),
                    Text(
                      _selectedGuestCount! > widget.currentGuestCount
                          ? 'Adding ${_selectedGuestCount! - widget.currentGuestCount} guests'
                          : 'Reducing by ${widget.currentGuestCount - _selectedGuestCount!} guests',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDishesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu Selection',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.medium),
            
            Text(
              'Current dishes: ${widget.currentDishes.length}',
              style: theme.textTheme.bodyMedium,
            ),
            
            const SizedBox(height: Spacing.small),
            
            ElevatedButton.icon(
              onPressed: () {
                // This would open a dish selection dialog
                _showDishSelectionDialog();
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Select New Dishes'),
            ),
            
            if (_selectedDishes.isNotEmpty && 
                !_listEquals(_selectedDishes, widget.currentDishes)) ...[
              const SizedBox(height: Spacing.medium),
              Container(
                padding: const EdgeInsets.all(Spacing.small),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected dishes: ${_selectedDishes.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Would list the selected dishes here
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialRequestsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Special Requests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.medium),
            
            TextFormField(
              controller: _specialRequestsController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any dietary restrictions, preferences, or special requests...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reason for Modification',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.small),
            Text(
              'Please explain why you need to modify your booking',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: Spacing.medium),
            
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a reason for the modification';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Describe the reason for your modification request...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCheckbox(ThemeData theme) {
    return Card(
      color: theme.colorScheme.error.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          children: [
            CheckboxListTile(
              title: Text(
                'This is an emergency request',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Emergency requests may be approved past the 24-hour deadline but may incur additional fees',
              ),
              value: _isEmergencyRequest,
              onChanged: (value) {
                setState(() {
                  _isEmergencyRequest = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canSubmit() ? _submitForm : null,
        icon: const Icon(Icons.send),
        label: Text(_showDeadlineWarning ? 'Submit Late Request' : 'Submit Request'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(Spacing.medium),
        ),
      ),
    );
  }

  // Helper methods

  String _getChangeTypeDisplayName(ChangeType type) {
    switch (type) {
      case ChangeType.dateTime:
        return 'Date & Time';
      case ChangeType.guestCount:
        return 'Number of Guests';
      case ChangeType.dishes:
        return 'Menu/Dishes';
      case ChangeType.specialRequests:
        return 'Special Requests';
      default:
        return type.name;
    }
  }

  String _getChangeTypeDescription(ChangeType type) {
    switch (type) {
      case ChangeType.dateTime:
        return 'Change the date or time of your booking';
      case ChangeType.guestCount:
        return 'Increase or decrease number of guests';
      case ChangeType.dishes:
        return 'Modify selected dishes or menu';
      case ChangeType.specialRequests:
        return 'Update dietary restrictions or preferences';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 
                     'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  bool _canSubmit() {
    return _changeTypes.values.any((selected) => selected) &&
           _reasonController.text.trim().isNotEmpty;
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _pickTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _selectedStartTime! : _selectedEndTime!,
    );
    
    if (time != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = time;
        } else {
          _selectedEndTime = time;
        }
      });
    }
  }

  void _showDishSelectionDialog() {
    // This would open a dialog to select dishes
    // Implementation would depend on available dishes
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    
    final changes = <BookingChange>[];
    
    // Add changes based on selected modification types
    if (_changeTypes[ChangeType.dateTime] == true) {
      final newDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );
      
      if (newDateTime != widget.currentBookingDate) {
        changes.add(BookingChange(
          type: ChangeType.dateTime,
          fieldName: 'dateTime',
          oldValue: widget.currentBookingDate,
          newValue: newDateTime,
          description: 'Change booking date and time',
        ));
      }
    }
    
    if (_changeTypes[ChangeType.guestCount] == true && 
        _selectedGuestCount != widget.currentGuestCount) {
      changes.add(BookingChange(
        type: ChangeType.guestCount,
        fieldName: 'guestCount',
        oldValue: widget.currentGuestCount,
        newValue: _selectedGuestCount!,
        description: 'Change number of guests',
      ));
    }
    
    if (_changeTypes[ChangeType.dishes] == true && 
        !_listEquals(_selectedDishes, widget.currentDishes)) {
      changes.add(BookingChange(
        type: ChangeType.dishes,
        fieldName: 'dishes',
        oldValue: widget.currentDishes,
        newValue: _selectedDishes,
        description: 'Modify selected dishes',
      ));
    }
    
    if (_changeTypes[ChangeType.specialRequests] == true && 
        _specialRequestsController.text.trim() != widget.currentSpecialRequests?.trim()) {
      changes.add(BookingChange(
        type: ChangeType.specialRequests,
        fieldName: 'specialRequests',
        oldValue: widget.currentSpecialRequests,
        newValue: _specialRequestsController.text.trim(),
        description: 'Update special requests',
      ));
    }
    
    final request = BookingModificationRequest(
      bookingId: widget.bookingId,
      requestedBy: 'current_user_id', // Would be actual user ID
      requestedAt: DateTime.now(),
      changes: changes,
      reason: _reasonController.text.trim(),
      isEmergencyRequest: _isEmergencyRequest,
    );
    
    widget.onSubmit(request);
  }
}