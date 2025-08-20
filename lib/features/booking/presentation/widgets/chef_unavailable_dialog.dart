import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chef_alternative.dart';
import '../../domain/services/chef_unavailability_handler.dart';
import '../../../core/constants/spacing.dart';

class ChefUnavailableDialog extends ConsumerStatefulWidget {
  final String bookingId;
  final UnavailabilityReason reason;
  final List<ChefAlternative> alternatives;
  final List<ReschedulingOption> reschedulingOptions;
  final VoidCallback? onDismiss;
  final Function(String resolutionType, Map<String, dynamic> data)? onResolutionSelected;

  const ChefUnavailableDialog({
    Key? key,
    required this.bookingId,
    required this.reason,
    this.alternatives = const [],
    this.reschedulingOptions = const [],
    this.onDismiss,
    this.onResolutionSelected,
  }) : super(key: key);

  @override
  ConsumerState<ChefUnavailableDialog> createState() => _ChefUnavailableDialogState();
}

class _ChefUnavailableDialogState extends ConsumerState<ChefUnavailableDialog> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  ChefAlternative? _selectedAlternative;
  ReschedulingOption? _selectedRescheduling;

  @override
  void initState() {
    super.initState();
    
    // Determine which tabs to show
    final tabCount = _calculateTabCount();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculateTabCount() {
    int count = 1; // Always show "What happened" tab
    if (widget.alternatives.isNotEmpty) count++;
    if (widget.reschedulingOptions.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: theme.colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: Spacing.small),
                Expanded(
                  child: Text(
                    'Chef Unavailable',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
            
            const SizedBox(height: Spacing.medium),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              onTap: (index) => setState(() => _selectedTabIndex = index),
              tabs: _buildTabs(),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: theme.colorScheme.primary,
            ),
            
            const SizedBox(height: Spacing.medium),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _buildTabViews(),
              ),
            ),
            
            const SizedBox(height: Spacing.medium),
            
            // Action buttons
            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  List<Tab> _buildTabs() {
    final tabs = <Tab>[
      const Tab(text: 'What Happened'),
    ];
    
    if (widget.alternatives.isNotEmpty) {
      tabs.add(const Tab(text: 'Alternative Chefs'));
    }
    
    if (widget.reschedulingOptions.isNotEmpty) {
      tabs.add(const Tab(text: 'Reschedule'));
    }
    
    return tabs;
  }

  List<Widget> _buildTabViews() {
    final views = <Widget>[
      _buildReasonView(),
    ];
    
    if (widget.alternatives.isNotEmpty) {
      views.add(_buildAlternativesView());
    }
    
    if (widget.reschedulingOptions.isNotEmpty) {
      views.add(_buildReschedulingView());
    }
    
    return views;
  }

  Widget _buildReasonView() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: theme.colorScheme.errorContainer.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.medium),
              child: Row(
                children: [
                  Icon(
                    _getReasonIcon(widget.reason.type),
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: Spacing.small),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reason.type.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: Spacing.small),
                        Text(
                          widget.reason.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: Spacing.large),
          
          if (widget.reason.isEmergency) ...[
            Container(
              padding: const EdgeInsets.all(Spacing.medium),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.priority_high,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.small),
                  Expanded(
                    child: Text(
                      'This is an emergency situation. We\'re working quickly to find you the best solution.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Spacing.medium),
          ],
          
          Text(
            'We sincerely apologize for this inconvenience. We understand how important your booking is and we\'re committed to finding you the best possible solution.',
            style: theme.textTheme.bodyMedium,
          ),
          
          const SizedBox(height: Spacing.medium),
          
          Text(
            'Please review the options below:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesView() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alternative Chefs Available',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: Spacing.small),
        
        Text(
          'We\'ve found ${widget.alternatives.length} qualified chefs who can take your booking:',
          style: theme.textTheme.bodyMedium,
        ),
        
        const SizedBox(height: Spacing.medium),
        
        Expanded(
          child: ListView.builder(
            itemCount: widget.alternatives.length,
            itemBuilder: (context, index) {
              final alternative = widget.alternatives[index];
              final isSelected = _selectedAlternative == alternative;
              
              return Card(
                margin: const EdgeInsets.only(bottom: Spacing.small),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAlternative = isSelected ? null : alternative;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.medium),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Chef image
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: alternative.profileImageUrl.isNotEmpty
                              ? NetworkImage(alternative.profileImageUrl)
                              : null,
                          child: alternative.profileImageUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        
                        const SizedBox(width: Spacing.medium),
                        
                        // Chef details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    alternative.chefName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: Spacing.small),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getMatchScoreColor(alternative.matchScore.overallScore),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      alternative.matchScore.matchGrade,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: Spacing.small),
                              
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${alternative.rating} (${alternative.reviewCount} reviews)',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: Spacing.medium),
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${alternative.distanceKm.toStringAsFixed(1)} km away',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: Spacing.small),
                              
                              Text(
                                'Cuisines: ${alternative.cuisines.join(', ')}',
                                style: theme.textTheme.bodySmall,
                              ),
                              
                              if (alternative.hourlyRate != 0) ...[
                                const SizedBox(height: Spacing.small),
                                Text(
                                  '${alternative.hourlyRate.toStringAsFixed(0)} DKK/hour',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Selection indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReschedulingView() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reschedule with Same Chef',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: Spacing.small),
        
        Text(
          'Your chef is available on these alternative dates:',
          style: theme.textTheme.bodyMedium,
        ),
        
        const SizedBox(height: Spacing.medium),
        
        Expanded(
          child: ListView.builder(
            itemCount: widget.reschedulingOptions.length,
            itemBuilder: (context, index) {
              final option = widget.reschedulingOptions[index];
              final isSelected = _selectedRescheduling == option;
              
              return Card(
                margin: const EdgeInsets.only(bottom: Spacing.small),
                child: InkWell(
                  onTap: option.isAvailable ? () {
                    setState(() {
                      _selectedRescheduling = isSelected ? null : option;
                    });
                  } : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.medium),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Date and time
                        Container(
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(option.dateTime),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                option.timeSlot,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: Spacing.medium),
                        
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: option.isAvailable 
                                          ? Colors.green 
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      option.isAvailable ? 'Available' : 'Unavailable',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: Spacing.small),
                                  Text(
                                    '${(option.probabilityScore * 100).round()}% match',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              
                              if (option.notes != null) ...[
                                const SizedBox(height: Spacing.small),
                                Text(
                                  option.notes!,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                              
                              if (option.priceDifference != null && option.priceDifference != 0) ...[
                                const SizedBox(height: Spacing.small),
                                Text(
                                  option.priceDifference! > 0 
                                      ? '+${option.priceDifference! / 100} DKK'
                                      : '${option.priceDifference! / 100} DKK',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: option.priceDifference! > 0 
                                        ? theme.colorScheme.error
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Selection indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Cancel booking button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              widget.onResolutionSelected?.call('cancel', {'booking_id': widget.bookingId});
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel Booking'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ),
        
        const SizedBox(width: Spacing.medium),
        
        // Accept solution button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _canProceed() ? () {
              _handleAcceptSolution();
            } : null,
            icon: const Icon(Icons.check_circle),
            label: Text(_getAcceptButtonText()),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getReasonIcon(UnavailabilityType type) {
    switch (type) {
      case UnavailabilityType.illness:
        return Icons.sick;
      case UnavailabilityType.familyEmergency:
        return Icons.family_restroom;
      case UnavailabilityType.equipmentFailure:
        return Icons.build_circle;
      case UnavailabilityType.doubleBooking:
        return Icons.event_busy;
      case UnavailabilityType.personalReasons:
        return Icons.person_off;
      case UnavailabilityType.travelDelay:
        return Icons.traffic;
      case UnavailabilityType.weatherConditions:
        return Icons.cloud;
      case UnavailabilityType.kitchenUnavailable:
        return Icons.kitchen;
      default:
        return Icons.warning;
    }
  }

  Color _getMatchScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  bool _canProceed() {
    if (_selectedTabIndex == 1 && widget.alternatives.isNotEmpty) {
      return _selectedAlternative != null;
    }
    if (_selectedTabIndex == 2 && widget.reschedulingOptions.isNotEmpty) {
      return _selectedRescheduling != null;
    }
    return false;
  }

  String _getAcceptButtonText() {
    if (_selectedTabIndex == 1 && _selectedAlternative != null) {
      return 'Book ${_selectedAlternative!.chefName}';
    }
    if (_selectedTabIndex == 2 && _selectedRescheduling != null) {
      return 'Reschedule Booking';
    }
    return 'Select Option';
  }

  void _handleAcceptSolution() {
    if (_selectedTabIndex == 1 && _selectedAlternative != null) {
      widget.onResolutionSelected?.call('alternative_chef', {
        'booking_id': widget.bookingId,
        'chef_id': _selectedAlternative!.chefId,
        'chef_name': _selectedAlternative!.chefName,
      });
    } else if (_selectedTabIndex == 2 && _selectedRescheduling != null) {
      widget.onResolutionSelected?.call('reschedule', {
        'booking_id': widget.bookingId,
        'new_date_time': _selectedRescheduling!.dateTime.toIso8601String(),
        'new_time_slot': _selectedRescheduling!.timeSlot,
      });
    }
  }
}