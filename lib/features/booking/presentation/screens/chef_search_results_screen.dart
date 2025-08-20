import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../widgets/chef_card.dart';
import '../../../../widgets/custom_button.dart';
import 'package:homechef/models/chef.dart';
import '../../domain/entities/time_slot.dart';
import '../providers/booking_availability_providers.dart';

class ChefSearchResultsScreen extends ConsumerStatefulWidget {
  final List<Chef> allChefs;
  final Function(Chef) onChefSelected;

  const ChefSearchResultsScreen({
    super.key,
    required this.allChefs,
    required this.onChefSelected,
  });

  @override
  ConsumerState<ChefSearchResultsScreen> createState() => _ChefSearchResultsScreenState();
}

class _ChefSearchResultsScreenState extends ConsumerState<ChefSearchResultsScreen> {
  DateTime? selectedDate;
  TimeSlot? selectedTimeSlot;
  Duration selectedDuration = const Duration(hours: 3);
  int numberOfGuests = 2;
  List<Chef> availableChefs = [];
  bool isSearchingAvailability = false;
  String selectedSortOption = 'rating'; // rating, price, distance
  List<String> selectedCuisines = [];
  RangeValues priceRange = const RangeValues(200, 800);

  @override
  void initState() {
    super.initState();
    availableChefs = widget.allChefs;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find kokke'), // Find chefs
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search filters
          _buildSearchFilters(theme),
          
          // Results
          Expanded(
            child: _buildSearchResults(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters(ThemeData theme) {
    return Container(
      padding: AppSpacing.screenPaddingHorizontal,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time selector
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(theme),
              ),
              AppSpacing.horizontalSpace12,
              Expanded(
                child: _buildTimeSelector(theme),
              ),
            ],
          ),
          AppSpacing.verticalSpace12,
          
          // Duration and guests
          Row(
            children: [
              Expanded(
                child: _buildDurationSelector(theme),
              ),
              AppSpacing.horizontalSpace12,
              Expanded(
                child: _buildGuestSelector(theme),
              ),
            ],
          ),
          AppSpacing.verticalSpace16,
          
          // Search button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isSearchingAvailability ? 'Søger...' : 'Søg tilgængelige kokke',
              onPressed: isSearchingAvailability ? null : _searchAvailableChefs,
              variant: ButtonVariant.primary,
              isLoading: isSearchingAvailability,
            ),
          ),
          AppSpacing.verticalSpace16,
        ],
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dato', // Date
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            AppSpacing.verticalSpace4,
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                AppSpacing.horizontalSpace8,
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat.MMMd('da').format(selectedDate!)
                        : 'Vælg dato',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selectedDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(ThemeData theme) {
    return InkWell(
      onTap: selectedDate != null ? () => _showTimeSelector(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedDate != null 
                ? theme.colorScheme.outline 
                : theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tid', // Time
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            AppSpacing.verticalSpace4,
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: selectedDate != null 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                AppSpacing.horizontalSpace8,
                Expanded(
                  child: Text(
                    selectedTimeSlot != null
                        ? '${DateFormat.Hm().format(selectedTimeSlot!.startTime)}'
                        : 'Vælg tid',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selectedTimeSlot != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Varighed', // Duration
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.verticalSpace4,
          DropdownButton<Duration>(
            value: selectedDuration,
            isExpanded: true,
            underline: const SizedBox(),
            items: [
              const Duration(hours: 2),
              const Duration(hours: 3),
              const Duration(hours: 4),
              const Duration(hours: 5),
              const Duration(hours: 6),
            ].map((duration) => DropdownMenuItem(
              value: duration,
              child: Text('${duration.inHours} timer'),
            )).toList(),
            onChanged: (duration) {
              if (duration != null) {
                setState(() {
                  selectedDuration = duration;
                  selectedTimeSlot = null; // Reset time slot
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gæster', // Guests
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.verticalSpace4,
          Row(
            children: [
              IconButton(
                onPressed: numberOfGuests > 1 ? () {
                  setState(() {
                    numberOfGuests--;
                  });
                } : null,
                icon: const Icon(Icons.remove),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Expanded(
                child: Text(
                  '$numberOfGuests',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: numberOfGuests < 12 ? () {
                  setState(() {
                    numberOfGuests++;
                  });
                } : null,
                icon: const Icon(Icons.add),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (availableChefs.isEmpty && !isSearchingAvailability) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            AppSpacing.verticalSpace16,
            Text(
              'Ingen kokke fundet', // No chefs found
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            AppSpacing.verticalSpace8,
            Text(
              'Prøv at ændre dine søgekriterier',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results header with sort
        Container(
          padding: AppSpacing.screenPaddingHorizontal.copyWith(
            top: AppSpacing.space12,
            bottom: AppSpacing.space8,
          ),
          child: Row(
            children: [
              Text(
                '${availableChefs.length} kokke fundet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showSortOptions(context),
                icon: const Icon(Icons.sort, size: 18),
                label: Text(_getSortLabel()),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        
        // Chef list
        Expanded(
          child: isSearchingAvailability 
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: AppSpacing.screenPaddingHorizontal.copyWith(bottom: AppSpacing.space24),
                  itemCount: availableChefs.length,
                  separatorBuilder: (_, __) => AppSpacing.verticalSpace12,
                  itemBuilder: (context, index) {
                    final chef = availableChefs[index];
                    return ChefCard(
                      chef: chef,
                      onTap: () => widget.onChefSelected(chef),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(hours: 2));
    final lastDate = now.add(const Duration(days: 60));

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
        availableChefs = widget.allChefs; // Reset to all chefs
      });
    }
  }

  void _showTimeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final times = _generateTimeOptions();
        return Container(
          padding: AppSpacing.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vælg starttid', // Select start time
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacing.verticalSpace16,
              Wrap(
                spacing: AppSpacing.betweenChips,
                runSpacing: AppSpacing.betweenChips,
                children: times.map((time) {
                  final isSelected = selectedTimeSlot?.startTime.hour == time.hour &&
                                  selectedTimeSlot?.startTime.minute == time.minute;
                  
                  return FilterChip(
                    label: Text(DateFormat.Hm().format(time)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        final endTime = time.add(selectedDuration);
                        setState(() {
                          selectedTimeSlot = TimeSlot(
                            startTime: time,
                            endTime: endTime,
                            isAvailable: true,
                          );
                        });
                      }
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DateTime> _generateTimeOptions() {
    final baseDate = selectedDate ?? DateTime.now();
    final times = <DateTime>[];
    
    for (int hour = 8; hour <= 20; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        times.add(DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute));
      }
    }
    
    return times;
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: AppSpacing.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sortér efter', // Sort by
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacing.verticalSpace16,
              
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Bedømmelse'),
                trailing: selectedSortOption == 'rating' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    selectedSortOption = 'rating';
                    _sortChefs();
                  });
                  Navigator.pop(context);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Pris (lav til høj)'),
                trailing: selectedSortOption == 'price' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    selectedSortOption = 'price';
                    _sortChefs();
                  });
                  Navigator.pop(context);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Afstand'),
                trailing: selectedSortOption == 'distance' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    selectedSortOption = 'distance';
                    _sortChefs();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  Text(
                    'Filtre', // Filters
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  AppSpacing.verticalSpace16,
                  
                  // Price range
                  Text(
                    'Prisklasse (kr/time)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RangeSlider(
                    values: priceRange,
                    min: 100,
                    max: 1000,
                    divisions: 18,
                    labels: RangeLabels(
                      '${priceRange.start.round()} kr',
                      '${priceRange.end.round()} kr',
                    ),
                    onChanged: (values) {
                      setModalState(() {
                        priceRange = values;
                      });
                    },
                  ),
                  
                  AppSpacing.verticalSpace16,
                  
                  // Apply filters button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Anvend filtre',
                      onPressed: () {
                        setState(() {
                          _applyFilters();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _searchAvailableChefs() async {
    if (selectedDate == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vælg venligst dato og tidspunkt')),
      );
      return;
    }

    setState(() {
      isSearchingAvailability = true;
    });

    try {
      // Simulate searching for available chefs
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, filter chefs based on some criteria
      final filtered = widget.allChefs.where((chef) => chef.isAvailable).toList();
      
      setState(() {
        availableChefs = filtered;
        _sortChefs();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fejl ved søgning: $e')),
        );
      }
    } finally {
      setState(() {
        isSearchingAvailability = false;
      });
    }
  }

  void _sortChefs() {
    switch (selectedSortOption) {
      case 'rating':
        availableChefs.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price':
        availableChefs.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
        break;
      case 'distance':
        availableChefs.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
    }
  }

  void _applyFilters() {
    availableChefs = widget.allChefs.where((chef) {
      // Price filter
      if (chef.hourlyRate < priceRange.start || chef.hourlyRate > priceRange.end) {
        return false;
      }
      
      // Cuisine filter
      if (selectedCuisines.isNotEmpty) {
        final hasMatchingCuisine = chef.cuisineTypes
            .any((cuisine) => selectedCuisines.contains(cuisine));
        if (!hasMatchingCuisine) return false;
      }
      
      return true;
    }).toList();
    
    _sortChefs();
  }

  String _getSortLabel() {
    switch (selectedSortOption) {
      case 'rating':
        return 'Bedømmelse';
      case 'price':
        return 'Pris';
      case 'distance':
        return 'Afstand';
      default:
        return 'Sortér';
    }
  }
}