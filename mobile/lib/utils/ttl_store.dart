import "package:hive/hive.dart";

class TtlStorage {
  final Box _box;
  final Duration ttl;

  TtlStorage(this._box, {required this.ttl});

  Future<void> save(String key, dynamic value) async {
    await _box.put(key, {
      "value": value,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  dynamic get(String key) {
    final data = _box.get(key);

    if (data == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final storedTime = data["timestamp"] as int;
    final timeElapsed = now - storedTime;

    if (timeElapsed > ttl.inMilliseconds) {
      _box.delete(key);
      return null;
    }

    return data["value"] as dynamic;
  }
}
