import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ChatContact {
  const ChatContact({
    required this.name,
    required this.initials,
    required this.childName,
  });
  final String name;
  final String initials;
  final String childName;
}

class _Msg {
  _Msg({required this.text, required this.isMe, required this.time, this.read = false});
  final String text;
  final bool isMe;
  final String time;
  final bool read;
}

// ─── Mock threads ─────────────────────────────────────────────────────────────

final _kDefaultThread = [
  _Msg(text: 'Bonjour Sophie, comment va Lucas aujourd\'hui ?', isMe: false, time: '08:30'),
  _Msg(text: 'Bonjour ! Lucas va très bien, il a bien mangé ce matin 😊', isMe: true, time: '08:45', read: true),
  _Msg(text: 'Super ! À quelle heure je peux passer le chercher ?', isMe: false, time: '09:15'),
  _Msg(text: 'Comme d\'habitude, à partir de 17h c\'est parfait !', isMe: true, time: '09:20', read: false),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatChatPage extends StatefulWidget {
  const AssMatChatPage({super.key, required this.contact, this.initialMessages});
  final ChatContact contact;
  final List<_Msg>? initialMessages;

  @override
  State<AssMatChatPage> createState() => _AssMatChatPageState();
}

class _AssMatChatPageState extends State<AssMatChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final List<_Msg> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.initialMessages ?? _kDefaultThread);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, isMe: true, time: _nowTime(), read: false));
      _msgCtrl.clear();
    });
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

  String _nowTime() {
    final now = TimeOfDay.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Inline header ──────────────────────────
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
                      widget.contact.initials,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.contact.name,
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700)),
                        Text('Parent de ${widget.contact.childName}',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryText,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: AppColors.secondaryText),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Page title row ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Messages',
                        style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w800, fontSize: 26)),
                    Text('Communication sécurisée avec les parents',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Bubble list ────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadii.md),
                    topRight: Radius.circular(AppRadii.md),
                  ),
                  border: Border.all(color: AppColors.divider),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadii.md),
                    topRight: Radius.circular(AppRadii.md),
                  ),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _BubbleTile(msg: _messages[i]),
                  ),
                ),
              ),
            ),

            // ── Input bar ─────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded,
                        color: AppColors.secondaryText, size: 22),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
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
                  IconButton(
                    icon: const Icon(Icons.graphic_eq_rounded,
                        color: AppColors.secondaryText, size: 22),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded,
                        color: AppColors.secondaryText, size: 22),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
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

// ─── Bubble tile ──────────────────────────────────────────────────────────────

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isMe
                        ? AppColors.primary
                        : const Color(0xFFF0F0EE),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                      bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          msg.isMe ? Colors.white : AppColors.primaryText,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.time,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.hint, fontSize: 10),
                    ),
                    if (msg.isMe) ...[
                      const SizedBox(width: 3),
                      Icon(
                        msg.read
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 13,
                        color: msg.read
                            ? AppColors.primary
                            : AppColors.secondaryText,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
