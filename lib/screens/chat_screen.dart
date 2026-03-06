import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../state/app_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = ChatService(FirebaseFirestore.instance);
  String? _chatId;
  bool _loading = false;
  bool _bootstrappingHistory = true;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLatestChat());
  }

  Future<void> _loadLatestChat() async {
    final uid = context.read<AppState>().user?.uid;
    if (uid == null) return;
    final latest = await _chatService.getLatestChatId(uid);
    if (!mounted) return;
    setState(() {
      _chatId = latest;
      _bootstrappingHistory = false;
      _lastMessageCount = 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      return;
    }
    _scrollController.jumpTo(target);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final appState = context.read<AppState>();
    setState(() => _loading = true);

    try {
      final currentChatId = await _chatService.ensureChat(
        appState.user!.uid,
        chatId: _chatId,
      );
      final result = await appState.submitDream(
        text: text,
        source: 'text',
        chatId: currentChatId,
      );
      final newChatId = result['chatId'] as String? ?? currentChatId;
      if (_chatId != newChatId) {
        _lastMessageCount = 0;
      }
      _chatId = newChatId;
      _controller.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rüya yorumu kaydedildi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderim hatası: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _transcribe() async {
    final appState = context.read<AppState>();
    if (!appState.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesli anlatım premium özelliktir.')),
      );
      return;
    }

    final storagePathController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Path ile çözümle'),
        content: TextField(
          controller: storagePathController,
          decoration: const InputDecoration(
            hintText: 'dream-audio/uid/file.m4a',
            labelText: 'Storage path',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çözümle'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    try {
      final text = await appState.transcribeFromStoragePath(
        storagePathController.text.trim(),
      );
      _controller.text = text;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çözümleme hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final uid = appState.user!.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('h:mm a');
    final userBubble =
        isDark ? const Color(0xFF2E5662) : const Color(0xFFCFE0E6);
    final assistantBubble =
        isDark ? const Color(0xFF1C2E36) : const Color(0xFFEAF1F4);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? AppPalette.color800 : AppPalette.color100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.nights_stay_rounded,
                size: 18,
                color: isDark ? AppPalette.color100 : AppPalette.color700,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Somniary'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppPalette.color700.withValues(alpha: 0.55)
                      : AppPalette.color300.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: isDark ? AppPalette.color200 : AppPalette.color700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appState.isPremium
                          ? 'Sınırsız yorum hakkın aktif.'
                          : (appState.canUseFreeToday
                              ? 'Bugün 1 ücretsiz yorum hakkın var.'
                              : 'Bugünkü ücretsiz yorum hakkın bitti.'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppPalette.color200 : AppPalette.color700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _bootstrappingHistory
                ? const Center(child: CircularProgressIndicator())
                : _chatId == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Rüyanı yaz, sohbet burada başlayacak.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? AppPalette.darkTextSecondary
                                  : AppPalette.lightTextSecondary,
                            ),
                          ),
                        ),
                      )
                    : StreamBuilder<List<ChatMessage>>(
                        stream: _chatService.watchMessages(uid, _chatId!),
                        builder: (context, snapshot) {
                          final messages = snapshot.data ?? [];
                          if (messages.length != _lastMessageCount) {
                            _lastMessageCount = messages.length;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) _scrollToBottom();
                            });
                          }
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final item = messages[index];
                              final isUser = item.role == 'user';
                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 520),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: isUser
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        if (!isUser)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 4,
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? AppPalette.color800
                                                        : AppPalette.color100,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.nights_stay_rounded,
                                                    size: 15,
                                                    color: isDark
                                                        ? AppPalette.color100
                                                        : AppPalette.color700,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Somnia',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? AppPalette
                                                            .darkTextSecondary
                                                        : AppPalette
                                                            .lightTextSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: isUser
                                                ? userBubble
                                                : assistantBubble,
                                            borderRadius:
                                                BorderRadius.circular(26),
                                            border: Border.all(
                                              color: isDark
                                                  ? AppPalette.color700
                                                      .withValues(alpha: 0.35)
                                                  : AppPalette.color200
                                                      .withValues(alpha: 0.9),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              20,
                                              18,
                                              20,
                                              18,
                                            ),
                                            child: Text(
                                              item.text,
                                              style: TextStyle(
                                                fontSize: 17,
                                                height: 1.6,
                                                color: isUser
                                                    ? (isDark
                                                        ? AppPalette.color50
                                                        : AppPalette.color900)
                                                    : (isDark
                                                        ? AppPalette.color100
                                                        : AppPalette.color900),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          timeFormat.format(item.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppPalette.darkTextSecondary
                                                : AppPalette.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF19303A)
                    : AppPalette.lightSurface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppPalette.color700.withValues(alpha: 0.4)
                      : AppPalette.color200,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Describe your dream...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppPalette.darkTextSecondary
                              : AppPalette.lightTextSecondary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _transcribe,
                    icon: Icon(
                      Icons.mic_none_rounded,
                      color: isDark
                          ? AppPalette.darkTextSecondary
                          : AppPalette.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppPalette.color700.withValues(alpha: 0.85)
                          : AppPalette.color500.withValues(alpha: 0.78),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: IconButton(
                        onPressed: _loading ? null : _send,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
