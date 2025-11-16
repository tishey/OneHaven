import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  final initialResult = await NetworkUtils.hasInternetConnection();
  yield initialResult;

  final streamGroup = StreamGroup<bool>();

  streamGroup.add(
    connectivity.onConnectivityChanged.asyncMap(
      (_) => NetworkUtils.hasInternetConnection(),
    ),
  );

  streamGroup.add(
    Stream.periodic(
      const Duration(seconds: 3),
    ).asyncMap((_) => NetworkUtils.hasInternetConnection()),
  );

  yield* streamGroup.stream.distinct();
});

class NetworkUtils {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
