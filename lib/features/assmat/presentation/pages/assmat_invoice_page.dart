import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/data/models/assmat_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../payments/data/models/invoice_model.dart';
import '../../../payments/data/repositories/invoice_repository.dart';
import '../../../payments/presentation/providers/invoice_providers.dart';
import 'assmat_home_page.dart';

class AssMatInvoicePage extends ConsumerWidget {
  const AssMatInvoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assmatAsync = ref.watch(assmatProfileProvider);
    final invoicesAsync = ref.watch(invoicesByAssmatProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AssMatDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.child_care_rounded,
                  size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text('AMiLY',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: assmatAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (assmat) => _Body(assmat: assmat, invoicesAsync: invoicesAsync),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewInvoiceSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle facture'),
      ),
    );
  }

  void _showNewInvoiceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NewInvoiceSheet(),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.assmat,
    required this.invoicesAsync,
  });

  final AssmatProfileModel? assmat;
  final AsyncValue<List<InvoiceModel>> invoicesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStripeConnected = assmat?.stripeConnected ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Facturation & Documents',
            style: AppTextStyles.titleLarge
                .copyWith(fontWeight: FontWeight.w700, fontSize: 26),
          ),
          const SizedBox(height: 4),
          Text(
            'Gérez vos factures et connectez Stripe pour recevoir les paiements',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isStripeConnected) _StripeOnboardingBanner(),
          if (isStripeConnected)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Compte Stripe connecté',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          _StatsSection(assmat: assmat!),
          const SizedBox(height: AppSpacing.md),
          _InvoiceList(invoicesAsync: invoicesAsync),
        ],
      ),
    );
  }
}

class _StripeOnboardingBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: AppColors.primary, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connectez votre compte bancaire',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Pour recevoir les paiements par carte, '
                  'connectez votre compte Stripe.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          TextButton(
            onPressed: () => _connectStripe(context, ref),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: const Text('Connecter'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectStripe(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    try {
      final repo = ref.read(invoiceRepositoryProvider);
      final url = await repo.getOnboardingLink(user.uid);
      if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}

class _StatsSection extends ConsumerWidget {
  const _StatsSection({required this.assmat});

  final AssmatProfileModel assmat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenue =
        ref.watch(monthlyRevenueProvider);
    final count =
        ref.watch(monthlyInvoiceCountProvider);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.euro_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.secondary,
            value: '${revenue.toStringAsFixed(0)} €',
            label: 'Revenus du mois',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_outlined,
            iconColor: AppColors.statBlueColor,
            iconBg: AppColors.statBlueBg,
            value: '$count',
            label: 'Factures ce mois',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({required this.invoicesAsync});

  final AsyncValue<List<InvoiceModel>> invoicesAsync;

  @override
  Widget build(BuildContext context) {
    return invoicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (invoices) {
        if (invoices.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    size: 64, color: AppColors.secondaryText),
                const SizedBox(height: AppSpacing.md),
                Text('Aucune facture',
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Créez votre première facture avec le bouton +',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _InvoiceTile(invoice: invoices[i]),
        );
      },
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.status == InvoiceStatus.paid;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPaid
                  ? AppColors.secondary
                  : AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 24,
              color: isPaid ? AppColors.primary : AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.familyName,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(invoice.childName,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${invoice.totalAmount.toStringAsFixed(2)} €',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  invoice.status.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isPaid ? AppColors.primary : AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewInvoiceSheet extends ConsumerStatefulWidget {
  const _NewInvoiceSheet();

  @override
  ConsumerState<_NewInvoiceSheet> createState() => _NewInvoiceSheetState();
}

class _NewInvoiceSheetState extends ConsumerState<_NewInvoiceSheet> {
  final _familleCtrl = TextEditingController();
  final _enfantCtrl = TextEditingController();
  final _heuresCtrl = TextEditingController();
  final _tauxHoraireCtrl = TextEditingController();
  final _repasCtrl = TextEditingController();
  final _tauxRepasCtrl = TextEditingController();
  final _heuresComplCtrl = TextEditingController();
  final _entretienCtrl = TextEditingController();
  int? _mois;
  bool _loading = false;

  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  void dispose() {
    _familleCtrl.dispose();
    _enfantCtrl.dispose();
    _heuresCtrl.dispose();
    _tauxHoraireCtrl.dispose();
    _repasCtrl.dispose();
    _tauxRepasCtrl.dispose();
    _heuresComplCtrl.dispose();
    _entretienCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    if (_familleCtrl.text.isEmpty ||
        _enfantCtrl.text.isEmpty ||
        _mois == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final assmatProfile = ref.read(assmatProfileProvider).valueOrNull;
      await ref.read(invoiceRepositoryProvider).createInvoice(
            assmatUid: user.uid,
            parentUid: '',
            assmatName: assmatProfile?.firstName ?? user.displayName ?? '',
            familyName: _familleCtrl.text.trim(),
            childName: _enfantCtrl.text.trim(),
            month: _mois!,
            year: DateTime.now().year,
            hours: double.tryParse(_heuresCtrl.text) ?? 0,
            hourlyRate: double.tryParse(_tauxHoraireCtrl.text) ?? 0,
            meals: int.tryParse(_repasCtrl.text) ?? 0,
            mealRate: double.tryParse(_tauxRepasCtrl.text) ?? 0,
            overtimeHours: double.tryParse(_heuresComplCtrl.text) ?? 0,
            maintenanceAllowance: double.tryParse(_entretienCtrl.text) ?? 0,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: Form(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HandleBar(),
              const SizedBox(height: AppSpacing.md),
              Text('Nouvelle facture',
                  style: AppTextStyles.titleLarge
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _familleCtrl,
                decoration: const InputDecoration(labelText: 'Nom de la famille *'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _enfantCtrl,
                decoration: const InputDecoration(labelText: "Prénom de l'enfant *"),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int>(
                value: _mois,
                decoration: const InputDecoration(labelText: 'Mois *'),
                items: List.generate(12, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_months[i]),
                )),
                onChanged: (v) => setState(() => _mois = v),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _heuresCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Heures d'accueil"),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _tauxHoraireCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Taux horaire (€)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _repasCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Repas'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _tauxRepasCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prix repas (€)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _heuresComplCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Heures complémentaires'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _entretienCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Frais d'entretien (€)"),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Créer la facture'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class HandleBar extends StatelessWidget {
  const HandleBar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
