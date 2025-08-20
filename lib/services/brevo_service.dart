import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BrevoService {
  static const String _baseUrl = 'https://api.brevo.com/v3';
  static const int _mailingListId = 12; // Your mailing list ID
  
  // Get API key from environment or use a default (should be in .env file)
  static String get _apiKey => 
      dotenv.env['BREVO_API_KEY'] ?? '';

  /// Add a contact to the mailing list
  static Future<bool> addContactToMailingList({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    bool updateEnabled = true,
  }) async {
    try {
      // Format phone number (ensure it has country code)
      String formattedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      if (!formattedPhone.startsWith('+')) {
        // Assume Danish number if no country code
        if (!formattedPhone.startsWith('45')) {
          formattedPhone = '+45$formattedPhone';
        } else {
          formattedPhone = '+$formattedPhone';
        }
      }

      // Create or update contact
      final contactResponse = await http.post(
        Uri.parse('$_baseUrl/contacts'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'api-key': _apiKey,
        },
        body: jsonEncode({
          'email': email,
          'attributes': {
            'FIRSTNAME': firstName,
            'LASTNAME': lastName,
            'SMS': formattedPhone,
            'PHONE': formattedPhone,
          },
          'listIds': [_mailingListId],
          'updateEnabled': updateEnabled,
        }),
      );

      if (contactResponse.statusCode == 201 || contactResponse.statusCode == 204) {
        print('✅ Contact added to Brevo mailing list successfully');
        return true;
      } else if (contactResponse.statusCode == 400) {
        // Contact might already exist, try to update and add to list
        final updateResponse = await updateContactAndAddToList(
          email: email,
          firstName: firstName,
          lastName: lastName,
          phone: formattedPhone,
        );
        return updateResponse;
      } else {
        print('❌ Failed to add contact to Brevo: ${contactResponse.statusCode}');
        print('Response: ${contactResponse.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error adding contact to Brevo: $e');
      return false;
    }
  }

  /// Update existing contact and add to list
  static Future<bool> updateContactAndAddToList({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      // First, update the contact attributes
      final updateResponse = await http.put(
        Uri.parse('$_baseUrl/contacts/$email'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'api-key': _apiKey,
        },
        body: jsonEncode({
          'attributes': {
            'FIRSTNAME': firstName,
            'LASTNAME': lastName,
            'SMS': phone,
            'PHONE': phone,
          },
          'listIds': [_mailingListId],
        }),
      );

      if (updateResponse.statusCode == 204 || updateResponse.statusCode == 200) {
        print('✅ Contact updated and added to Brevo mailing list');
        return true;
      } else {
        print('❌ Failed to update contact in Brevo: ${updateResponse.statusCode}');
        print('Response: ${updateResponse.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating contact in Brevo: $e');
      return false;
    }
  }

  /// Remove contact from mailing list (for unsubscribe)
  static Future<bool> removeContactFromMailingList(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/contacts/lists/$_mailingListId/contacts/remove'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'api-key': _apiKey,
        },
        body: jsonEncode({
          'emails': [email],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Contact removed from Brevo mailing list');
        return true;
      } else {
        print('❌ Failed to remove contact from Brevo: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error removing contact from Brevo: $e');
      return false;
    }
  }

  /// Send transactional email (e.g., welcome email)
  static Future<bool> sendWelcomeEmail({
    required String email,
    required String firstName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/smtp/email'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'api-key': _apiKey,
        },
        body: jsonEncode({
          'to': [
            {
              'email': email,
              'name': firstName,
            }
          ],
          'sender': {
            'email': 'noreply@dinnerhelp.dk',
            'name': 'DinnerHelp',
          },
          'subject': 'Velkommen til DinnerHelp! 🍽️',
          'htmlContent': '''
            <html>
              <body style="font-family: Arial, sans-serif; padding: 20px; background-color: #f5f5f5;">
                <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px;">
                  <h1 style="color: #79CBC2;">Velkommen til DinnerHelp, $firstName!</h1>
                  <p style="font-size: 16px; line-height: 1.5;">
                    Tak for din tilmelding! Vi er glade for at have dig med i vores fællesskab.
                  </p>
                  <p style="font-size: 16px; line-height: 1.5;">
                    Nu kan du:
                  </p>
                  <ul style="font-size: 16px; line-height: 1.8;">
                    <li>Søge efter professionelle kokke i dit område</li>
                    <li>Booke private madoplevelser derhjemme</li>
                    <li>Nyde restaurantkvalitet i dit eget hjem</li>
                  </ul>
                  <div style="text-align: center; margin-top: 30px;">
                    <a href="https://dinnerhelp.dk" style="background-color: #79CBC2; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
                      Find din kok
                    </a>
                  </div>
                  <p style="font-size: 14px; color: #666; margin-top: 30px;">
                    Har du spørgsmål? Kontakt os på support@dinnerhelp.dk
                  </p>
                </div>
              </body>
            </html>
          ''',
        }),
      );

      if (response.statusCode == 201) {
        print('✅ Welcome email sent successfully');
        return true;
      } else {
        print('❌ Failed to send welcome email: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending welcome email: $e');
      return false;
    }
  }
}