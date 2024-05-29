abstract class Repository<T> {
  Future<void> save();
  Future<void> saveAll(modelStream);
  Future<T> read();
  Future<List<T>> readAll();
  Future<void> update();
  Future<void> delete();
  Future<void> deleteAll();
}
