import 'package:flutter/material.dart';
import 'package:homechef/models/booking.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Booking> _bookings = Booking.getSampleBookings();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcomingBookings = _bookings.where((b) => 
        b.status == BookingStatus.confirmed || b.status == BookingStatus.pending).toList();
    final pastBookings = _bookings.where((b) => 
        b.status == BookingStatus.completed).toList();
    final cancelledBookings = _bookings.where((b) => 
        b.status == BookingStatus.cancelled).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(upcomingBookings, 'No upcoming bookings'),
          _buildBookingsList(pastBookings, 'No past bookings'),
          _buildBookingsList(cancelledBookings, 'No cancelled bookings'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final theme = Theme.of(context);
    final isUpcoming = booking.dateTime.isAfter(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.chefName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.statusText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(booking.dateTime),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '${booking.guestCount} guests',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            
            if (booking.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Total: ${booking.totalPrice.toStringAsFixed(0)} DKK',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isUpcoming && booking.status == BookingStatus.confirmed)
                  OutlinedButton(
                    onPressed: () => _showBookingDetails(booking),
                    child: const Text('View Details'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.inProgress:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$weekday, $month ${dateTime.day} at $time';
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chef: ${booking.chefName}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDateTime(booking.dateTime)}'),
            const SizedBox(height: 8),
            Text('Guests: ${booking.guestCount}'),
            const SizedBox(height: 8),
            Text('Address: ${booking.address}'),
            const SizedBox(height: 16),
            const Text('Price Breakdown:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Base Price: ${booking.basePrice.toStringAsFixed(0)} DKK'),
            Text('Service Fee: ${booking.serviceFee.toStringAsFixed(0)} DKK'),
            Text('Tax: ${booking.tax.toStringAsFixed(0)} DKK'),
            const Divider(),
            Text('Total: ${booking.totalPrice.toStringAsFixed(0)} DKK', 
                 style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}