import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/visio_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../messaging/data/messaging_datasource.dart';
import '../../../messaging/providers/messaging_providers.dart';
import '../../../notifications/presentation/providers/notification_triggers.dart';
import '../../../../shared/models/message_model.dart';
import 'engagement_contract_page.dart';

/// Page de chat côté parent — fil de messages avec une assmat donnée.
///
/// Si la conversation n'existe pas encore, elle est créée automatiquement
/// lors du premier envoi (via [MessagingDatasource.getOrCreateConversation]).
class ParentChatPage extends ConsumerStatefulWidget {
  const ParentChatPage({
    super.key,
    required this.assmatUid,
    required this.assmatName,
  });

  final String assmatUid;
  final String assmatName;

  @override
  ConsumerState<ParentChatPage> createState() => _ParentChatPageState();
}

class _ParentChatPageState extends ConsumerState<ParentChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  /// Null tant que la conversation n'est pas encore créée/récupérée.
  String? _convId;

  /// Message d'erreur si la création de conversation échoue.
  String? _initError;



  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _initConversation() async {
    try {
      final currentUser = ref.read(currentUserProvider).valueOrNull;
      if (currentUser == null) return;

      final parentProfile = ref.read(parentProfileProvider).valueOrNull;
      final parentName = parentProfile != null
          ? '${parentProfile.firstName} ${parentProfile.lastName}'.trim()
          : currentUser.displayName ?? 'Parent';

      final datasource = ref.read(messagingDatasourceProvider);
      final result = await datasource.getOrCreateConversation(
        parentUid: currentUser.uid,
        assmatUid: widget.assmatUid,
        parentName: parentName,
        assmatName: widget.assmatName,
      );

      if (!mounted) return;
      setState(() => _convId = result.convId);

      // Marque les messages comme lus à l'ouverture.
      // On enveloppe dans un try-catch pour que l'ouverture de la conversation
      // ne plante pas si l'update échoue (ex: latence, règle Firestore transitoire).
      try {
        await datasource.markAsRead(convId: result.convId, readerIsParent: true);
      } catch (markError) {
        debugPrint('[Chat] markAsRead warning: $markError');
      }
    } catch (e, stack) {
      debugPrint('[Chat] _initConversation error: $e');
      debugPrint('[Chat] Stacktrace: $stack');
      if (!mounted) return;
      setState(() => _initError =
          'Impossible d\'ouvrir la conversation.\nErreur : ${e.toString().split('\n').first}');
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _convId == null) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    _msgCtrl.clear();
    await ref.read(messagingDatasourceProvider).sendMessage(
          convId: _convId!,
          senderUid: currentUser.uid,
          text: text,
          senderIsParent: true,
        );

    // Notification in-app pour l'assmat
    try {
      ref.read(notificationTriggersProvider).onMessageSent(
            recipientUid: widget.assmatUid,
            senderUid: currentUser.uid,
            senderName: currentUser.displayName ?? 'Un parent',
            conversationId: _convId!,
            messageText: text,
          );
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showVisioPicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (!mounted || time == null) return;

    final visioDate = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null || _convId == null) return;

    await ref.read(messagingDatasourceProvider).sendVisioProposal(
          convId: _convId!,
          senderUid: currentUser.uid,
          visioDate: visioDate,
          senderIsParent: true,
        );

    // Notification in-app pour l'assmat
    try {
      ref.read(notificationTriggersProvider).onVisioProposalSent(
            recipientUid: widget.assmatUid,
            senderUid: currentUser.uid,
            senderName: currentUser.displayName ?? 'Un parent',
            conversationId: _convId!,
            visioDate: visioDate,
            visioProposalId: '',
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final myUid = currentUser?.uid ?? '';

    final initials = widget.assmatName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      initials,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.assmatName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _convId != null
                        ? () => _showVisioPicker()
                        : null,
                    icon: const Icon(Icons.videocam_rounded, size: 18),
                    label: Text('Visio',
                        style: AppTextStyles.labelMedium),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Contrat banner ─────────────────────────────────────────────────────
            _ContractBanner(
              currentUserUid: myUid,
              assmatUid: widget.assmatUid,
              assmatName: widget.assmatName,
            ),

            // ── Messages ───────────────────────────────────────────────────────────
            Expanded(
              child: _initError != null
                  ? _ErrorView(
                      message: _initError!,
                      onRetry: () {
                        setState(() => _initError = null);
                        _initConversation();
                      },
                    )
                  : _convId == null
                      ? const Center(child: CircularProgressIndicator())
                  : ref.watch(messagesProvider(_convId!)).when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text(
                            'Erreur de chargement\n$e',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        data: (messages) {
                          final itemCount =
                              messages.length + 1;

                          if (messages.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollCtrl.hasClients) {
                                _scrollCtrl.jumpTo(
                                    _scrollCtrl.position.maxScrollExtent);
                              }
                            });
                          }

                          return ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: itemCount,
                            itemBuilder: (_, i) {
                              if (i == 0) {
                                return Column(
                                  children: [
                                    _UnlockCard(
                                      assmatName: widget.assmatName,
                                    ),
                                    if (messages.isEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(
                                                bottom: AppSpacing.xl),
                                        child: Text(
                                          'Envoyez votre premier message\nà ${widget.assmatName} !',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                  color: AppColors
                                                      .secondaryText),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                );
                              }
                              final msg = messages[i - 1];
                              if (msg.isVisioProposal) {
                                final responses = messages.where(
                                  (m) => m.type == MessageType.visioResponse && m.visioProposalId == msg.id,
                                ).toList();
                                final lastResponse = responses.isNotEmpty ? responses.last : null;
                                 return _VisioCard(
                                   message: msg,
                                   responseStatus: lastResponse?.visioStatus,
                                   reflectionDeadline: lastResponse?.reflectionDeadline,
                                   isMe: msg.senderUid == myUid,
                                   convId: _convId,
                                   parentUid: myUid,
                                   assmatName: widget.assmatName,
                                   assmatUid: widget.assmatUid,
                                 );
                              }
                              if (msg.type == MessageType.visioResponse) {
                                return const SizedBox.shrink();
                              }
                              return _BubbleTile(
                                msg: msg,
                                isMe: msg.senderUid == myUid,
                              );
                            },
                          );
                        },
                      ),
            ),

            // ── Input bar ────────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: AppTextStyles.bodySmall,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Écrire un message',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.hint),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.full),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.full),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadii.full),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bannière affichant le statut du contrat dans le chat.
class _ContractBanner extends StatelessWidget {
  const _ContractBanner({
    required this.currentUserUid,
    required this.assmatUid,
    required this.assmatName,
  });

  final String currentUserUid;
  final String assmatUid;
  final String assmatName;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contracts')
          .where('parentUid', isEqualTo: currentUserUid)
          .where('assmatUid', isEqualTo: assmatUid)
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        final d = snap.data!.docs.first.data() as Map<String, dynamic>;
        final status = d['status'] as String? ?? '';
        if (status == 'active' || status.isEmpty) {
          return const SizedBox.shrink();
        }

        final (label, color, action) = switch (status) {
          'draft' => ('Brouillon de contrat', AppColors.secondary, 'Reprendre'),
          'pendingAssmat' => ('En attente de signature assmat', AppColors.accent, 'Voir'),
          'pendingParent' => ('Contrat à signer', AppColors.primary, 'Signer'),
          _ => ('', Colors.transparent, ''),
        };
        if (label.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              SizedBox(
                height: 26,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EngagementContractPage(
                        assmatUid: assmatUid,
                        assmatName: assmatName,
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: const TextStyle(fontSize: 11),
                    visualDensity: VisualDensity.compact,
                    foregroundColor: color,
                  ),
                  child: Text(action),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Bubble ───────────────────────────────────────────────────────────────────

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({required this.msg, required this.isMe});
  final MessageModel msg;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(msg.sentAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : const Color(0xFFF0F0EE),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isMe ? Colors.white : AppColors.primaryText,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.hint, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      return '$h:$m';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Hier $h:$m';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} $h:$m';
  }
}

/// Carte système affichée en haut d'une nouvelle conversation pour indiquer
/// que le profil de l'assmat est débloqué.
class _UnlockCard extends StatelessWidget {
  const _UnlockCard({required this.assmatName});

  final String assmatName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🔓', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil de $assmatName débloqué !',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Vous pouvez maintenant discuter et organiser une visio',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte affichant une proposition de visio avec son cycle de vie :
/// attente → acceptée (+ rejoindre/terminée) → terminée (+ suivi décision) → décision prise.
class _VisioCard extends ConsumerWidget {
  const _VisioCard({
    required this.message,
    required this.isMe,
    this.responseStatus,
    this.reflectionDeadline,
    this.convId,
    this.parentUid,
    this.assmatName,
    this.assmatUid,
  });
  final MessageModel message;
  final bool isMe;
  final VisioStatus? responseStatus;
  final DateTime? reflectionDeadline;
  final String? convId;
  final String? parentUid;
  final String? assmatName;
  final String? assmatUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveStatus = responseStatus ?? message.visioStatus;
    final bool isAccepted = effectiveStatus == VisioStatus.accepted;
    final bool isCompleted = effectiveStatus == VisioStatus.completed;

    final (Color bgColor, Color borderColor, String statusText) =
        switch (effectiveStatus) {
      VisioStatus.accepted => (
          AppColors.secondary,
          AppColors.primary,
          'Accepté par l\'assistante maternelle',
        ),
      VisioStatus.completed => (
          AppColors.primary.withValues(alpha: 0.08),
          AppColors.primary,
          'Visio terminée',
        ),
      VisioStatus.match => (
          AppColors.success.withValues(alpha: 0.08),
          AppColors.success,
          'Match validé',
        ),
      VisioStatus.reflection => (
          AppColors.accent.withValues(alpha: 0.08),
          AppColors.accent,
          'En réflexion',
        ),
      VisioStatus.rejected => (
          AppColors.error.withValues(alpha: 0.08),
          AppColors.error,
          'Match refusé',
        ),
      VisioStatus.refused => (
          AppColors.error.withValues(alpha: 0.08),
          AppColors.error,
          'Refusé par l\'assistante maternelle',
        ),
      _ => (
          AppColors.secondary,
          AppColors.primary.withValues(alpha: 0.3),
          'En attente d\'acceptation',
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('📹', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMe
                        ? 'Vous avez proposé une visio'
                        : 'Proposition de visio',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: borderColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: Text(
                      statusText,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: borderColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // ── Visio acceptée : rejoindre / terminer ──────────────
                  if (isAccepted) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: convId != null
                                ? () => _joinVisio(context)
                                : null,
                            icon: const Icon(Icons.videocam_rounded, size: 16),
                            label: const Text('Rejoindre la visio'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadii.sm),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: convId != null
                                ? () => _markCompleted(context, ref)
                                : null,
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: const Text('Visio terminée'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              side: BorderSide.none,
                              backgroundColor: AppColors.success.withValues(alpha: 0.08),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadii.sm),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // ── Visio terminée : suivi décision ────────────────────
                  if (isCompleted) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'La visio est terminée — quelle suite donner ?',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choisissez une option pour continuer le parcours',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: _DecisionBtn(
                                  icon: Icons.favorite,
                                  label: 'Match validé',
                                  color: AppColors.success,
                                  enabled: convId != null,
                                  onTap: () => _makeDecision(context, ref, VisioStatus.match),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _DecisionBtn(
                                  icon: Icons.schedule,
                                  label: 'Réflexion',
                                  color: AppColors.accent,
                                  enabled: convId != null,
                                  onTap: () => _makeDecision(context, ref, VisioStatus.reflection),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _DecisionBtn(
                                  icon: Icons.close,
                                  label: 'Refuser',
                                  color: AppColors.error,
                                  enabled: convId != null,
                                  onTap: () => _makeDecision(context, ref, VisioStatus.rejected),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  // ── Match validé : engagement réciproque ──────────────
                  if (effectiveStatus == VisioStatus.match) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎉 Match validé !',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Vous pouvez maintenant passer à l\'étape suivante : la signature de l\'engagement réciproque',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EngagementContractPage(
                                        assmatUid: assmatUid ?? '',
                                        assmatName: assmatName ?? 'l\'assistante maternelle',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.description_outlined, size: 18),
                                label: const Text('Créer l\'engagement réciproque'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadii.sm),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // ── Réflexion : compte à rebours ──────────────────────
                  if (effectiveStatus == VisioStatus.reflection) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ReflectionCard(
                      deadline: reflectionDeadline,
                      onValidateMatch: () => _makeDecision(context, ref, VisioStatus.match),
                      onReject: () => _makeDecision(context, ref, VisioStatus.rejected),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinVisio(BuildContext context) async {
    if (convId == null) return;
    try {
      await VisioService.joinVisio(
        conversationId: convId!,
        userName: parentUid ?? 'Parent',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de lancer la visio : $e')),
        );
      }
    }
  }

  Future<void> _markCompleted(BuildContext context, WidgetRef ref) async {
    final datasource = ref.read(messagingDatasourceProvider);
    try {
      await datasource.respondToVisio(
        convId: convId!,
        msgId: message.id,
        status: VisioStatus.completed,
        responderIsParent: true,
        responderUid: parentUid!,
      );

      // Notification in-app pour l'assmat
      try {
        final assmatUid = convId!.split('_').last;
        ref.read(notificationTriggersProvider).onVisioResponse(
              recipientUid: assmatUid,
              senderUid: parentUid!,
              senderName: 'Le parent',
              conversationId: convId!,
              status: VisioStatus.completed,
            );
      } catch (_) {}
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  Future<void> _makeDecision(
      BuildContext context, WidgetRef ref, VisioStatus status) async {
    final datasource = ref.read(messagingDatasourceProvider);
    try {
      await datasource.respondToVisio(
        convId: convId!,
        msgId: message.id,
        status: status,
        responderIsParent: true,
        responderUid: parentUid!,
      );

      // Notification in-app pour l'assmat
      try {
        final assmatUid = convId!.split('_').last;
        ref.read(notificationTriggersProvider).onVisioResponse(
              recipientUid: assmatUid,
              senderUid: parentUid!,
              senderName: 'Le parent',
              conversationId: convId!,
              status: status,
            );
      } catch (_) {}
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }
}

/// Suivi des rappels déjà affichés dans la session en cours.
final Set<String> _shownReflectionReminders = {};

/// Carte de réflexion avec compte à rebours sur 10 jours et rappels.
class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({
    this.deadline,
    required this.onValidateMatch,
    required this.onReject,
  });

  final DateTime? deadline;
  final VoidCallback onValidateMatch;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remaining = deadline != null
        ? deadline!.difference(now)
        : const Duration(days: 10);
    final daysLeft = remaining.inDays;
    final isExpired = daysLeft < 0;

    final String countdownText;
    if (deadline == null) {
      countdownText = 'J-10';
    } else if (isExpired) {
      countdownText = 'Délai expiré';
    } else if (daysLeft == 0) {
      countdownText = 'Dernier jour';
    } else {
      countdownText = 'J-$daysLeft';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏳ En attente de réflexion',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vous avez 10 jours pour prendre votre décision',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: isExpired
                    ? AppColors.error
                    : daysLeft <= 2
                        ? AppColors.error
                        : AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                countdownText,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isExpired
                      ? AppColors.error
                      : daysLeft <= 2
                          ? AppColors.error
                          : AppColors.accent,
                ),
              ),
            ],
          ),
          // ── Rappels in-app ──────────────────────────────────────
          if (deadline != null && !isExpired) ...[
            if (daysLeft <= 5 && daysLeft > 2 && _shownReflectionReminders.add('${deadline!.millisecondsSinceEpoch}_5'))
              const _ReminderBanner(
                icon: Icons.info_outline,
                text: '⏰ J-5 : Pensez à prendre votre décision !',
                color: AppColors.primary,
              ),
            if (daysLeft <= 2 && daysLeft > 1 && _shownReflectionReminders.add('${deadline!.millisecondsSinceEpoch}_2'))
              const _ReminderBanner(
                icon: Icons.warning_amber_rounded,
                text: '⚠️ J-2 : Il ne vous reste plus que 2 jours !',
                color: AppColors.accent,
              ),
            if (daysLeft <= 1 && _shownReflectionReminders.add('${deadline!.millisecondsSinceEpoch}_1'))
              const _ReminderBanner(
                icon: Icons.error_outline,
                text: '🚨 J-1 : Dernier jour pour prendre votre décision !',
                color: AppColors.error,
              ),
          ],
          if (isExpired)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Le délai de réflexion est expiré',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isExpired ? null : onValidateMatch,
                  icon: const Icon(Icons.favorite, size: 16),
                  label: const Text('Valider le match'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: BorderSide(
                      color: isExpired
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.success,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isExpired ? null : onReject,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Refuser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: isExpired
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.error,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
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

/// Bannière de rappel colorée.
class _ReminderBanner extends StatelessWidget {
  const _ReminderBanner({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Petit bouton carré pour les décisions post-visio.
class _DecisionBtn extends StatelessWidget {
  const _DecisionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Réessayer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

