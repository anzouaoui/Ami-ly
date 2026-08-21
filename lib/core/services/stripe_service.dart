import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/app_env.dart';

class StripeService {
  static void initStripe() {
    final publishableKey = AppEnv.stripePublishableKey.trim();
    if (publishableKey.isEmpty) {
      debugPrint(
        '[Ami-ly] STRIPE_PUBLISHABLE_KEY manquante : les paiements seront '
        'indisponibles. Renseignez-la dans .env (voir .env.example).',
      );
      return;
    }
    Stripe.publishableKey = publishableKey;
    Stripe.merchantIdentifier = 'merchant.com.app.amily';
  }

  static Future<bool> payInvoice({
    required String clientSecret,
    required String assmatName,
    required double amount,
  }) async {
    if (AppEnv.stripePublishableKey.trim().isEmpty) {
      throw StateError(
        'STRIPE_PUBLISHABLE_KEY manquante : paiement impossible. '
        'Renseignez-la dans .env puis relancez avec '
        '--dart-define-from-file=.env',
      );
    }
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
