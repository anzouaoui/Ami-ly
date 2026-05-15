import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../messaging/data/messaging_datasource.dart';
import '../../../messaging/providers/messaging_providers.dart';
import '../../../../shared/models/message_model.dart';

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
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final parentProfile = ref.read(parentProfileProvider).valueOrNull;
    final parentName = parentProfile != null
        ? '${parentProfile.firstName} ${parentProfile.lastName}'.trim()
        : currentUser.displayName ?? 'Parent';

    final datasource = ref.read(messagingDatasourceProvider);
    final convId = await datasource.getOrCreateConversation(
      parentUid: currentUser.uid,
      assmatUid: widget.assmatUid,
      parentName: parentName,
      assmatName: widget.assmatName,
    );

    if (!mounted) return;
    setState(() => _convId = convId);

    // Marque les messages comme lus à l'ouverture
    await datasource.markAsRead(convId: convId, readerIsParent: true);
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
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Messages ─────────────────────────────────────────────────
            Expanded(
              child: _convId == null
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
                          if (messages.isEmpty) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(AppSpacing.xl),
                                child: Text(
                                  'Envoyez votre premier message\nà ${widget.assmatName} !',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.secondaryText),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollCtrl.hasClients) {
                              _scrollCtrl.jumpTo(
                                  _scrollCtrl.position.maxScrollExtent);
                            }
                          });
                          return ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: messages.length,
                            itemBuilder: (_, i) => _BubbleTile(
                              msg: messages[i],
                              isMe: messages[i].senderUid == myUid,
                            ),
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
