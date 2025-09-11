import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/location_providers.dart';
import '../exceptions/location_exceptions.dart';
import 'location_permission_dialog.dart';

class LocationSelector extends ConsumerWidget {
  const LocationSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);
    final canAccess = ref.watch(canAccessLocationProvider);

    return GestureDetector(
      onTap: () => _handleLocationTap(context, ref),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 6),
          locationState.when(
            data: (location) => _buildLocationDisplay(
              context, 
              _extractCityName(location?.address ?? AppLocalizations.of(context)!.selectLocation),
              hasLocation: location != null,
            ),
            loading: () => _buildLoadingDisplay(context),
            error: (error, _) => _buildErrorDisplay(context, error),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
        ],
      ),
    );
  }
  
  String _extractCityName(String address) {
    // Extract city name from address
    // Common Danish address format: "Street, PostalCode City"
    final parts = address.split(',');
    if (parts.length > 1) {
      // Try to get the city from the last part
      final lastPart = parts.last.trim();
      // Remove postal code if present (4 digits in Denmark)
      final cityMatch = RegExp(r'\d{4}\s+(.+)').firstMatch(lastPart);
      if (cityMatch != null) {
        return cityMatch.group(1) ?? address;
      }
      // If no postal code, might be just the city
      if (!RegExp(r'^\d').hasMatch(lastPart)) {
        return lastPart;
      }
    }
    // Fallback to full address if can't extract city
    return address;
  }

  Widget _buildLocationDisplay(BuildContext context, String address, {required bool hasLocation}) {
    return Text(
      address,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: hasLocation 
            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
            : (Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLoadingDisplay(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.gettingLocation,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54,
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;
    String errorText = l10n.locationUnavailable;
    
    if (error is LocationException) {
      switch (error.type) {
        case LocationErrorType.permissionDenied:
          errorText = l10n.locationPermissionNeeded;
          break;
        case LocationErrorType.serviceDisabled:
          errorText = l10n.locationDisabled;
          break;
        case LocationErrorType.timeout:
          errorText = l10n.locationTimeout;
          break;
        default:
          errorText = l10n.locationError;
      }
    }

    return Text(
      errorText,
      style: TextStyle(
        color: Colors.red.shade400,
        fontSize: 14,
        fontWeight: FontWeight.w500,
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
        onSelectManually: () => _showManualLocationPicker(context, ref),
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

  void _showManualLocationPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => _ManualLocationDialog(
        onLocationSubmit: (address) {
          Navigator.pop(dialogContext);
          ref.read(locationNotifierProvider.notifier).setManualLocation(address);
        },
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
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectLocation,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOption(
                    context,
                    icon: Icons.my_location,
                    title: AppLocalizations.of(context)!.useCurrentLocation,
                    subtitle: AppLocalizations.of(context)!.getPreciseLocation,
                    onTap: () {
                      Navigator.pop(context);
                      onRefresh();
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.search,
                    title: AppLocalizations.of(context)!.enterManually,
                    subtitle: AppLocalizations.of(context)!.typeLocationOrAddress,
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
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ManualLocationDialog extends StatefulWidget {
  final void Function(String address) onLocationSubmit;

  const _ManualLocationDialog({
    required this.onLocationSubmit,
  });

  @override
  State<_ManualLocationDialog> createState() => _ManualLocationDialogState();
}

class _ManualLocationDialogState extends State<_ManualLocationDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.enterManually),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: l10n.typeLocationOrAddress,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.locationPermissionRequired;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submitLocation(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submitLocation,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  void _submitLocation() {
    if (_formKey.currentState!.validate()) {
      widget.onLocationSubmit(_controller.text.trim());
    }
  }
}