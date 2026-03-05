import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Chat {
  @HiveField(0)
  final String id;

  /// For 1:1 chat we keep exactly 2 participant ids.
  @HiveField(1)
  final List<String> participantIds;

  @HiveField(2)
  final bool pinned;

  @HiveField(3)
  final int unreadCount;

  /// Convenience: last message preview text (persisted).
  @HiveField(4)
  final String lastMessageText;

  @HiveField(5)
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.participantIds,
    required this.pinned,
    required this.unreadCount,
    required this.lastMessageText,
    required this.updatedAt,
  });

  Chat copyWith({
    String? id,
    List<String>? participantIds,
    bool? pinned,
    int? unreadCount,
    String? lastMessageText,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      pinned: pinned ?? this.pinned,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Manual adapter
class ChatAdapter extends TypeAdapter<Chat> {
  @override
  final int typeId = 2;

  @override
  Chat read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final numOfFields = reader.readByte();
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return Chat(
      id: fields[0] as String,
      participantIds: (fields[1] as List).cast<String>(),
      pinned: fields[2] as bool,
      unreadCount: fields[3] as int,
      lastMessageText: fields[4] as String,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Chat obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.participantIds)
      ..writeByte(2)
      ..write(obj.pinned)
      ..writeByte(3)
      ..write(obj.unreadCount)
      ..writeByte(4)
      ..write(obj.lastMessageText)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }
}