enum BallState {
  idle,
  listening,
  thinking,
  speaking,
}

class ConversationMessage {
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime timestamp;

  ConversationMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
      };
}
