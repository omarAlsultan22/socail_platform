abstract class BaseRepository {
  Future<Map<String, dynamic>> getInfo({
    required String uid
  });
}