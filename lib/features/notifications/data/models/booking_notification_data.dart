import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_notification_data.freezed.dart';
part 'booking_notification_data.g.dart';

@freezed
class BookingNotificationData with _$BookingNotificationData {
  const factory BookingNotificationData({
    required String bookingId,
    required String userId,
    required String chefId,
    required String chefName,
    required String userName,
    required DateTime dateTime,
    required int guestCount,
    required String address,
    required int durationHours,
    String? userEmail,
    String? userPhone,
    String? chefEmail,
    String? chefPhone,
    String? notes,
    double? totalAmount,
    String? paymentStatus,
    List<String>? dishNames,
    Map<String, dynamic>? additionalData,
  }) = _BookingNotificationData;

  factory BookingNotificationData.fromJson(Map<String, dynamic> json) =>
      _$BookingNotificationDataFromJson(json);
}

extension BookingNotificationDataExtension on BookingNotificationData {
  Map<String, dynamic> toNotificationData() {
    return {
      'booking_id': bookingId,
      'user_id': userId,
      'chef_id': chefId,
      'chef_name': chefName,
      'user_name': userName,
      'booking_date': dateTime.toIso8601String().split('T')[0],
      'booking_time': '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
      'booking_datetime': dateTime.toIso8601String(),
      'guest_count': guestCount.toString(),
      'address': address,
      'duration_hours': durationHours.toString(),
      if (userEmail != null) 'user_email': userEmail!,
      if (userPhone != null) 'user_phone': userPhone!,
      if (chefEmail != null) 'chef_email': chefEmail!,
      if (chefPhone != null) 'chef_phone': chefPhone!,
      if (notes != null) 'notes': notes!,
      if (totalAmount != null) 'total_amount': totalAmount!.toStringAsFixed(2),
      if (paymentStatus != null) 'payment_status': paymentStatus!,
      if (dishNames != null && dishNames!.isNotEmpty) 'dish_names': dishNames!.join(', '),
      if (additionalData != null) ...additionalData!,
    };
  }

  String get formattedDate {
    final months = [
      'Januar', 'Februar', 'Marts', 'April', 'Maj', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'December'
    ];
    return '${dateTime.day}. ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String get formattedDateEn {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String get formattedTime {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate kl. $formattedTime';
  }

  String get formattedDateTimeEn {
    return '$formattedDateEn at $formattedTime';
  }
}

@freezed
class NotificationTemplate with _$NotificationTemplate {
  const factory NotificationTemplate({
    required String key,
    required String nameDa,
    required String nameEn,
    required String subjectDa,
    required String subjectEn,
    required String contentDa,
    required String contentEn,
    String? htmlContentDa,
    String? htmlContentEn,
    @Default([]) List<String> requiredVariables,
    @Default({}) Map<String, String> defaultValues,
  }) = _NotificationTemplate;

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
      _$NotificationTemplateFromJson(json);
}

