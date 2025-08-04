import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_providers.dart';
import '../exceptions/location_exceptions.dart';
import 'location_permission_dialog.dart';

class LocationSelector extends ConsumerWidget {
  const LocationSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);
    final canAccess = ref.watch(canAccessLocationProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: () => _handleLocationTap(context, ref),
        child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade200
                  : Colors.grey.shade800,
              shape: BoxShape.circle,
            ),
            child: Icon(
              locationState.isLoading 
                ? Icons.gps_not_fixed 
                : Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: locationState.when(
              data: (location) => _buildLocationDisplay(
                context, 
                location?.address ?? 'Select Location',
                hasLocation: location != null,
              ),
              loading: () => _buildLoadingDisplay(context),
              error: (error, _) => _buildErrorDisplay(context, error),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.onSurface,
            size: 16,
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildLocationDisplay(BuildContext context, String address, {required bool hasLocation}) {
    return Text(
      address,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: hasLocation 
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLoadingDisplay(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Getting location...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDisplay(BuildContext context, Object error) {
    String errorText = 'Location unavailable';
    
    if (error is LocationException) {
      switch (error.type) {
        case LocationErrorType.permissionDenied:
          errorText = 'Permission needed';
          break;
        case LocationErrorType.serviceDisabled:
          errorText = 'Location disabled';
          break;
        case LocationErrorType.timeout:
          errorText = 'Location timeout';
          break;
        default:
          errorText = 'Location error';
      }
    }

    return Text(
      errorText,
      style: TextStyle(
        color: Colors.red.shade300,
        fontSize: 14,
      ),
    );
  }

  void _handleLocationTap(BuildContext context, WidgetRef ref) {
    final locationState = ref.read(locationNotifierProvider);
    
    // Don't handle tap if currently loading
    if (locationState.isLoading) return;
    
    if (locationState.hasError) {
      final error = locationState.error;
      if (error is DinnerHelpLocationPermissionDeniedForeverException) {
        _showPermissionDeniedForeverDialog(context);
      } else if (error is DinnerHelpLocationServiceDisabledException) {
        _showLocationServiceDisabledDialog(context);
      } else {
        _retryLocation(ref);
      }
    } else {
      _showLocationOptions(context, ref);
    }
  }

  void _showLocationOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationOptionsSheet(
        onRefresh: () => _retryLocation(ref),
        onSelectManually: () => _showManualLocationPicker(context),
      ),
    );
  }

  void _retryLocation(WidgetRef ref) {
    ref.read(locationNotifierProvider.notifier).getCurrentLocation();
  }

  void _showPermissionDeniedForeverDialog(BuildContext context) {
    LocationPermissionDialog.showPermanentlyDeniedDialog(context);
  }

  void _showLocationServiceDisabledDialog(BuildContext context) {
    LocationPermissionDialog.showLocationServiceDisabledDialog(context);
  }

  void _showManualLocationPicker(BuildContext context) {
    // TODO: Implement manual location picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual location picker coming soon'),
      ),
    );
  }
}

class LocationOptionsSheet extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onSelectManually;

  const LocationOptionsSheet({
    super.key,
    required this.onRefresh,
    required this.onSelectManually,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Location',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOption(
                    context,
                    icon: Icons.my_location,
                    title: 'Use Current Location',
                    subtitle: 'Get your precise location',
                    onTap: () {
                      Navigator.pop(context);
                      onRefresh();
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.search,
                    title: 'Enter Manually',
                    subtitle: 'Type city or address',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectManually();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}