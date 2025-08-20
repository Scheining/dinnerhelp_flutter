import 'dart:convert';
import 'package:http/http.dart' as http;

class DawaAddress {
  final String id;
  final String tekst; // Full address text
  final String adresseringsnavn; // Address name for labels
  final String vejnavn;
  final String husnr;
  final String etage;
  final String door;
  final String postnr;
  final String postnrnavn;
  final String kommune;
  final double? x; // Longitude
  final double? y; // Latitude

  DawaAddress({
    required this.id,
    required this.tekst,
    required this.adresseringsnavn,
    required this.vejnavn,
    required this.husnr,
    this.etage = '',
    this.door = '',
    required this.postnr,
    required this.postnrnavn,
    required this.kommune,
    this.x,
    this.y,
  });

  factory DawaAddress.fromJson(Map<String, dynamic> json) {
    final adgangsadresse = json['adgangsadresse'] ?? {};
    final vejstykke = adgangsadresse['vejstykke'] ?? {};
    final postnummer = adgangsadresse['postnummer'] ?? {};
    final kommune = adgangsadresse['kommune'] ?? {};
    
    // Extract coordinates if available
    final koordinater = adgangsadresse['adgangspunkt']?['koordinater'] ?? [];
    double? longitude = koordinater.length > 0 ? koordinater[0]?.toDouble() : null;
    double? latitude = koordinater.length > 1 ? koordinater[1]?.toDouble() : null;

    return DawaAddress(
      id: json['id'] ?? '',
      tekst: json['tekst'] ?? '',
      adresseringsnavn: json['adresseringsnavn'] ?? '',
      vejnavn: vejstykke['navn'] ?? '',
      husnr: adgangsadresse['husnr'] ?? '',
      etage: json['etage'] ?? '',
      door: json['dør'] ?? '',
      postnr: postnummer['nr'] ?? '',
      postnrnavn: postnummer['navn'] ?? '',
      kommune: kommune['navn'] ?? '',
      x: longitude,
      y: latitude,
    );
  }

  String get fullAddress {
    String address = '$vejnavn $husnr';
    if (etage.isNotEmpty) address += ', $etage';
    if (door.isNotEmpty) address += '. $door';
    address += ', $postnr $postnrnavn';
    return address;
  }

  String get shortAddress {
    return '$vejnavn $husnr, $postnr $postnrnavn';
  }
}

class DawaAddressService {
  static const String _baseUrl = 'https://api.dataforsyningen.dk';
  static const int _maxResults = 10;

  /// Search for addresses with autocomplete
  static Future<List<DawaAddress>> searchAddresses(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Use simpler autocomplete endpoint
      final uri = Uri.parse('$_baseUrl/autocomplete').replace(
        queryParameters: {
          'q': query,
          'type': 'adresse',
          'per_side': _maxResults.toString(),
        },
      );

      print('DAWA API Request: $uri');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('DAWA API Response Status: ${response.statusCode}');
      print('DAWA API Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('DAWA API Results: ${data.length} items found');
        
        // Filter only actual addresses (not street names)
        final addresses = data.where((item) {
          // Check if it has address data
          return item['data'] != null && 
                 item['data']['id'] != null &&
                 item['data']['vejnavn'] != null &&
                 item['data']['husnr'] != null;
        }).map((item) {
          final addressData = item['data'] as Map<String, dynamic>;
          
          // Build the display text
          String displayText = item['tekst']?.toString().trim() ?? '';
          if (displayText.isEmpty) {
            displayText = '${addressData['vejnavn']} ${addressData['husnr']}, ${addressData['postnr']} ${addressData['postnrnavn']}';
          }
          
          return DawaAddress(
            id: addressData['id'] ?? '',
            tekst: displayText,
            adresseringsnavn: addressData['adresseringsvejnavn'] ?? addressData['vejnavn'] ?? '',
            vejnavn: addressData['vejnavn'] ?? '',
            husnr: addressData['husnr'] ?? '',
            etage: addressData['etage'] ?? '',
            door: addressData['dør'] ?? '',
            postnr: addressData['postnr'] ?? '',
            postnrnavn: addressData['postnrnavn'] ?? '',
            kommune: addressData['kommunenavn'] ?? '',
            x: addressData['x']?.toDouble(),
            y: addressData['y']?.toDouble(),
          );
        }).toList();
        
        print('Filtered to ${addresses.length} actual addresses');
        return addresses;
      } else {
        print('DAWA API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching addresses from DAWA: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Get full address details by ID
  static Future<DawaAddress?> getAddressById(String addressId) async {
    try {
      final uri = Uri.parse('$_baseUrl/adresser/$addressId');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DawaAddress.fromJson(data);
      } else {
        print('DAWA API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching address details from DAWA: $e');
      return null;
    }
  }

  /// Search addresses by postal code
  static Future<List<DawaAddress>> searchByPostalCode(String postalCode) async {
    if (postalCode.trim().isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl/adresser').replace(
        queryParameters: {
          'postnr': postalCode,
          'per_side': _maxResults.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DawaAddress.fromJson(item)).toList();
      } else {
        print('DAWA API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching addresses by postal code: $e');
      return [];
    }
  }

  /// Reverse geocoding - get address from coordinates
  static Future<DawaAddress?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/adresser/reverse').replace(
        queryParameters: {
          'x': longitude.toString(),
          'y': latitude.toString(),
          'srid': '4326', // WGS84 coordinate system
        },
      );

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DawaAddress.fromJson(data);
      } else {
        print('DAWA API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error with reverse geocoding: $e');
      return null;
    }
  }
}