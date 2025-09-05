import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/booking.dart';
import 'package:homechef/providers/booking_provider.dart';
import 'package:homechef/providers/chef_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/localization/app_localizations_extension.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessingCancellation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Get the actual authenticated user ID from Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        ref.read(currentUserIdProvider.notifier).state = user.id;
      }
      
      // Check if there's a selected booking ID from navigation
      final selectedBookingId = ref.read(selectedBookingIdProvider);
      if (selectedBookingId != null) {
        // Wait a bit for the UI to be ready, then show the booking details
        Future.delayed(const Duration(milliseconds: 500), () {
          _showBookingDetailsById(selectedBookingId);
          // Clear the selected booking ID after showing
          ref.read(selectedBookingIdProvider.notifier).state = null;
        });
      }
    });
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
    final upcomingBookingsAsync = ref.watch(upcomingBookingsProvider);
    final pastBookingsAsync = ref.watch(pastBookingsProvider);
    final cancelledBookingsAsync = ref.watch(bookingsByStatusProvider(BookingStatus.cancelled));

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark 
          ? theme.scaffoldBackgroundColor 
          : Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              snap: false,
              expandedHeight: 90.0,
              backgroundColor: theme.brightness == Brightness.dark 
                  ? theme.appBarTheme.backgroundColor 
                  : Colors.white,
              elevation: 0,
              collapsedHeight: kToolbarHeight,
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0,
                child: Text(
                  'Bookinger',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
              ),
              centerTitle: false,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isCollapsed = constraints.biggest.height <= kToolbarHeight + 48;
                  return FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.only(
                      left: 20,
                      bottom: isCollapsed ? 48 : 16,
                    ),
                    title: null,
                    background: Container(
                      color: theme.brightness == Brightness.dark 
                          ? theme.appBarTheme.backgroundColor 
                          : Colors.white,
                    ),
                  );
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: theme.brightness == Brightness.dark 
                      ? theme.appBarTheme.backgroundColor 
                      : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: l10n.upcomingTab),
                      Tab(text: l10n.pastTab),
                      Tab(text: l10n.cancelledTab),
                    ],
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.brightness == Brightness.dark 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingsListAsync(upcomingBookingsAsync, l10n.noUpcomingBookings, true),
            _buildBookingsListAsync(pastBookingsAsync, l10n.noPastBookings, false),
            _buildBookingsListAsync(cancelledBookingsAsync, l10n.noCancelledBookings, false),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsListAsync(AsyncValue<List<Booking>> bookingsAsync, String emptyMessage, bool isUpcoming) {
    final l10n = context.l10n;
    
    return bookingsAsync.when(
      data: (bookings) => _buildBookingsList(bookings, emptyMessage, isUpcoming),
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.errorLoadingBookings,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(bookingActionsProvider).refreshAllBookings(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, String emptyMessage, bool isUpcoming) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUpcoming ? Icons.calendar_today_outlined : Icons.history_outlined,
                size: 64,
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 12),
              Text(
                l10n.findYourNextChef,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/search');
                },
                icon: const Icon(Icons.search),
                label: Text(l10n.startExploring),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(bookingActionsProvider).refreshAllBookings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildModernBookingCard(booking, isUpcoming);
        },
      ),
    );
  }

  Widget _buildModernBookingCard(Booking booking, bool isUpcoming) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final canCancel = _canCancelBooking(booking);
    
    // Calculate days until booking
    final now = DateTime.now();
    final daysUntil = booking.dateTime.difference(now).inDays;
    final isToday = daysUntil == 0 && booking.dateTime.day == now.day;
    final isTomorrow = daysUntil == 1;
    
    // Watch chef data for images
    final chefAsync = ref.watch(chefByIdProvider(booking.chefId));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? const Color(0xFF252325) 
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Primary shadow for elevation
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          // Secondary shadow for definition
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showBookingDetails(booking),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image with Chef Profile Photo Overlay
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover/Header Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: chefAsync.when(
                      data: (chef) => chef?.headerImage != null && chef!.headerImage.isNotEmpty
                        ? Image.network(
                            chef.headerImage,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/logo_brand.png'),
                                  fit: BoxFit.cover,
                                ),
                                color: theme.colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                          )
                        : Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/images/logo_brand.png'),
                                fit: BoxFit.cover,
                              ),
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                      loading: () => Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/images/logo_brand.png'),
                            fit: BoxFit.cover,
                          ),
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                  
                  // Gradient overlay for better text readability
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  
                  // Chef Name Overlay - positioned at bottom edge
                  Positioned(
                    left: 110, // Moved further right
                    bottom: 4, // Very close to the bottom edge
                    right: 20,
                    child: Text(
                      booking.chefName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Status Chip - moved to top right corner
                  Positioned(
                    right: 20,
                    top: 20,
                    child: _buildEnhancedStatusChip(booking.status, paymentStatus: booking.paymentStatus),
                  ),
                  
                  // Chef Profile Photo
                  Positioned(
                    bottom: -35,
                    left: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          chefAsync.when(
                            data: (chef) => chef?.profileImage != null && chef!.profileImage.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    chef.profileImage,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            theme.colorScheme.primary.withOpacity(0.9),
                                            theme.colorScheme.primary,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          booking.chefName.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(0.9),
                                        theme.colorScheme.primary,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      booking.chefName.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                            loading: () => Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            error: (error, stack) => Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.9),
                                    theme.colorScheme.primary,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  booking.chefName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Status indicator dot
                          if (booking.status == BookingStatus.confirmed)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Today/Tomorrow Badge
                  if (isUpcoming && (isToday || isTomorrow))
                    Positioned(
                      left: 20,
                      top: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isToday ? Colors.red : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isToday ? Colors.red : Colors.orange).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          isToday ? 'I DAG' : 'I MORGEN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Enhanced Details Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  children: [
                    // Quick Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickInfoCard(
                            Icons.calendar_today_rounded,
                            _formatDate(booking.dateTime),
                            const Color(0xFF4A90E2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickInfoCard(
                            Icons.schedule_rounded,
                            _formatTime(booking.dateTime),
                            const Color(0xFFFF9500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickInfoCard(
                            Icons.group_rounded,
                            '${booking.guestCount} personer',
                            const Color(0xFF5AC8FA),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF9B59B6).withOpacity(0.08),
                                  const Color(0xFF9B59B6).withOpacity(0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF9B59B6).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9B59B6).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    size: 18,
                                    color: Color(0xFF9B59B6),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    booking.address.split(',').first,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.grey.shade300
                                          : const Color(0xFF2C3E50),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Price display row
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.08),
                            theme.colorScheme.primary.withOpacity(0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.payments_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Total pris',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Text(
                            '${booking.totalPrice.toStringAsFixed(0)} kr',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Cancellation deadline indicator (only for upcoming bookings with pending status)
                    if (isUpcoming && booking.status == BookingStatus.pending) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: canCancel 
                              ? Colors.green.withValues(alpha: 0.05)
                              : Colors.orange.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: canCancel 
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.orange.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              canCancel ? Icons.check_circle_outline : Icons.info_outline,
                              size: 18,
                              color: canCancel ? Colors.green.shade600 : Colors.orange.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                canCancel 
                                    ? 'Gratis afbestilling mulig (mere end 48 timer før)'
                                    : 'Ingen refundering mulig (mindre end 48 timer før)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: canCancel 
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Notes section if present
                    if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: theme.brightness == Brightness.dark
                                ? [
                                    Colors.amber.shade900.withOpacity(0.2),
                                    Colors.amber.shade900.withOpacity(0.1),
                                  ]
                                : [
                                    Colors.amber.shade50,
                                    Colors.amber.shade50.withOpacity(0.5),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? Colors.amber.shade700.withOpacity(0.3)
                                : Colors.amber.shade300.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.amber.shade800.withOpacity(0.3)
                                    : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.sticky_note_2_rounded,
                                size: 14,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.amber.shade400
                                    : Colors.amber.shade700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                booking.notes!,
                                style: TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.amber.shade200
                                      : Colors.amber.shade900,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Premium Action Button
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showBookingDetails(booking),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.remove_red_eye_rounded,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Se detaljer',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickInfoCard(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : const Color(0xFF2C3E50),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnhancedStatusChip(BookingStatus status, {PaymentStatus? paymentStatus}) {
    final l10n = context.l10n;
    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData? icon;
    
    // Show "Betalt" (Paid) for completed bookings with successful payment
    if (status == BookingStatus.completed && paymentStatus == PaymentStatus.succeeded) {
      backgroundColor = const Color(0xFF4CAF50).withOpacity(0.1);
      textColor = const Color(0xFF2E7D32);
      statusText = 'Betalt';
      icon = Icons.check_circle_rounded;
    } else {
      switch (status) {
        case BookingStatus.pending:
          backgroundColor = Colors.orange.shade100;
          textColor = Colors.orange.shade800;
          statusText = l10n.pending;
          icon = Icons.hourglass_empty_rounded;
          break;
        case BookingStatus.confirmed:
          backgroundColor = Colors.green.shade100;
          textColor = Colors.green.shade800;
          statusText = 'Bekræftet';
          icon = Icons.check_circle_rounded;
          break;
        case BookingStatus.inProgress:
          backgroundColor = Colors.blue.shade100;
          textColor = Colors.blue.shade800;
          statusText = l10n.inProgress;
          icon = Icons.restaurant_rounded;
          break;
        case BookingStatus.completed:
          backgroundColor = Colors.grey.shade200;
          textColor = Colors.grey.shade700;
          statusText = l10n.completed;
          icon = Icons.done_all_rounded;
          break;
        case BookingStatus.cancelled:
          backgroundColor = Colors.red.shade100;
          textColor = Colors.red.shade800;
          statusText = l10n.cancelled;
          icon = Icons.cancel_rounded;
          break;
        case BookingStatus.refunded:
          backgroundColor = Colors.purple.shade100;
          textColor = Colors.purple.shade800;
          statusText = l10n.refunded;
          icon = Icons.replay_rounded;
          break;
        case BookingStatus.disputed:
          backgroundColor = Colors.deepOrange.shade100;
          textColor = Colors.deepOrange.shade800;
          statusText = l10n.disputed;
          icon = Icons.warning_rounded;
          break;
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color iconColor, {bool isAddress = false}) {
    return Row(
      crossAxisAlignment: isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade800,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: isAddress ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BookingStatus status, {PaymentStatus? paymentStatus}) {
    // Now just delegates to the enhanced version
    return _buildEnhancedStatusChip(status, paymentStatus: paymentStatus);
  }

  String _formatDate(DateTime dateTime) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0 && dateTime.day == now.day) {
      return 'I dag';
    } else if (difference.inDays == 1) {
      return 'I morgen';
    } else if (difference.inDays == -1) {
      return 'I går';
    }
    
    final weekdays = ['Man', 'Tir', 'Ons', 'Tor', 'Fre', 'Lør', 'Søn'];
    final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun',
                   'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    
    return '$weekday ${dateTime.day}. $month ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getBookingAge(DateTime createdAt) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return 'Lige nu';
    }
  }

  bool _canCancelBooking(Booking booking) {
    // Allow cancellation for pending and confirmed bookings only
    if (booking.status != BookingStatus.pending && booking.status != BookingStatus.confirmed) {
      return false;
    }
    
    // Check if booking is in the future (can't cancel past bookings)
    final now = DateTime.now();
    if (booking.dateTime.isBefore(now)) {
      return false;
    }
    
    // Enforce 48-hour cancellation policy
    // Users cannot cancel if less than 48 hours before the booking
    final hoursUntilBooking = booking.dateTime.difference(now).inHours;
    return hoursUntilBooking > 48;
  }

  void _showBookingDetailsById(String bookingId) async {
    // Fetch the booking by ID
    final booking = await ref.read(bookingByIdProvider(bookingId).future);
    if (booking != null && mounted) {
      _showBookingDetails(booking);
    }
  }
  
  void _showBookingDetails(Booking booking) {
    final l10n = context.l10n;
    // Get chef data for profile image
    final chefAsync = ref.watch(chefByIdProvider(booking.chefId));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 5,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 5,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    l10n.bookingDetails,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chef Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Chef Avatar with actual image
                          chefAsync.when(
                            data: (chef) => chef?.profileImage != null && chef!.profileImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    chef.profileImage,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context).colorScheme.primary,
                                            Theme.of(context).colorScheme.secondary,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          booking.chefName.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      booking.chefName.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            loading: () => Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            error: (error, stack) => Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  booking.chefName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.chefName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildStatusChip(booking.status, paymentStatus: booking.paymentStatus),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Booking Creation Date
                    Text(
                      'Booking oprettet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailTile(
                      Icons.history_outlined, 
                      'Booket den', 
                      '${_formatDate(booking.createdAt)} kl. ${_formatTime(booking.createdAt)}'
                    ),
                    const SizedBox(height: 24),
                    
                    // Details
                    Text(
                      'Booking Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailTile(Icons.calendar_month, 'Service dato', _formatDate(booking.dateTime)),
                    _buildDetailTile(Icons.access_time, l10n.time, _formatTime(booking.dateTime)),
                    _buildDetailTile(Icons.people, 'Personer', '${booking.guestCount} personer'),
                    _buildDetailTile(Icons.location_on, l10n.address, booking.address),
                    
                    if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        l10n.specialRequests,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          booking.notes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    Text(
                      l10n.priceBreakdown,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow(l10n.basePrice, '${booking.basePrice.toStringAsFixed(0)} kr'),
                          const SizedBox(height: 8),
                          _buildPriceRow(l10n.serviceFee, '${booking.serviceFee.toStringAsFixed(0)} kr'),
                          const SizedBox(height: 8),
                          _buildPriceRow(l10n.tax, '${booking.tax.toStringAsFixed(0)} kr'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(),
                          ),
                          _buildPriceRow(
                            l10n.total,
                            '${booking.totalPrice.toStringAsFixed(0)} kr',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    
                    // Payment Details Section (for paid bookings)
                    if (booking.paymentStatus == PaymentStatus.succeeded) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Betalingsdetaljer',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.green.shade900.withOpacity(0.2)
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.green.shade700.withOpacity(0.3)
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Betaling gennemført',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (booking.stripePaymentIntentId != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transaktion ID',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '...${booking.stripePaymentIntentId!.substring(booking.stripePaymentIntentId!.length - 8)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    if (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed) ...[
                      Row(
                        children: [
                          // Cancel button (only if cancellable)
                          if (_canCancelBooking(booking))
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showCancelConfirmation(booking);
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Annuller booking'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          if (_canCancelBooking(booking))
                            const SizedBox(width: 12),
                          // Contact chef button
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Navigate to messages
                                Navigator.pushNamed(
                                  context,
                                  '/messages',
                                  arguments: {'chefId': booking.chefId, 'chefName': booking.chefName},
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Kontakt kok'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ] else if (booking.paymentStatus == PaymentStatus.succeeded) ...[
                      // Action buttons for paid bookings
                      Column(
                        children: [
                          // Send receipt button
                          FilledButton.icon(
                            onPressed: () => _sendReceipt(context, booking),
                            icon: const Icon(Icons.email_outlined),
                            label: const Text('Send kvittering på mail'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Contact support button
                          OutlinedButton.icon(
                            onPressed: () => _contactSupport(context, booking),
                            icon: const Icon(Icons.support_agent_outlined),
                            label: const Text('Kontakt support'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),
          ],
          ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal 
                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal 
                ? Theme.of(context).colorScheme.primary 
                : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  void _showCancelConfirmation(Booking booking) {
    final l10n = context.l10n;
    
    // Calculate hours until booking for refund policy display
    final now = DateTime.now();
    final hoursUntilBooking = booking.dateTime.difference(now).inHours;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,  // Allow the sheet to be full height
      builder: (context) => Container(
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 5,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 5,
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,  // Account for keyboard if any
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: SingleChildScrollView(  // Make content scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.orange.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.cancelBookingTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cancelBookingConfirmation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildCancelDetailRow('Kok', booking.chefName),
                  const SizedBox(height: 8),
                  _buildCancelDetailRow('Dato', _formatDate(booking.dateTime)),
                  const SizedBox(height: 8),
                  _buildCancelDetailRow('Total', '${booking.totalPrice.toStringAsFixed(0)} kr'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Refund policy notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: hoursUntilBooking > 48 
                    ? Colors.green.withValues(alpha: 0.08)
                    : Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hoursUntilBooking > 48 
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hoursUntilBooking > 48 
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    size: 22,
                    color: hoursUntilBooking > 48 
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hoursUntilBooking > 48 ? 'Bemærk:' : 'Advarsel:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: hoursUntilBooking > 48 
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hoursUntilBooking > 48 
                              ? 'Du vil modtage fuld refundering, da der er mere end 48 timer til bookingen.'
                              : 'Ingen refundering mulig, da der er mindre end 48 timer til bookingen.',
                          style: TextStyle(
                            fontSize: 12,
                            color: hoursUntilBooking > 48 
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Behold booking'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isProcessingCancellation ? null : () {
                      Navigator.of(context).pop();
                      Future.microtask(() => _cancelBooking(booking));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ja, annuller'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
            ),
          ),
      ),
    );
  }

  Widget _buildCancelDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    final l10n = context.l10n;
    
    if (_isProcessingCancellation) {
      return;
    }
    
    setState(() {
      _isProcessingCancellation = true;
    });

    try {
      // If there's a payment, call refund-payment function which handles cancellation and refund
      if (booking.paymentStatus == PaymentStatus.succeeded && booking.stripePaymentIntentId != null) {
        // Call refund-payment Edge Function - it handles both cancellation and refund
        final supabase = Supabase.instance.client;
        final response = await supabase.functions.invoke(
          'refund-payment',
          body: {
            'booking_id': booking.id,
            'cancelled_by': 'user',
            'reason': 'User requested cancellation',
          },
        );
        
        // The function returns info about whether refund was processed
        if (response.data != null && response.data['refunded'] == true) {
          final refundAmount = response.data['refund_amount'];
          // Refund will be processed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Booking cancelled. Refund of $refundAmount kr will be processed.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // No refund (within 48 hours)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Booking cancelled. No refund due to cancellation within 48 hours.'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        // No payment to refund, just cancel the booking
        final bookingActions = ref.read(bookingActionsProvider);
        await bookingActions.cancelBooking(
          booking.id, 
          cancellationReason: 'User requested cancellation',
        );
        
        // Show cancellation success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.bookingCancelledSuccess),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorCancellingBooking}: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCancellation = false;
        });
      }
    }
  }

  Future<void> _sendReceipt(BuildContext context, Booking booking) async {
    final l10n = context.l10n;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Get current user email
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User email not found');
      }
      
      // Call Edge Function to send receipt
      final response = await Supabase.instance.client.functions.invoke(
        'send-receipt-email',
        body: {
          'booking_id': booking.id,
          'recipient_email': user.email,
        },
      );
      
      // Check if the response indicates an error
      if (response.data != null && response.data['error'] != null) {
        throw Exception(response.data['error']);
      }
      
      // Check for success flag
      if (response.data == null || response.data['success'] != true) {
        throw Exception('Failed to send receipt');
      }
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Close the booking details modal
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kvittering sendt til ${user.email}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke sende kvittering: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _contactSupport(BuildContext context, Booking booking) {
    // Navigate to messages with pre-filled support context
    Navigator.of(context).pop(); // Close the booking details modal
    Navigator.pushNamed(
      context,
      '/messages',
      arguments: {
        'recipientId': 'support', // Special support ID
        'recipientName': 'DinnerHelp Support',
        'context': 'Booking #${booking.id.substring(0, 8).toUpperCase()}',
        'prefilledMessage': 'Jeg har brug for hjælp med min booking #${booking.id.substring(0, 8).toUpperCase()}',
      },
    );
  }
}