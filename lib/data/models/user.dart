import 'package:hive/hive.dart';



@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isOnline;

  @HiveField(3)
  final DateTime lastSeenAt;

  const User({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.lastSeenAt,
  });

  User copyWith({
    String? id,
    String? name,
    bool? isOnline,
    DateTime? lastSeenAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}

/// Manual adapter (no build_runner)
class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final numOfFields = reader.readByte();
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      isOnline: fields[2] as bool,
      lastSeenAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isOnline)
      ..writeByte(3)
      ..write(obj.lastSeenAt);
  }
}