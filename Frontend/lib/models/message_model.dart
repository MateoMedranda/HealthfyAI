class Message {
  final String type;
  final String content;
  final String? imageUrl;

  Message({required this.type, required this.content, this.imageUrl});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      type: json['type'].toString(),
      content: json['content']?.toString() ?? '',
<<<<<<< HEAD
      imageUrl: json['image_url']?.toString(),
=======
      imageUrl: json['imageUrl']?.toString(),
>>>>>>> 8a1a672d013e2c73e2e70d45cb17573ece4b8a23
    );
  }

  factory Message.fromBotResponse(Map<String, dynamic> json) {
    return Message(type: 'ai', content: json['content']?.toString() ?? '');
  }
}
