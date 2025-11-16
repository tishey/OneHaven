import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onehaven_assessment/provider/connection_provier.dart';

class InternetConnectionWrapper extends ConsumerWidget {
  final Widget child;

  const InternetConnectionWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            child,

            connectivityAsync.when(
              data: (isConnected) {
                log('CONNEXTIVITY: $isConnected');
                return isConnected
                    ? const SizedBox.shrink()
                    : _buildOfflineBanner(context);
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'No internet connection',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
