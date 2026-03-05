import 'package:hive/hive.dart';

import '../../models/user.dart';
import 'hive_keys.dart';
import '../user_repository.dart';

class HiveUserRepository implements UserRepository {
  Box<User> get _box => Hive.box<User>(HiveKeys.usersBox);

  @override
  Future<List<User>> getAll() async {
    return _box.values.toList(growable: false);
  }

  @override
  Future<User?> getById(String id) async {
    return _box.get(id);
  }

  @override
  Future<List<User>> search(String query) async {
    final q = query.trim().toLowerCase();
    final all = await getAll();
    if (q.isEmpty) return all;
    return all.where((u) => u.name.toLowerCase().contains(q)).toList(growable: false);
  }
}