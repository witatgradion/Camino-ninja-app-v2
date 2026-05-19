import 'dart:async';

/// Events emitted by [AuthEventBus].
enum AuthEvent {
  /// The user's session has expired and credentials were cleared.
  sessionExpired,
}

/// A simple broadcast event bus for authentication-related events.
///
/// Registered as a singleton in DI so that the network layer can
/// emit events (e.g. forced logout) and the UI layer can listen.
class AuthEventBus {
  final _controller = StreamController<AuthEvent>.broadcast();

  /// Stream of authentication events.
  Stream<AuthEvent> get stream => _controller.stream;

  /// Emit an authentication event.
  void emit(AuthEvent event) => _controller.add(event);

  /// Dispose the underlying stream controller.
  void dispose() => _controller.close();
}
