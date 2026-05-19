import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Service that provides instant synchronous access to ACTUAL internet connectivity
/// Combines connectivity_plus (network) + internet_connection_checker_plus (real internet)
class NetworkUtil {
  factory NetworkUtil() => _instance;
  NetworkUtil._internal();
  static final NetworkUtil _instance = NetworkUtil._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetStatus>? _internetSubscription;

  // Synchronously accessible flags - no waiting!
  bool _hasNetworkConnection = true; // Device connected to WiFi/Mobile
  bool _hasInternetAccess = true; // Actual internet is reachable

  /// True if device has actual working internet connection
  bool get isConnected => _hasNetworkConnection && _hasInternetAccess;

  /// True if connected to network but no internet (captive portal, no routing, etc)
  bool get isConnectedButNoInternet =>
      _hasNetworkConnection && !_hasInternetAccess;

  /// Detailed status getter
  NetworkStatus get status {
    if (!_hasNetworkConnection) return NetworkStatus.offline;
    if (!_hasInternetAccess) return NetworkStatus.connectedNoInternet;
    return NetworkStatus.online;
  }

  /// Initialize the service - call this in main() or app startup
  Future<void> initialize() async {
    // Get initial connectivity status
    final connectivityResults = await _connectivity.checkConnectivity();
    _updateNetworkStatus(connectivityResults);

    // Get initial internet status
    final internetStatus = await _internetChecker.internetStatus;
    _updateInternetStatus(internetStatus);

    // Listen for network connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateNetworkStatus);

    // Listen for actual internet changes
    _internetSubscription =
        _internetChecker.onStatusChange.listen(_updateInternetStatus);
  }

  void _updateNetworkStatus(List<ConnectivityResult> results) {
    _hasNetworkConnection = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet,);
  }

  void _updateInternetStatus(InternetStatus status) {
    _hasInternetAccess = status == InternetStatus.connected;
  }

  /// Force check internet right now (useful after network change)
  Future<bool> checkInternet() async {
    final status = await _internetChecker.internetStatus;
    _updateInternetStatus(status);
    return isConnected;
  }

  /// Stream of connectivity changes (true = has internet, false = no internet)
  Stream<bool> get connectivityStream {
    return _internetChecker.onStatusChange
        .map((status) => status == InternetStatus.connected);
  }

  /// Stream of detailed status changes
  Stream<NetworkStatus> get statusStream {
    // Combine both streams
    return _internetChecker.onStatusChange.map((internetStatus) {
      if (!_hasNetworkConnection) return NetworkStatus.offline;
      if (internetStatus != InternetStatus.connected) {
        return NetworkStatus.connectedNoInternet;
      }
      return NetworkStatus.online;
    });
  }

  /// Clean up
  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
  }
}

/// Network status enum
enum NetworkStatus {
  online, // Full internet access
  connectedNoInternet, // Connected to WiFi/Mobile but no internet
  offline, // No network connection at all
}
