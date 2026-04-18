enum MessageType {
  text('TextChat'),
  image('ImageChat'),
  voice('VoiceChat');

  final String apiValue;

  const MessageType(this.apiValue);
  static MessageType fromString(String value) {
    final normalized = value.toLowerCase();
    for (final type in MessageType.values) {
      if (type.apiValue.toLowerCase() == normalized) {
        return type;
      }
    }
    return MessageType.text; // default
  }

  static MessageType detectFromContent(String content) {
    if (content.startsWith('[IMAGE]') || content.startsWith('data:image')) {
      return MessageType.image;
    }
    if (content.startsWith('[VOICE]') || content.startsWith('data:audio')) {
      return MessageType.voice;
    }
    return MessageType.text;
  }
}
