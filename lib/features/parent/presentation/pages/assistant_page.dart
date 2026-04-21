import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Origine d'un message dans la conversation.
enum _Sender { bot, user }

/// Message affiché dans la conversation avec l'assistant.
class _Message {
  const _Message({required this.sender, required this.content});
  final _Sender sender;
  final Widget content;
}

/// Page "Assistant AMiLY" — chatbot d'aide administrative.
///
/// Layout :
///   - Header : back + avatar bot + titre/sous-titre
///   - Zone messages scrollable (bot à gauche, user à droite)
///   - Quick replies (5 suggestions tap-to-send)
///   - Input bar : champ + bouton envoi circulaire
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _quickReplies = [
    'Comprendre ma fiche de paie',
    'Remplir Pajemploi',
    'Gérer les congés',
    'Contrat assistante maternelle',
    'Poser une question',
  ];

  late final List<_Message> _messages = [
    const _Message(sender: _Sender.bot, content: _WelcomeContent()),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(_Message(
        sender: _Sender.user,
        content: Text(trimmed, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimary)),
      ));
      // Réponse bot stub.
      _messages.add(
        _Message(
          sender: _Sender.bot,
          content: Text(
            'Je traite votre demande : « $trimmed ». Cette fonctionnalité arrivera bientôt.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    });
    _controller.clear();

    // Scroll en bas après ajout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _AssistantHeader(),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _messages.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, i) => _MessageBubble(message: _messages[i]),
              ),
            ),
            _QuickReplies(
              replies: _quickReplies,
              onTap: _send,
            ),
            _InputBar(
              controller: _controller,
              onSend: () => _send(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header : back + avatar bot + titre.
class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 24,
              color: AppColors.primaryText,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Retour',
          ),
          const _BotAvatar(size: 40),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Assistant AMiLY',
                  style: AppTextStyles.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Aide administrative',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar circulaire de l'assistant (fond secondary + icône bot primary).
class _BotAvatar extends StatelessWidget {
  const _BotAvatar({this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.smart_toy_rounded,
        color: AppColors.primary,
        size: size * 0.55,
      ),
    );
  }
}

/// Bulle de message : bot à gauche (gris), user à droite (vert).
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    final isBot = message.sender == _Sender.bot;

    final bubble = Flexible(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isBot
              ? AppColors.divider.withValues(alpha: 0.3)
              : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadii.md),
            topRight: const Radius.circular(AppRadii.md),
            bottomLeft:
                Radius.circular(isBot ? AppRadii.sm : AppRadii.md),
            bottomRight:
                Radius.circular(isBot ? AppRadii.md : AppRadii.sm),
          ),
        ),
        child: DefaultTextStyle(
          style: AppTextStyles.bodyMedium.copyWith(
            color: isBot ? AppColors.primaryText : AppColors.onPrimary,
            height: 1.4,
          ),
          child: message.content,
        ),
      ),
    );

    return Row(
      mainAxisAlignment:
          isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: isBot
          ? [
              const _BotAvatar(),
              const SizedBox(width: AppSpacing.sm),
              bubble,
            ]
          : [bubble],
    );
  }
}

/// Message de bienvenue initial du bot (texte riche + liste).
class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Bonjour 👋'),
        const SizedBox(height: AppSpacing.sm),
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryText,
              height: 1.4,
            ),
            children: const [
              TextSpan(text: 'Je suis l\''),
              TextSpan(
                text: 'Assistant AMiLY',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text('Je peux vous aider à :'),
        const SizedBox(height: AppSpacing.xs),
        const Text('📄  Comprendre votre fiche de paie'),
        const Text('💻  Remplir Pajemploi'),
        const Text('📄  Gérer votre contrat'),
        const Text('❓  Répondre à vos questions administratives'),
        const SizedBox(height: AppSpacing.sm),
        const Text('Que souhaitez-vous faire ?'),
      ],
    );
  }
}

/// Barre de suggestions "quick replies" — tap pour envoyer directement.
class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.replies, required this.onTap});
  final List<String> replies;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final r in replies) _QuickReplyChip(label: r, onTap: onTap),
        ],
      ),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  const _QuickReplyChip({required this.label, required this.onTap});
  final String label;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(label),
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}

/// Input bar du chat : TextField + bouton envoi circulaire primary.
class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Posez votre question…',
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onSend,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.send_rounded,
                  color: AppColors.onPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
