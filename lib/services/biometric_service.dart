import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  static BiometricService get instance => _instance;
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _savedCredentialsKey = 'saved_credentials';
  static const String _paymentProtectionKey = 'payment_protection_enabled';
  
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }
      
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('BiometricService: Error checking biometric availability: $e');
      return false;
    }
  }
  
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('BiometricService: Error getting available biometrics: $e');
      return [];
    }
  }
  
  Future<bool> authenticate({
    String reason = 'Verificer din identitet',
    bool stickyAuth = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
      
      return didAuthenticate;
    } catch (e) {
      debugPrint('BiometricService: Authentication error: $e');
      return false;
    }
  }
  
  Future<bool> isBiometricLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }
  
  Future<void> setBiometricLoginEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    
    if (!enabled) {
      await clearSavedCredentials();
    }
  }
  
  Future<void> saveCredentials(String email, String password) async {
    if (!await isBiometricLoginEnabled()) {
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    
    final credentials = {
      'email': email,
      'password': password,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final encodedCredentials = base64.encode(
      utf8.encode(jsonEncode(credentials))
    );
    
    await prefs.setString(_savedCredentialsKey, encodedCredentials);
    debugPrint('BiometricService: Credentials saved for biometric login');
  }
  
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedCredentials = prefs.getString(_savedCredentialsKey);
      
      if (encodedCredentials == null) {
        return null;
      }
      
      final decodedJson = utf8.decode(base64.decode(encodedCredentials));
      final credentials = jsonDecode(decodedJson);
      
      final timestamp = DateTime.parse(credentials['timestamp']);
      final daysSinceLastLogin = DateTime.now().difference(timestamp).inDays;
      
      if (daysSinceLastLogin > 30) {
        await clearSavedCredentials();
        return null;
      }
      
      return {
        'email': credentials['email'],
        'password': credentials['password'],
      };
    } catch (e) {
      debugPrint('BiometricService: Error retrieving saved credentials: $e');
      return null;
    }
  }
  
  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedCredentialsKey);
    debugPrint('BiometricService: Saved credentials cleared');
  }
  
  Future<bool> authenticateAndLogin() async {
    try {
      if (!await isBiometricLoginEnabled()) {
        debugPrint('BiometricService: Biometric login not enabled');
        return false;
      }
      
      final credentials = await getSavedCredentials();
      if (credentials == null) {
        debugPrint('BiometricService: No saved credentials found');
        return false;
      }
      
      final authenticated = await authenticate(
        reason: 'Log ind med Face ID eller Touch ID',
      );
      
      if (!authenticated) {
        debugPrint('BiometricService: Biometric authentication failed');
        return false;
      }
      
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: credentials['email']!,
        password: credentials['password']!,
      );
      
      if (response.user != null) {
        debugPrint('BiometricService: Successfully logged in with biometrics');
        await saveCredentials(credentials['email']!, credentials['password']!);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('BiometricService: Login error: $e');
      await clearSavedCredentials();
      return false;
    }
  }
  
  Future<bool> isPaymentProtectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_paymentProtectionKey) ?? false;
  }
  
  Future<void> setPaymentProtectionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_paymentProtectionKey, enabled);
  }
  
  Future<bool> authenticateForPayment({
    required String amount,
    required String currency,
  }) async {
    if (!await isPaymentProtectionEnabled()) {
      return true;
    }
    
    final authenticated = await authenticate(
      reason: 'Bekræft betaling på $amount $currency',
    );
    
    return authenticated;
  }
  
  String getBiometricTypeString(List<BiometricType> biometrics) {
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometrisk';
  }
  
  Future<String> getAvailableBiometricString() async {
    final biometrics = await getAvailableBiometrics();
    return getBiometricTypeString(biometrics);
  }
}