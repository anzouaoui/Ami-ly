# Ignorer les avertissements liés aux classes manquantes de Stripe Push Provisioning
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.pushprovisioning.**

# Règle générale pour Stripe si d'autres avertissements apparaissent
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**