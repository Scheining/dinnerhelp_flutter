import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChefAvailabilityService {
  final SupabaseClient _supabaseClient;
  
  ChefAvailabilityService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;
  
  /// Get the working days for a chef (for UI calendar to disable non-working days)
  Future<List<int>> getWorkingWeekdays(String chefId) async {
    try {
      final response = await _supabaseClient
          .from('chef_working_hours')
          .select()
          .eq('chef_id', chefId)
          .maybeSingle();
      
      if (response == null) {
        // No working hours set, assume all days available
        return [1, 2, 3, 4, 5, 6, 7];
      }
      
      final workingDays = <int>[];
      if (response['monday_enabled'] == true) workingDays.add(1);
      if (response['tuesday_enabled'] == true) workingDays.add(2);
      if (response['wednesday_enabled'] == true) workingDays.add(3);
      if (response['thursday_enabled'] == true) workingDays.add(4);
      if (response['friday_enabled'] == true) workingDays.add(5);
      if (response['saturday_enabled'] == true) workingDays.add(6);
      if (response['sunday_enabled'] == true) workingDays.add(7);
      
      return workingDays;
    } catch (e) {
      print('Error getting working weekdays: $e');
      // On error, return all days to not block the UI
      return [1, 2, 3, 4, 5, 6, 7];
    }
  }

  /// Check if a chef is available for a specific booking
  Future<AvailabilityCheckResult> checkAvailability({
    required String chefId,
    required DateTime bookingDate,
    required TimeOfDay startTime,
    required int durationHours,
  }) async {
    try {
      // Convert TimeOfDay to DateTime for easier calculations
      final bookingDateTime = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        startTime.hour,
        startTime.minute,
      );
      
      final endDateTime = bookingDateTime.add(Duration(hours: durationHours));
      
      print('🔍 Checking availability for chef $chefId on ${bookingDate.toIso8601String()} at ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}');
      print('   Day of week: ${bookingDateTime.weekday} (${_getDanishDayName(bookingDateTime.weekday)})');
      
      // 1. Check chef schedule settings (buffer time, max bookings, min notice)
      final settingsCheck = await _checkScheduleSettings(chefId, bookingDateTime);
      if (!settingsCheck.isAvailable) {
        print('❌ Schedule settings check failed: ${settingsCheck.message}');
        return settingsCheck;
      }
      print('✅ Schedule settings check passed');
      
      // 2. Check standard working hours
      final workingHoursCheck = await _checkWorkingHours(chefId, bookingDateTime, endDateTime);
      if (!workingHoursCheck.isAvailable) {
        print('❌ Working hours check failed: ${workingHoursCheck.message}');
        return workingHoursCheck;
      }
      print('✅ Working hours check passed');
      
      // 3. Check specific availability overrides
      final availabilityCheck = await _checkSpecificAvailability(chefId, bookingDate, startTime, endDateTime);
      if (!availabilityCheck.isAvailable) {
        print('❌ Specific availability check failed: ${availabilityCheck.message}');
        return availabilityCheck;
      }
      print('✅ Specific availability check passed');
      
      // 4. Check time off periods
      final timeOffCheck = await _checkTimeOff(chefId, bookingDateTime);
      if (!timeOffCheck.isAvailable) {
        print('❌ Time off check failed: ${timeOffCheck.message}');
        return timeOffCheck;
      }
      print('✅ Time off check passed');
      
      // 5. Check existing bookings with buffer time
      final bookingsCheck = await _checkExistingBookings(chefId, bookingDateTime, endDateTime);
      if (!bookingsCheck.isAvailable) {
        print('❌ Existing bookings check failed: ${bookingsCheck.message}');
        return bookingsCheck;
      }
      print('✅ Existing bookings check passed');
      
      // 6. Check max bookings per day
      final maxBookingsCheck = await _checkMaxBookingsPerDay(chefId, bookingDate);
      if (!maxBookingsCheck.isAvailable) {
        print('❌ Max bookings check failed: ${maxBookingsCheck.message}');
        return maxBookingsCheck;
      }
      print('✅ Max bookings check passed');
      
      print('✅ All availability checks passed - Chef is available!');
      return AvailabilityCheckResult(
        isAvailable: true,
        message: 'Chef er tilgængelig for denne booking',
      );
      
    } catch (e) {
      print('❌ Availability check error: ${e.toString()}');
      return AvailabilityCheckResult(
        isAvailable: false,
        message: 'Kunne ikke kontrollere tilgængelighed: ${e.toString()}',
      );
    }
  }
  
  Future<AvailabilityCheckResult> _checkScheduleSettings(
    String chefId,
    DateTime bookingDateTime,
  ) async {
    final response = await _supabaseClient
        .from('chef_schedule_settings')
        .select('min_notice_hours')
        .eq('chef_id', chefId)
        .maybeSingle();
    
    if (response == null) {
      // No settings found, use defaults
      return AvailabilityCheckResult(isAvailable: true);
    }
    
    final minNoticeHours = response['min_notice_hours'] as int? ?? 24;
    final hoursUntilBooking = bookingDateTime.difference(DateTime.now()).inHours;
    
    if (hoursUntilBooking < minNoticeHours) {
      return AvailabilityCheckResult(
        isAvailable: false,
        message: 'Kokken kræver mindst $minNoticeHours timers varsel for bookinger',
      );
    }
    
    return AvailabilityCheckResult(isAvailable: true);
  }
  
  Future<AvailabilityCheckResult> _checkWorkingHours(
    String chefId,
    DateTime startDateTime,
    DateTime endDateTime,
  ) async {
    final response = await _supabaseClient
        .from('chef_working_hours')
        .select()
        .eq('chef_id', chefId)
        .maybeSingle();
    
    if (response == null) {
      // No working hours set, assume available
      print('   ⚠️ No working hours found for chef - assuming available');
      return AvailabilityCheckResult(isAvailable: true);
    }
    
    // Get the day of week
    final dayName = _getDayName(startDateTime.weekday);
    print('   📅 Checking ${dayName} (weekday ${startDateTime.weekday})');
    print('   📋 Working hours data: ${dayName}_enabled = ${response['${dayName}_enabled']}');
    
    final isEnabled = response['${dayName}_enabled'] as bool? ?? false;
    if (!isEnabled) {
      return AvailabilityCheckResult(
        isAvailable: false,
        message: 'Kokken arbejder ikke på ${_getDanishDayName(startDateTime.weekday)}',
      );
    }
    
    final workStart = response['${dayName}_start'] as String?;
    final workEnd = response['${dayName}_end'] as String?;
    
    if (workStart == null || workEnd == null) {
      return AvailabilityCheckResult(isAvailable: true);
    }
    
    // Parse time strings
    final startTimeParts = workStart.split(':');
    final endTimeParts = workEnd.split(':');
    
    final workStartTime = TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    );
    
    final workEndTime = TimeOfDay(
      hour: int.parse(endTimeParts[0]),
      minute: int.parse(endTimeParts[1]),
    );
    
    // Check if booking time is within working hours
    final bookingStartTime = TimeOfDay.fromDateTime(startDateTime);
    final bookingEndTime = TimeOfDay.fromDateTime(endDateTime);
    
    if (!_isTimeInRange(bookingStartTime, workStartTime, workEndTime) ||
        !_isTimeInRange(bookingEndTime, workStartTime, workEndTime)) {
      return AvailabilityCheckResult(
        isAvailable: false,
        message: 'Booking tiden er uden for kokkens arbejdstider (${workStart} - ${workEnd})',
      );
    }
    
    return AvailabilityCheckResult(isAvailable: true);
  }
  
  Future<AvailabilityCheckResult> _checkSpecificAvailability(
    String chefId,
    DateTime bookingDate,
    TimeOfDay startTime,
    DateTime endDateTime,
  ) async {
    // Check if there's a specific availability override for this date
    final response = await _supabaseClient
        .from('chef_availability')
        .select()
        .eq('chef_id', chefId)
        .eq('date', bookingDate.toIso8601String().split('T')[0]);
    
    if (response.isEmpty) {
      // No specific availability, use standard hours
      return AvailabilityCheckResult(isAvailable: true);
    }
    
    // Check each availability slot
    for (final availability in response) {
      final isFullDay = availability['is_full_day'] as bool? ?? false;
      
      if (!isFullDay) {
        final availStart = availability['time_start'] as String;
        final availEnd = availability['time_end'] as String;
        
        final startParts = availStart.split(':');
        final endParts = availEnd.split(':');
        
        final availStartTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
        
        final availEndTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
        
        final bookingEndTime = TimeOfDay.fromDateTime(endDateTime);
        
        if (_isTimeInRange(startTime, availStartTime, availEndTime) &&
            _isTimeInRange(bookingEndTime, availStartTime, availEndTime)) {
          return AvailabilityCheckResult(isAvailable: true);
        }
      }
    }
    
    return AvailabilityCheckResult(
      isAvailable: false,
      message: 'Kokken er ikke tilgængelig på det valgte tidspunkt',
    );
  }
  
  Future<AvailabilityCheckResult> _checkTimeOff(
    String chefId,
    DateTime bookingDateTime,
  ) async {
    final response = await _supabaseClient
        .from('chef_time_off')
        .select()
        .eq('chef_id', chefId)
        .lte('start_date', bookingDateTime.toIso8601String())
        .gte('end_date', bookingDateTime.toIso8601String());
    
    if (response.isNotEmpty) {
      final timeOff = response.first;
      final isPublicReason = timeOff['is_public_reason'] as bool? ?? false;
      final reason = timeOff['reason'] as String?;
      
      String message = 'Kokken er ikke tilgængelig på denne dato';
      if (isPublicReason && reason != null) {
        message += ': $reason';
      }
      
      return AvailabilityCheckResult(
        isAvailable: false,
        message: message,
      );
    }
    
    return AvailabilityCheckResult(isAvailable: true);
  }
  
  Future<AvailabilityCheckResult> _checkExistingBookings(
    String chefId,
    DateTime bookingStart,
    DateTime bookingEnd,
  ) async {
    // Get buffer time setting
    final settingsResponse = await _supabaseClient
        .from('chef_schedule_settings')
        .select('buffer_time')
        .eq('chef_id', chefId)
        .maybeSingle();
    
    final bufferMinutes = settingsResponse?['buffer_time'] as int? ?? 60;
    print('   ⏰ Buffer time: $bufferMinutes minutes');
    
    // Add buffer to booking times
    final bufferedStart = bookingStart.subtract(Duration(minutes: bufferMinutes));
    final bufferedEnd = bookingEnd.add(Duration(minutes: bufferMinutes));
    print('   📍 Requested: ${bookingStart.hour}:${bookingStart.minute.toString().padLeft(2, '0')} - ${bookingEnd.hour}:${bookingEnd.minute.toString().padLeft(2, '0')}');
    print('   🔄 With buffer: ${bufferedStart.hour}:${bufferedStart.minute.toString().padLeft(2, '0')} - ${bufferedEnd.hour}:${bufferedEnd.minute.toString().padLeft(2, '0')}');
    
    // Check for conflicting bookings
    final date = bookingStart.toIso8601String().split('T')[0];
    final existingBookings = await _supabaseClient
        .from('bookings')
        .select('start_time, end_time, status')
        .eq('chef_id', chefId)
        .eq('date', date)
        .inFilter('status', ['pending', 'confirmed', 'in_progress']);
    
    print('   📚 Found ${existingBookings.length} existing bookings on $date');
    
    for (final booking in existingBookings) {
      final startTimeStr = booking['start_time'] as String;
      final endTimeStr = booking['end_time'] as String;
      
      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');
      
      final existingStart = DateTime(
        bookingStart.year,
        bookingStart.month,
        bookingStart.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );
      
      final existingEnd = DateTime(
        bookingStart.year,
        bookingStart.month,
        bookingStart.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );
      
      // Check for overlap with buffer
      print('      📌 Existing booking: ${existingStart.hour}:${existingStart.minute.toString().padLeft(2, '0')} - ${existingEnd.hour}:${existingEnd.minute.toString().padLeft(2, '0')} (${booking['status']})');
      
      if (bufferedStart.isBefore(existingEnd) && bufferedEnd.isAfter(existingStart)) {
        print('      ❌ CONFLICT DETECTED! Overlaps with existing booking');
        return AvailabilityCheckResult(
          isAvailable: false,
          message: 'Kokken har allerede en booking på dette tidspunkt (inklusive buffer tid)',
        );
      }
      print('      ✅ No conflict with this booking');
    }
    
    // NEW: Also check for active payment reservations
    final activeReservations = await _supabaseClient
        .from('active_booking_reservations')
        .select('start_time, end_time')
        .eq('chef_id', chefId)
        .eq('date', date);
    
    for (final reservation in activeReservations) {
      final startTimeStr = reservation['start_time'] as String;
      final endTimeStr = reservation['end_time'] as String;
      
      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');
      
      final reservationStart = DateTime(
        bookingStart.year,
        bookingStart.month,
        bookingStart.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );
      
      final reservationEnd = DateTime(
        bookingStart.year,
        bookingStart.month,
        bookingStart.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );
      
      // Check for overlap with buffer
      if (bufferedStart.isBefore(reservationEnd) && bufferedEnd.isAfter(reservationStart)) {
        return AvailabilityCheckResult(
          isAvailable: false,
          message: 'Dette tidspunkt er midlertidigt reserveret af en anden kunde. Prøv igen om et par minutter eller vælg et andet tidspunkt.',
        );
      }
    }
    
    return AvailabilityCheckResult(isAvailable: true);
  }
  
  Future<AvailabilityCheckResult> _checkMaxBookingsPerDay(
    String chefId,
    DateTime bookingDate,
  ) async {
    // Get max bookings setting
    final settingsResponse = await _supabaseClient
        .from('chef_schedule_settings')
        .select('max_bookings_per_day')
        .eq('chef_id', chefId)
        .maybeSingle();
    
    final maxBookings = settingsResponse?['max_bookings_per_day'] as int? ?? 3;
    
    // Count existing bookings for the day
    final date = bookingDate.toIso8601String().split('T')[0];
    final countResponse = await _supabaseClient
        .from('bookings')
        .select('id')
        .eq('chef_id', chefId)
        .eq('date', date)
        .inFilter('status', ['pending', 'confirmed', 'in_progress']);
    
    if (countResponse.length >= maxBookings) {
      return AvailabilityCheckResult(
        isAvailable: false,
        message: 'Kokken har nået det maksimale antal bookinger for denne dag',
      );
    }
    
    return AvailabilityCheckResult(isAvailable: true);
  }
  
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }
  
  String _getDanishDayName(int weekday) {
    switch (weekday) {
      case 1: return 'mandag';
      case 2: return 'tirsdag';
      case 3: return 'onsdag';
      case 4: return 'torsdag';
      case 5: return 'fredag';
      case 6: return 'lørdag';
      case 7: return 'søndag';
      default: return 'mandag';
    }
  }
  
  bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (endMinutes >= startMinutes) {
      // Normal case: start and end on same day
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // End time is past midnight
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
}

class AvailabilityCheckResult {
  final bool isAvailable;
  final String? message;
  
  AvailabilityCheckResult({
    required this.isAvailable,
    this.message,
  });
}