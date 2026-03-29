import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  ConnectivityProvider() {
    _init();
  }

  void _init() {
    checkConnectivity();
    listenConnection();
  }

  final Connectivity _connectivity = Connectivity();
  bool _isConnectivity = true;

  bool get isConnectivity => _isConnectivity;
  Future<void> checkConnectivity() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      _isConnectivity = false;
    } else {
      _isConnectivity = true;
    }
    log("result : $result");
    notifyListeners();
  }

  Future<void> listenConnection() async {
    StreamSubscription<List<ConnectivityResult>> listen = _connectivity
        .onConnectivityChanged
        .listen((result) {
          if (result.contains(ConnectivityResult.none)) {
            _isConnectivity = false;
          } else {
            _isConnectivity = true;
          }
          notifyListeners();
        });
    log("listen : $listen");
  }
}
