import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../features/auth/data/models/assmat_profile_model.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

/// Éléments de vérification attendus sur le profil d'une assistante maternelle
/// avant de pouvoir créer un contrat (engagement réciproque ou CDI).
enum AssmatVerificationIssue { identity, accreditation, criminalRecord }

/// Retourne `true` si le profil assmat est entièrement vérifié.
bool isAssmatFullyVerified(AssmatProfileModel? profile) =>
    profile?.isFullyVerified ?? false;

/// Liste les éléments de vérification manquants du profil assmat.
///
/// Doit rester cohérent avec `AssmatProfileModel.isFullyVerified` :
/// - identité vérifiée + document d'identité non expiré ;
/// - agrément PMI valide (date d'expiration dans le futur) ;
/// - casier judiciaire fourni.
List<AssmatVerificationIssue> computeMissingAssmatVerification(
  AssmatProfileModel? profile,
) {
  if (profile == null) return AssmatVerificationIssue.values;
  final issues = <AssmatVerificationIssue>[];
  final identityDocValid = profile.identityDocumentExpiry != null &&
      profile.identityDocumentExpiry!.isAfter(DateTime.now());
  if (!profile.isIdentityVerified || !identityDocValid) {
    issues.add(AssmatVerificationIssue.identity);
  }
  final accreditationValid = profile.accreditationExpiry != null &&
      profile.accreditationExpiry!.isAfter(DateTime.now());
  if (!accreditationValid) {
    issues.add(AssmatVerificationIssue.accreditation);
  }
  if (profile.criminalRecordUrl == null ||
      profile.criminalRecordUrl!.isEmpty) {
    issues.add(AssmatVerificationIssue.criminalRecord);
  }
  return issues;
}

/// Garde de création de contrat : vérifie que le profil assmat est
/// entièrement vérifié, sinon affiche la modale explicative et
/// retourne `false` (l'action est interceptée).
Future<bool> ensureAssmatVerifiedForContract({
  required BuildContext context,
  required bool isAssmatSide,
  AssmatProfileModel? profile,
  VoidCallback? onCompleteProfile,
}) async {
  if (isAssmatFullyVerified(profile)) return true;
  await showUnverifiedProfileSheet(
    context: context,
    isAssmatSide: isAssmatSide,
    issues: computeMissingAssmatVerification(profile),
    onCompleteProfile: onCompleteProfile,
  );
  return false;
}

/// Attend si nécessaire la première émission d'un provider stream pour éviter
/// un faux négatif quand le provider vient tout juste d'être lu.
///
/// Un profil absent (stream qui émet `null`) est retourné tel quel : la garde
/// le traite alors comme non vérifié.
Future<AssmatProfileModel?> resolveAssmatProfile(
  WidgetRef ref,
  String assmatUid,
) async {
  if (assmatUid.isEmpty) return null;
  try {
    return await ref
        .read(assmatProfileByUidProvider(assmatUid).future)
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    return null;
  }
}

/// Profil assmat de l'utilisatrice courante (côté assmat).
Future<AssmatProfileModel?> resolveOwnAssmatProfile(WidgetRef ref) async {
  try {
    return await ref
        .read(assmatProfileProvider.future)
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    return null;
  }
}

/// Affiche la modale expliquant pourquoi la création de contrat est bloquée.
Future<void> showUnverifiedProfileSheet({
  required BuildContext context,
  required bool isAssmatSide,
  List<AssmatVerificationIssue>? issues,
  VoidCallback? onCompleteProfile,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (_) => UnverifiedProfileSheet(
      isAssmatSide: isAssmatSide,
      issues: issues,
      onCompleteProfile: onCompleteProfile,
    ),
  );
}

/// Modale partagée indiquant les éléments de vérification manquants.
class UnverifiedProfileSheet extends StatelessWidget {
  const UnverifiedProfileSheet({
    super.key,
    required this.isAssmatSide,
    this.issues,
    this.onCompleteProfile,
  });

  final bool isAssmatSide;
  final List<AssmatVerificationIssue>? issues;
  final VoidCallback? onCompleteProfile;

  List<AssmatVerificationIssue> get _resolved =>
      issues ?? AssmatVerificationIssue.values;

  static String _label(AssmatVerificationIssue issue) => switch (issue) {
        AssmatVerificationIssue.identity => 'Identité vérifiée',
        AssmatVerificationIssue.accreditation => 'Agrément certifié à jour',
        AssmatVerificationIssue.criminalRecord => 'Casier judiciaire fourni',
      };

  static String _hint(AssmatVerificationIssue issue) => switch (issue) {
        AssmatVerificationIssue.identity =>
          "Votre pièce d'identité doit être validée avant de créer un contrat.",
        AssmatVerificationIssue.accreditation =>
          'Votre agrément doit être certifié et à jour.',
        AssmatVerificationIssue.criminalRecord =>
          'Le bulletin n°3 du casier judiciaire doit être fourni.',
      };

  @override
  Widget build(BuildContext context) {
    final title = isAssmatSide
        ? 'Profil à compléter'
        : 'Vérification en cours';
    final message = isAssmatSide
        ? 'Votre profil doit être entièrement vérifié avant de créer un contrat. '
            'Il manque les éléments suivants :'
        : "Cette assistante maternelle n'a pas encore complété la vérification "
            'de son profil. Vous pourrez créer le contrat dès que sa vérification '
            'sera terminée.';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    isAssmatSide
                        ? Icons.verified_user_outlined
                        : Icons.hourglass_top_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._resolved.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _label(issue),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _hint(issue),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isAssmatSide && onCompleteProfile != null
                    ? onCompleteProfile
                    : () => Navigator.of(context).pop(),
                icon: Icon(
                  isAssmatSide && onCompleteProfile != null
                      ? Icons.edit_outlined
                      : Icons.check_rounded,
                  size: 18,
                ),
                label: Text(
                  isAssmatSide && onCompleteProfile != null
                      ? 'Compléter mon profil'
                      : 'Compris',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
