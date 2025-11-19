import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../src/presentation/widget/connection_toast.dart';


class ConnectionService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static List<ConnectivityResult> _lastStatus = [ConnectivityResult.none];

  static void initialize(BuildContext context) {
    // Check initial connectivity status
    _initConnectivity(context);

    // Listen for connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
          _updateConnectionStatus(result, context);
        });
  }

  static Future<void> _initConnectivity(BuildContext context) async {
    late List<ConnectivityResult> result;

    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      // If connectivity check fails, assume no connection
      result = [ConnectivityResult.none];
    }

    if (_isDifferentConnection(result)) {
      _updateConnectionStatus(result, context);
    }
  }

  static void _updateConnectionStatus(List<ConnectivityResult> result, BuildContext context) {
    // Only update if the status actually changed
    if (_isDifferentConnection(result)) {
      _lastStatus = result;

      final bool isConnected = result.any((r) => r != ConnectivityResult.none);

      if (isConnected) {
        ConnectionToast.showConnected(context);
      } else {
        ConnectionToast.showDisconnected(context);
      }
    }
  }

  static bool _isDifferentConnection(List<ConnectivityResult> newStatus) {
    if (_lastStatus.length != newStatus.length) return true;

    for (var status in newStatus) {
      if (!_lastStatus.contains(status)) return true;
    }

    return false;
  }

  static Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}