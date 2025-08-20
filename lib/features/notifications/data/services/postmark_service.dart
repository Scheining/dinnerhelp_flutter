import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../models/booking_notification_data.dart';

abstract class EmailService {
  Future<Either<Failure, void>> sendEmailNotification(NotificationEntity notification);
  Future<Either<Failure, void>> sendTemplateEmail({
    required String to,
    required String templateKey,
    required Map<String, dynamic> templateModel,
    required String language,
    String? fromEmail,
    String? fromName,
  });
  Future<Either<Failure, void>> sendTransactionalEmail({
    required String to,
    required String subject,
    required String htmlBody,
    String? textBody,
    String? fromEmail,
    String? fromName,
    Map<String, String>? headers,
  });
}

class PostmarkService implements EmailService {
  static const String _baseUrl = 'https://api.postmarkapp.com';
  final String _apiToken;
  final String _defaultFromEmail;
  final String _defaultFromName;
  final http.Client _httpClient;
  
  PostmarkService({
    required String apiToken,
    required String defaultFromEmail,
    required String defaultFromName,
    http.Client? httpClient,
  }) : _apiToken = apiToken,
       _defaultFromEmail = defaultFromEmail,
       _defaultFromName = defaultFromName,
       _httpClient = httpClient ?? http.Client();

