import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StripeService {
  static StripeService? _instance;
  final SupabaseClient _supabaseClient;
  
  StripeService._({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;
  
  static StripeService get instance {
    _instance ??= StripeService._(
      supabaseClient: Supabase.instance.client,
    );
    return _instance!;
  }
  
  /// Initialize Stripe with publishable key
  Future<void> initialize() async {
    try {
      // Use Stripe test publishable key
      // This is safe to expose as it's a publishable key (not secret key)
      // Replace with your production publishable key when ready
      const publishableKey = 'pk_test_51R51biD5hbeubG7DiYXGn3q9lZ7Cic6K1Mv6yCeKPnA02D8ei7iGvEpsNK1HWnj00qHsejbJa6YpatOYbCRvKiIX00dJa8Q558';
      
      Stripe.publishableKey = publishableKey;
      Stripe.merchantIdentifier = 'merchant.com.dinnerhelp';
      Stripe.urlScheme = 'flutterstripe';
      await Stripe.instance.applySettings();
      
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Stripe: $e');
      rethrow;
    }
  }
  
  /// Create payment intent via Edge Function and return client secret
  /// Now supports both old (with bookingId) and new (with bookingData) approaches
  Future<String> createPaymentIntent({
    String? bookingId, // Now optional for backward compatibility
    required int amount,
    required int serviceFeeAmount,
    int? paymentProcessingFee, // New parameter for payment processing fee
    required int vatAmount,
    required String chefId,
    Map<String, dynamic>? bookingData, // New parameter for reservation system
  }) async {
    try {
      // Get chef's Stripe account ID
      final chefResponse = await _supabaseClient
          .from('chefs')
          .select('stripe_account_id')
          .eq('id', chefId)
          .maybeSingle();
      
      final chefStripeAccountId = chefResponse?['stripe_account_id'];
      
      if (chefStripeAccountId == null || chefStripeAccountId.toString().isEmpty) {
        throw Exception('Chef does not have a valid Stripe account');
      }
      
      // Prepare request body
      final requestBody = {
        'amount': amount,
        'service_fee_amount': serviceFeeAmount,
        'payment_processing_fee': paymentProcessingFee ?? 0,
        'vat_amount': vatAmount,
        'chef_stripe_account_id': chefStripeAccountId,
      };
      
      // Add either booking_id (old) or booking_data (new)
      if (bookingId != null) {
        requestBody['booking_id'] = bookingId;
      } else if (bookingData != null) {
        requestBody['booking_data'] = bookingData;
      } else {
        throw Exception('Either bookingId or bookingData must be provided');
      }
      
      // Create payment intent via Edge Function
      final response = await _supabaseClient.functions.invoke(
        'create-payment-intent',
        body: requestBody,
      );
      
      if (response.data == null || response.data['client_secret'] == null) {
        throw Exception('Failed to create payment intent: ${response.data?['error'] ?? 'Unknown error'}');
      }
      
      return response.data['client_secret'];
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      rethrow;
    }
  }
  
  /// Initialize payment sheet with payment intent
  Future<void> initPaymentSheet({
    required String clientSecret,
    required String customerEmail,
    required String merchantDisplayName,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          customerEphemeralKeySecret: null,
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF79CBC2),
            ),
            shapes: const PaymentSheetShape(
              borderRadius: 12.0,
              shadow: PaymentSheetShadowParams(
                color: Colors.black12,
                opacity: 0.1,
              ),
            ),
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'DK',
            currencyCode: 'DKK',
            testEnv: true,
          ),
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'DK',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error initializing payment sheet: $e');
      rethrow;
    }
  }
  
  /// Present payment sheet to user
  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        debugPrint('Payment cancelled by user');
        return false;
      }
      debugPrint('Payment failed: ${e.error.message}');
      throw Exception('Payment failed: ${e.error.message}');
    } catch (e) {
      debugPrint('Payment error: $e');
      throw Exception('Payment error: $e');
    }
  }
  
  /// Process payment with saved card (for returning customers)
  Future<bool> processPaymentWithSavedCard({
    required String paymentMethodId,
    required String clientSecret,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethodId,
          ),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error processing payment with saved card: $e');
      return false;
    }
  }
  
  /// Create setup intent for saving cards
  Future<String?> createSetupIntent({
    required String customerId,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'create-setup-intent',
        body: {
          'customer_id': customerId,
        },
      );
      
      if (response.data != null && response.data['client_secret'] != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (e) {
      debugPrint('Error creating setup intent: $e');
      return null;
    }
  }
  
  /// Capture payment after service is completed
  Future<bool> capturePayment({
    required String bookingId,
    int? actualAmount,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'capture-payment',
        body: {
          'booking_id': bookingId,
          if (actualAmount != null) 'actual_amount': actualAmount,
        },
      );
      
      return response.data?['success'] == true;
    } catch (e) {
      debugPrint('Error capturing payment: $e');
      return false;
    }
  }
  
  /// Process refund
  Future<bool> processRefund({
    required String bookingId,
    required int amount,
    required String reason,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'process-refund',
        body: {
          'booking_id': bookingId,
          'amount': amount,
          'reason': reason,
        },
      );
      
      return response.data?['success'] == true;
    } catch (e) {
      debugPrint('Error processing refund: $e');
      return false;
    }
  }
}