import 'package:amily/shared/utils/chat_time_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 9, 5);
  final yesterday = DateTime(now.year, now.month, now.day - 1, 18, 30);
  final old = DateTime(now.year, now.month, now.day - 40, 7, 0);
  String two(int v) => v.toString().padLeft(2, '0');

  group('conversationTimeLabel', () {
    test('null → vide', () => expect(conversationTimeLabel(null), ''));
    test('aujourd\'hui → HH:mm',
        () => expect(conversationTimeLabel(today), '09:05'));
    test('hier → Hier', () => expect(conversationTimeLabel(yesterday), 'Hier'));
    test('ancien → dd/MM', () {
      expect(conversationTimeLabel(old), '${two(old.day)}/${two(old.month)}');
    });
  });

  group('chatMessageTimeLabel', () {
    test('aujourd\'hui', () => expect(chatMessageTimeLabel(today), '09:05'));
    test('hier', () => expect(chatMessageTimeLabel(yesterday), 'Hier 18:30'));
    test('ancien', () {
      expect(
        chatMessageTimeLabel(old),
        '${two(old.day)}/${two(old.month)} 07:00',
      );
    });
  });
}