class NotificationTemplates {
  static const Map<String, NotificationTemplate> templates = {
    'booking_confirmation_user': NotificationTemplate(
      key: 'booking_confirmation_user',
      nameDa: 'Booking Bekræftelse - Bruger',
      nameEn: 'Booking Confirmation - User',
      subjectDa: 'Din booking er bekræftet! 🎉',
      subjectEn: 'Your booking is confirmed! 🎉',
      contentDa: '''
Hej {{user_name}},

Din booking er bekræftet!

Detaljer:
• Kok: {{chef_name}}
• Dato: {{booking_date}}
• Tid: {{booking_time}}
• Personer: {{guest_count}}
• Adresse: {{address}}

Vi glæder os til at give dig en fantastisk madoplevelse!

Med venlig hilsen,
DinnerHelp-teamet
      ''',
      contentEn: '''
Hi {{user_name}},

Your booking is confirmed!

Details:
• Chef: {{chef_name}}
• Date: {{booking_date}}
• Time: {{booking_time}}
• Guests: {{guest_count}}
• Address: {{address}}

We look forward to providing you with an amazing dining experience!

Best regards,
The DinnerHelp Team
      ''',
      htmlContentDa: '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Booking Bekræftelse</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .header { background-color: #2E7D32; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .details { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .footer { background-color: #f9f9f9; padding: 15px; text-align: center; border-top: 1px solid #eee; }
        .button { background-color: #2E7D32; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎉 Din booking er bekræftet!</h1>
    </div>
    <div class="content">
        <p>Hej {{user_name}},</p>
        <p>Vi er glade for at kunne bekræfte din booking hos DinnerHelp!</p>
        
        <div class="details">
            <h3>Booking detaljer:</h3>
            <p><strong>Kok:</strong> {{chef_name}}</p>
            <p><strong>Dato:</strong> {{booking_date}}</p>
            <p><strong>Tid:</strong> {{booking_time}}</p>
            <p><strong>Antal personer:</strong> {{guest_count}}</p>
            <p><strong>Adresse:</strong> {{address}}</p>
        </div>
        
        <p>Sørg for at være klar og have køkkenet tilgængeligt for kokken. Du vil modtage påmindelser både 24 timer og 1 time før din booking.</p>
        
        <a href="https://dinnerhelp.dk/bookings/{{booking_id}}" class="button">Se booking detaljer</a>
    </div>
    <div class="footer">
        <p>Med venlig hilsen,<br><strong>DinnerHelp-teamet</strong></p>
        <p>Har du spørgsmål? Kontakt os på support@dinnerhelp.dk</p>
    </div>
</body>
</html>
      ''',
      htmlContentEn: '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Booking Confirmation</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .header { background-color: #2E7D32; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .details { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .footer { background-color: #f9f9f9; padding: 15px; text-align: center; border-top: 1px solid #eee; }
        .button { background-color: #2E7D32; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎉 Your booking is confirmed!</h1>
    </div>
    <div class="content">
        <p>Hi {{user_name}},</p>
        <p>We're excited to confirm your booking with DinnerHelp!</p>
        
        <div class="details">
            <h3>Booking details:</h3>
            <p><strong>Chef:</strong> {{chef_name}}</p>
            <p><strong>Date:</strong> {{booking_date}}</p>
            <p><strong>Time:</strong> {{booking_time}}</p>
            <p><strong>Guests:</strong> {{guest_count}}</p>
            <p><strong>Address:</strong> {{address}}</p>
        </div>
        
        <p>Make sure you're ready and have the kitchen available for the chef. You'll receive reminders both 24 hours and 1 hour before your booking.</p>
        
        <a href="https://dinnerhelp.dk/bookings/{{booking_id}}" class="button">View booking details</a>
    </div>
    <div class="footer">
        <p>Best regards,<br><strong>The DinnerHelp Team</strong></p>
        <p>Have questions? Contact us at support@dinnerhelp.dk</p>
    </div>
</body>
</html>
      ''',
      requiredVariables: [
        'user_name', 'chef_name', 'booking_date', 'booking_time', 
        'guest_count', 'address', 'booking_id'
      ],
    ),

    'booking_confirmation_chef': NotificationTemplate(
      key: 'booking_confirmation_chef',
      nameDa: 'Booking Bekræftelse - Kok',
      nameEn: 'Booking Confirmation - Chef',
      subjectDa: 'Ny booking bekræftet! 👨‍🍳',
      subjectEn: 'New booking confirmed! 👨‍🍳',
      contentDa: '''
Hej {{chef_name}},

Du har fået en ny booking!

Detaljer:
• Kunde: {{user_name}}
• Dato: {{booking_date}}
• Tid: {{booking_time}}
• Personer: {{guest_count}}
• Adresse: {{address}}

Log ind på din konto for at se alle detaljer og forberede dig på madoplevelsen.

Held og lykke med din madlavning!

Med venlig hilsen,
DinnerHelp-teamet
      ''',
      contentEn: '''
Hi {{chef_name}},

You have received a new booking!

Details:
• Customer: {{user_name}}
• Date: {{booking_date}}
• Time: {{booking_time}}
• Guests: {{guest_count}}
• Address: {{address}}

Log in to your account to see all details and prepare for the dining experience.

Good luck with your cooking!

Best regards,
The DinnerHelp Team
      ''',
      requiredVariables: [
        'chef_name', 'user_name', 'booking_date', 'booking_time', 
        'guest_count', 'address', 'booking_id'
      ],
    ),

    'booking_reminder_24h': NotificationTemplate(
      key: 'booking_reminder_24h',
      nameDa: 'Booking Påmindelse - 24 timer',
      nameEn: 'Booking Reminder - 24 hours',
      subjectDa: 'Påmindelse: Din madoplevelse i morgen! 🍽️',
      subjectEn: 'Reminder: Your dining experience tomorrow! 🍽️',
      contentDa: '''
Hej {{user_name}},

Dette er en påmindelse om din madoplevelse i morgen!

Detaljer:
• Kok: {{chef_name}}
• Dato: {{booking_date}}
• Tid: {{booking_time}}
• Personer: {{guest_count}}
• Adresse: {{address}}

Sørg for at:
✓ Have køkkenet rent og klar
✓ Skaffe alle nødvendige ingredienser (hvis aftalt)
✓ Være hjemme i god tid før kokken ankommer

Vi glæder os til din madoplevelse!

Med venlig hilsen,
DinnerHelp-teamet
      ''',
      contentEn: '''
Hi {{user_name}},

This is a reminder about your dining experience tomorrow!

Details:
• Chef: {{chef_name}}
• Date: {{booking_date}}
• Time: {{booking_time}}
• Guests: {{guest_count}}
• Address: {{address}}

Make sure to:
✓ Have the kitchen clean and ready
✓ Get all necessary ingredients (if agreed)
✓ Be home well before the chef arrives

We look forward to your dining experience!

Best regards,
The DinnerHelp Team
      ''',
      requiredVariables: [
        'user_name', 'chef_name', 'booking_date', 'booking_time', 
        'guest_count', 'address'
      ],
    ),

    'booking_complete_review': NotificationTemplate(
      key: 'booking_complete_review',
      nameDa: 'Anmodning om anmeldelse',
      nameEn: 'Review Request',
      subjectDa: 'Hvordan var din madoplevelse? ⭐',
      subjectEn: 'How was your dining experience? ⭐',
      contentDa: '''
Hej {{user_name}},

Vi håber, du havde en fantastisk madoplevelse med {{chef_name}}!

Vi vil være meget taknemmelige, hvis du vil dele din oplevelse med andre ved at skrive en anmeldelse.

Din feedback hjælper andre brugere med at finde de bedste kokke og hjælper os med at forbedre vores service.

Det tager kun et par minutter!

Med venlig hilsen,
DinnerHelp-teamet
      ''',
      contentEn: '''
Hi {{user_name}},

We hope you had an amazing dining experience with {{chef_name}}!

We would be very grateful if you would share your experience with others by writing a review.

Your feedback helps other users find the best chefs and helps us improve our service.

It only takes a few minutes!

Best regards,
The DinnerHelp Team
      ''',
      requiredVariables: ['user_name', 'chef_name', 'booking_id'],
    ),

    'booking_modified': NotificationTemplate(
      key: 'booking_modified',
      nameDa: 'Booking Ændring',
      nameEn: 'Booking Modification',
      subjectDa: 'Din booking er blevet opdateret',
      subjectEn: 'Your booking has been updated',
      contentDa: '''
Hej {{user_name}},

Din booking med {{chef_name}} er blevet opdateret.

Ændringer:
{{changes}}

Opdaterede booking detaljer:
• Dato: {{booking_date}}
• Tid: {{booking_time}}
• Personer: {{guest_count}}
• Adresse: {{address}}

Hvis du har spørgsmål til disse ændringer, er du velkommen til at kontakte os.

Med venlig hilsen,
DinnerHelp-teamet
      ''',
      contentEn: '''
Hi {{user_name}},

Your booking with {{chef_name}} has been updated.

Changes:
{{changes}}

Updated booking details:
• Date: {{booking_date}}
• Time: {{booking_time}}
• Guests: {{guest_count}}
• Address: {{address}}

If you have questions about these changes, please feel free to contact us.

Best regards,
The DinnerHelp Team
      ''',
      requiredVariables: [
        'user_name', 'chef_name', 'changes', 'booking_date', 
        'booking_time', 'guest_count', 'address'
      ],
    ),

    'booking_cancelled': NotificationTemplate(
      key: 'booking_cancelled',
      nameDa: 'Booking Aflyst',
      nameEn: 'Booking Cancelled',
      subjectDa: 'Din booking er blevet aflyst',
      subjectEn: 'Your booking has been cancelled',
      contentDa: '''
Hej {{user_name}},

Vi er kede af at meddele, at din booking med {{chef_name}} desværre er blevet aflyst.

Booking detaljer:
• Dato: {{booking_date}}
• Tid: {{booking_time}}
• Adresse: {{address}}

Årsag: {{cancellation_reason}}

Hvis du har betalt, vil beløbet blive refunderet inden for 3-5 arbejdsdage.

Vi undskylder for ulejligheden og håber at kunne hjælpe dig med en ny booking snart.

Med venlig hilsen,
DinnerHelp-teamet
      ''',
      contentEn: '''
Hi {{user_name}},

We're sorry to inform you that your booking with {{chef_name}} has unfortunately been cancelled.

Booking details:
• Date: {{booking_date}}
• Time: {{booking_time}}
• Address: {{address}}

Reason: {{cancellation_reason}}

If you have made a payment, the amount will be refunded within 3-5 business days.

We apologize for the inconvenience and hope to help you with a new booking soon.

Best regards,
The DinnerHelp Team
      ''',
      requiredVariables: [
        'user_name', 'chef_name', 'booking_date', 'booking_time', 
        'address', 'cancellation_reason'
      ],
    ),
  };

  static NotificationTemplate? getTemplate(String key) {
    return templates[key];
  }

  static String renderTemplate(
    String template, 
    Map<String, dynamic> variables,
  ) {
    String rendered = template;
    
    variables.forEach((key, value) {
      rendered = rendered.replaceAll('{{$key}}', value?.toString() ?? '');
    });
    
    return rendered;
  }
}