import 'package:hive/hive.dart';

part 'chat.g.dart';

@HiveType(typeId: 2)
class Chat extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<String> participantIds;

  Chat({
    required this.id,
    required this.participantIds,
  });
}