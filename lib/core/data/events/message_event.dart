// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/data/events/message_event.dart
import '../../enums/enums.dart';

class MessageEvent {
  final String message;
  final MessageType messageType;

  const MessageEvent(this.message, {this.messageType = MessageType.error});
}
