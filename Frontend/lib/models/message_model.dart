class Message {
  final String type;
  final String content;

  Message({required this.type, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      type: json['type'].toString(),
      content: json['content']?.toString() ?? '',
    );
  }

  factory Message.fromBotResponse(Map<String, dynamic> json) {
    return Message(
      type: 'ai',
      content: json['content']?.toString() ?? '',
    );
  }
}