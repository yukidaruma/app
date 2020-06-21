class InvalidOperationException implements Exception {
  InvalidOperationException([this.message]);

  final String message;

  @override
  String toString() {
    return 'Invalid operation' + message == null ? '' : ': $message';
  }
}
