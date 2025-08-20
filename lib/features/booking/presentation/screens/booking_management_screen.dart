import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../widgets/custom_button.dart';
import 'package:homechef/models/booking.dart';
import '../../domain/entities/recurrence_pattern.dart';

class BookingManagementScreen extends ConsumerStatefulWidget {
  final List<Booking> bookings;
  final Function(String bookingId) onModifyBooking;
  final Function(String bookingId) onCancelBooking;
  final Function(String bookingId) onContactChef;

  const BookingManagementScreen({
    super.key,
    required this.bookings,
    required this.onModifyBooking,
    required this.onCancelBooking,
    required this.onContactChef,
  });

  @override
  ConsumerState<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends ConsumerState<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'all'; // all, upcoming, completed, cancelled

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final filteredBookings = _getFilteredBookings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mine bookinger'), // My bookings
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Alle (${widget.bookings.length})'),
            Tab(text: 'Kommende (${_getUpcomingBookings().length})'),
            Tab(text: 'Gennemført (${_getCompletedBookings().length})'),
            Tab(text: 'Annulleret (${_getCancelledBookings().length})'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(widget.bookings, theme),
          _buildBookingList(_getUpcomingBookings(), theme),
          _buildBookingList(_getCompletedBookings(), theme),
          _buildBookingList(_getCancelledBookings(), theme),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, ThemeData theme) {
    if (bookings.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.separated(
        padding: AppSpacing.screenPaddingHorizontal.copyWith(top: AppSpacing.space16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => AppSpacing.verticalSpace16,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking, theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          AppSpacing.verticalSpace16,
          Text(
            'Ingen bookinger', // No bookings
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.verticalSpace8,
          Text(
            'Dine bookinger vil vises her',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, ThemeData theme) {
    final now = DateTime.now();
    final canModify = booking.dateTime.isAfter(now.add(const Duration(hours: 24))) &&
                      booking.status != BookingStatus.cancelled &&
                      booking.status != BookingStatus.completed;
    final canCancel = booking.dateTime.isAfter(now.add(const Duration(hours: 24))) &&
                      booking.status != BookingStatus.cancelled &&
                      booking.status != BookingStatus.completed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with chef name and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.chefName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      AppSpacing.verticalSpace4,
                      Text(
                        'Booking #${booking.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(booking.status, theme),
              ],
            ),
            AppSpacing.verticalSpace16,
            
            // Booking details
            _buildBookingDetailRow(
              icon: Icons.calendar_today,
              label: 'Dato',
              value: DateFormat.yMMMEd('da').format(booking.dateTime),
              theme: theme,
            ),
            AppSpacing.verticalSpace8,
            
            _buildBookingDetailRow(
              icon: Icons.access_time,
              label: 'Tid',
              value: DateFormat.Hm().format(booking.dateTime),
              theme: theme,
            ),
            AppSpacing.verticalSpace8,
            
            _buildBookingDetailRow(
              icon: Icons.people,
              label: 'Gæster',
              value: '${booking.guestCount} personer',
              theme: theme,
            ),
            AppSpacing.verticalSpace8,
            
            _buildBookingDetailRow(
              icon: Icons.location_on,
              label: 'Adresse',
              value: booking.address,
              theme: theme,
            ),
            
            if (booking.notes != null) ...[
              AppSpacing.verticalSpace8,
              _buildBookingDetailRow(
                icon: Icons.note,
                label: 'Noter',
                value: booking.notes!,
                theme: theme,
              ),
            ],
            
            AppSpacing.verticalSpace16,
            
            // Price
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Total pris',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${booking.totalPrice.toStringAsFixed(0)} kr',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            AppSpacing.verticalSpace16,
            
            // Action buttons
            _buildActionButtons(booking, canModify, canCancel, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        AppSpacing.horizontalSpace8,
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BookingStatus status, ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case BookingStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        textColor = Colors.orange.shade700;
        text = 'Afventer';
        break;
      case BookingStatus.confirmed:
        backgroundColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
        textColor = theme.colorScheme.primary;
        text = 'Bekræftet';
        break;
      case BookingStatus.inProgress:
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue.shade700;
        text = 'I gang';
        break;
      case BookingStatus.completed:
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green.shade700;
        text = 'Gennemført';
        break;
      case BookingStatus.cancelled:
        backgroundColor = theme.colorScheme.errorContainer.withValues(alpha: 0.5);
        textColor = theme.colorScheme.error;
        text = 'Annulleret';
        break;
      case BookingStatus.refunded:
        backgroundColor = Colors.purple.withValues(alpha: 0.2);
        textColor = Colors.purple.shade700;
        text = 'Refunderet';
        break;
      case BookingStatus.disputed:
        backgroundColor = Colors.deepOrange.withValues(alpha: 0.2);
        textColor = Colors.deepOrange.shade700;
        text = 'Under tvist';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    Booking booking,
    bool canModify,
    bool canCancel,
    ThemeData theme,
  ) {
    return Row(
      children: [
        // Contact chef button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => widget.onContactChef(booking.id),
            icon: const Icon(Icons.chat, size: 18),
            label: const Text('Kontakt kok'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        if (canModify) ...[
          AppSpacing.horizontalSpace8,
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => widget.onModifyBooking(booking.id),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Rediger'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
                side: BorderSide(color: theme.colorScheme.secondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        
        if (canCancel) ...[
          AppSpacing.horizontalSpace8,
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(booking.id),
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Annuller'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showCancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Annuller booking'),
          content: const Text(
            'Er du sikker på, at du vil annullere denne booking? '
            'Denne handling kan ikke fortrydes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Behold'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onCancelBooking(bookingId);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Annuller booking'),
            ),
          ],
        );
      },
    );
  }

  List<Booking> _getFilteredBookings() {
    switch (selectedFilter) {
      case 'upcoming':
        return _getUpcomingBookings();
      case 'completed':
        return _getCompletedBookings();
      case 'cancelled':
        return _getCancelledBookings();
      default:
        return widget.bookings;
    }
  }

  List<Booking> _getUpcomingBookings() {
    final now = DateTime.now();
    return widget.bookings.where((booking) =>
        booking.dateTime.isAfter(now) &&
        booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed
    ).toList();
  }

  List<Booking> _getCompletedBookings() {
    return widget.bookings.where((booking) =>
        booking.status == BookingStatus.completed
    ).toList();
  }

  List<Booking> _getCancelledBookings() {
    return widget.bookings.where((booking) =>
        booking.status == BookingStatus.cancelled
    ).toList();
  }
}