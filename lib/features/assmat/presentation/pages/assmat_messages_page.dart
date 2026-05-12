import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'assmat_chat_page.dart';
import 'assmat_home_page.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _Conversation {
  const _Conversation({
    required this.parentName,
    required this.initials,
    required this.childName,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
  });
  final String parentName;
  final String initials;
  final String childName;
  final String lastMessage;
  final String time;
  final int unread;
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kConversations = [
  _Conversation(
    parentName: 'Marie Dupont',
    initials: 'MD',
    childName: 'Lucas Dupont',
    lastMessage: 'Bonjour, à quelle heure...',
    time: '09:30',
    unread: 2,
  ),
  _Conversation(
    parentName: 'Julie Leroy',
    initials: 'JL',
    childName: 'Emma Leroy',
    lastMessage: 'Merci beaucoup !',
    time: 'Hier',
    unread: 0,
  ),
  _Conversation(
    parentName: 'Thomas Bernard',
    initials: 'TB',
    childName: 'Léa Bernard',
    lastMessage: 'Elle a bien mangé aujourd\'hui.',
    time: 'Lun',
    unread: 0,
  ),
  _Conversation(
    parentName: 'Sophie Martin',
    initials: 'SM',
    childName: 'Hugo Martin',
    lastMessage: 'D\'accord, on sera là à 17h.',
    time: 'Ven',
    unread: 0,
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssMatMessagesPage extends StatefulWidget {
  const AssMatMessagesPage({super.key});

  @override
  State<AssMatMessagesPage> createState() => _AssMatMessagesPageState();
}

class _AssMatMessagesPageState extends State<AssMatMessagesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Conversation> get _filtered => _kConversations
      .where((c) =>
          _query.isEmpty ||
          c.parentName.toLowerCase().contains(_query.toLowerCase()) ||
          c.childName.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AssMatDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 24),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Messages',
                    style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800, fontSize: 28)),
                const SizedBox(height: 4),
                Text('Communication sécurisée avec les parents',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),

          // ── Conversation list card ─────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.hint),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 18, color: AppColors.secondaryText),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (_, i) =>
                          _ConversationTile(conv: _filtered[i]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nouveau message — à venir'),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conv});
  final _Conversation conv;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openThread(context, conv),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    conv.initials,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                if (conv.unread > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE07830),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${conv.unread}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.parentName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: conv.unread > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conv.time,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: conv.unread > 0
                              ? const Color(0xFFE07830)
                              : AppColors.secondaryText,
                          fontWeight: conv.unread > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${conv.childName} · ${conv.lastMessage}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: conv.unread > 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openThread(BuildContext context, _Conversation conv) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssMatChatPage(
          contact: ChatContact(
            name: conv.parentName,
            initials: conv.initials,
            childName: conv.childName,
          ),
        ),
      ),
    );
  }
}

// ─── Chat thread page ─────────────────────────────────────────────────────────

class _ChatMessage {
  const _ChatMessage(
      {required this.text, required this.isMe, required this.time});
  final String text;
  final bool isMe;
  final String time;
}

final _kThreads = <String, List<_ChatMessage>>{
  'Marie Dupont': [
    const _ChatMessage(
        text: 'Bonjour ! Tout se passe bien avec Lucas ?',
        isMe: false,
        time: '09:20'),
    const _ChatMessage(
        text: 'Oui, il est en pleine forme ! Il a très bien mangé ce midi.',
        isMe: true,
        time: '09:25'),
    const _ChatMessage(
        text: 'Bonjour, à quelle heure puis-je venir le récupérer ?',
        isMe: false,
        time: '09:30'),
  ],
  'Julie Leroy': [
    const _ChatMessage(
        text: 'Emma a fait une belle sieste aujourd\'hui, 2h sans se réveiller.',
        isMe: true,
        time: 'Hier 14:10'),
    const _ChatMessage(text: 'Merci beaucoup !', isMe: false, time: 'Hier 17:45'),
  ],
};

class _ChatThreadPage extends StatefulWidget {
  const _ChatThreadPage({required this.conv});
  final _Conversation conv;

  @override
  State<_ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<_ChatThreadPage> {
  final _msgCtrl = TextEditingController();
  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.of(
        _kThreads[widget.conv.parentName] ?? []);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true, time: 'maintenant'));
      _msgCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                widget.conv.initials,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.conv.parentName,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                Text(widget.conv.childName,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.secondaryText, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _Bubble(msg: _messages[i]),
            ),
          ),

          // Input bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: AppTextStyles.bodySmall,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      hintStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.hint),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.full),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.full),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.full),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _send,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        size: 18, color: Colors.white),
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

// ─── Chat bubble ─────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE0E8E4),
              child: Icon(Icons.person_rounded,
                  size: 16, color: AppColors.secondaryText),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isMe
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                      bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                    ),
                    border: msg.isMe
                        ? null
                        : Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: msg.isMe ? Colors.white : AppColors.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  msg.time,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.hint, fontSize: 10),
                ),
              ],
            ),
          ),
          if (msg.isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
