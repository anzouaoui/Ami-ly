# Ignorer les avertissements liés aux classes manquantes de Stripe Push Provisioning
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.pushprovisioning.**

# Règle générale pour Stripe si d'autres avertissements apparaissent
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Ignorer les avertissements des classes manquantes des reconnaissances de
# texte ML Kit non utilisées (chinois, devanagari, japonais, coréen)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**