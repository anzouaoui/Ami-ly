/// Exceptions levées par les datasources (couche data).
/// Les repositories les convertissent en [Failure] pour la couche domain.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class FirestoreException implements Exception {
  FirestoreException(this.message);
  final String message;

  @override
  String toString() => 'FirestoreException: $message';
}

class StorageException implements Exception {
  StorageException(this.message);
  final String message;

  @override
  String toString() => 'StorageException: $message';
}
