/// [UnsplashException] describes an error communicating with the Unsplash API.
class UnsplashException extends Error {
  UnsplashException(this.code, this.message, this.reason);

  /// The HTTP response code returned from the API.
  final int code;

  /// A message describing the error.
  final String message;

  /// The reason string returned from the API.
  final String reason;

  @override
  String toString() {
    return 'UnsplashException [$code] $message ($reason)';
  }
}
