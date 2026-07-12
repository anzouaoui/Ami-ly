import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../constants/app_constants.dart';

class StripeService {
  static void initStripe() {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.com.app.amily';
  }

  static Future<bool> payInvoice({
    required String clientSecret,
    required String assmatName,
    required double amount,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Ami-ly',
          style: ThemeMode.system,
          billingDetails: BillingDetails(
            name: assmatName,
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      debugPrint('[Stripe] Error: ${e.error.localizedMessage}');
      rethrow;
    }
  }
}