  @override
  Future<Either<Failure, void>> sendEmailNotification(NotificationEntity notification) async {
    try {
      // Get user's email and template data from notification
      final userEmail = notification.data['user_email'] as String?;
      if (userEmail == null) {
        return Left(ValidationFailure('User email not found in notification data'));
      }

      if (notification.templateId == null) {
        return Left(ValidationFailure('Template ID not found in notification'));
      }

      // Get template and render content
      final template = NotificationTemplates.getTemplate(notification.templateId!);
      if (template == null) {
        return Left(ValidationFailure('Template not found: ${notification.templateId}'));
      }

      // Determine language from notification data or default to Danish
      final language = notification.data['language'] as String? ?? 'da';
      
      // Render template content
      final subject = language == 'da' ? template.subjectDa : template.subjectEn;
      final htmlContent = language == 'da' ? template.htmlContentDa : template.htmlContentEn;
      final textContent = language == 'da' ? template.contentDa : template.contentEn;

      final renderedSubject = NotificationTemplates.renderTemplate(subject, notification.data);
      final renderedHtmlContent = htmlContent != null
          ? NotificationTemplates.renderTemplate(htmlContent, notification.data)
          : NotificationTemplates.renderTemplate(textContent, notification.data);
      final renderedTextContent = NotificationTemplates.renderTemplate(textContent, notification.data);

      return await sendTransactionalEmail(
        to: userEmail,
        subject: renderedSubject,
        htmlBody: renderedHtmlContent,
        textBody: renderedTextContent,
      );
    } catch (e) {
      return Left(ServerFailure('Failed to send email notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendTemplateEmail({
    required String to,
    required String templateKey,
    required Map<String, dynamic> templateModel,
    required String language,
    String? fromEmail,
    String? fromName,
  }) async {
    try {
      final template = NotificationTemplates.getTemplate(templateKey);
      if (template == null) {
        return Left(ValidationFailure('Template not found: $templateKey'));
      }

      // Render template content
      final subject = language == 'da' ? template.subjectDa : template.subjectEn;
      final htmlContent = language == 'da' ? template.htmlContentDa : template.htmlContentEn;
      final textContent = language == 'da' ? template.contentDa : template.contentEn;

      final renderedSubject = NotificationTemplates.renderTemplate(subject, templateModel);
      final renderedHtmlContent = htmlContent != null
          ? NotificationTemplates.renderTemplate(htmlContent, templateModel)
          : NotificationTemplates.renderTemplate(textContent, templateModel);
      final renderedTextContent = NotificationTemplates.renderTemplate(textContent, templateModel);

      return await sendTransactionalEmail(
        to: to,
        subject: renderedSubject,
        htmlBody: renderedHtmlContent,
        textBody: renderedTextContent,
        fromEmail: fromEmail,
        fromName: fromName,
      );
    } catch (e) {
      return Left(ServerFailure('Failed to send template email: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendTransactionalEmail({
    required String to,
    required String subject,
    required String htmlBody,
    String? textBody,
    String? fromEmail,
    String? fromName,
    Map<String, String>? headers,
  }) async {
    try {
      final emailData = {
        'From': '${fromName ?? _defaultFromName} <${fromEmail ?? _defaultFromEmail}>',
        'To': to,
        'Subject': subject,
        'HtmlBody': htmlBody,
        if (textBody != null) 'TextBody': textBody,
        'MessageStream': 'outbound',
        if (headers != null) 'Headers': headers.entries.map((e) => {
          'Name': e.key,
          'Value': e.value,
        }).toList(),
      };

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/email'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Postmark-Server-Token': _apiToken,
        },
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        final errorData = json.decode(response.body);
        return Left(ServerFailure(
          'Failed to send email: ${errorData['Message'] ?? response.body}'
        ));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to send email: $e'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getDeliveryStatistics() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/deliverystats'),
        headers: {
          'Accept': 'application/json',
          'X-Postmark-Server-Token': _apiToken,
        },
      );

      if (response.statusCode == 200) {
        final stats = json.decode(response.body) as Map<String, dynamic>;
        return Right(stats);
      } else {
        return Left(ServerFailure('Failed to get delivery statistics: ${response.body}'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to get delivery statistics: $e'));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getRecentBounces({
    int? count,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (count != null) queryParams['count'] = count.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse('$_baseUrl/bounces').replace(queryParameters: queryParams);
      
      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Postmark-Server-Token': _apiToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final bounces = (data['Bounces'] as List).cast<Map<String, dynamic>>();
        return Right(bounces);
      } else {
        return Left(ServerFailure('Failed to get bounces: ${response.body}'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to get bounces: $e'));
    }
  }

  Future<Either<Failure, void>> suppressEmail(String email, String reason) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/suppressions'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Postmark-Server-Token': _apiToken,
        },
        body: json.encode({
          'Suppressions': [
            {
              'EmailAddress': email,
              'SuppressionReason': reason,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure('Failed to suppress email: ${response.body}'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to suppress email: $e'));
    }
  }
}

// Mock implementation for testing and development
class MockEmailService implements EmailService {
  final List<Map<String, dynamic>> _sentEmails = [];
  
  List<Map<String, dynamic>> get sentEmails => List.unmodifiable(_sentEmails);
  
  void clearSentEmails() {
    _sentEmails.clear();
  }

  @override
  Future<Either<Failure, void>> sendEmailNotification(NotificationEntity notification) async {
    _sentEmails.add({
      'type': 'notification',
      'notification_id': notification.id,
      'user_id': notification.userId,
      'template_id': notification.templateId,
      'title': notification.title,
      'content': notification.content,
      'data': notification.data,
      'sent_at': DateTime.now().toIso8601String(),
    });
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendTemplateEmail({
    required String to,
    required String templateKey,
    required Map<String, dynamic> templateModel,
    required String language,
    String? fromEmail,
    String? fromName,
  }) async {
    _sentEmails.add({
      'type': 'template',
      'to': to,
      'template_key': templateKey,
      'template_model': templateModel,
      'language': language,
      'from_email': fromEmail,
      'from_name': fromName,
      'sent_at': DateTime.now().toIso8601String(),
    });
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendTransactionalEmail({
    required String to,
    required String subject,
    required String htmlBody,
    String? textBody,
    String? fromEmail,
    String? fromName,
    Map<String, String>? headers,
  }) async {
    _sentEmails.add({
      'type': 'transactional',
      'to': to,
      'subject': subject,
      'html_body': htmlBody,
      'text_body': textBody,
      'from_email': fromEmail,
      'from_name': fromName,
      'headers': headers,
      'sent_at': DateTime.now().toIso8601String(),
    });
    return const Right(null);
  }
}

// Extension for easy email validation
extension EmailValidation on String {
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }
}

// Utility class for email formatting and localization
class EmailFormatter {
  static String formatBookingDate(DateTime date, String language) {
    if (language == 'da') {
      final months = [
        'januar', 'februar', 'marts', 'april', 'maj', 'juni',
        'juli', 'august', 'september', 'oktober', 'november', 'december'
      ];
      return '${date.day}. ${months[date.month - 1]} ${date.year}';
    } else {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  static String formatBookingTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatCurrency(double amount, String language) {
    if (language == 'da') {
      return '${amount.toStringAsFixed(0)} kr.';
    } else {
      return 'DKK ${amount.toStringAsFixed(0)}';
    }
  }

  static Map<String, dynamic> buildBookingEmailData(
    BookingNotificationData booking,
    String language,
  ) {
    return {
      'booking_id': booking.bookingId,
      'user_name': booking.userName,
      'chef_name': booking.chefName,
      'booking_date': formatBookingDate(booking.dateTime, language),
      'booking_time': formatBookingTime(booking.dateTime),
      'booking_datetime': booking.dateTime.toIso8601String(),
      'guest_count': booking.guestCount.toString(),
      'address': booking.address,
      'duration_hours': booking.durationHours.toString(),
      if (booking.userEmail != null) 'user_email': booking.userEmail!,
      if (booking.chefEmail != null) 'chef_email': booking.chefEmail!,
      if (booking.totalAmount != null) 
        'total_amount': formatCurrency(booking.totalAmount!, language),
      if (booking.notes != null) 'notes': booking.notes!,
      'language': language,
    };
  }
}