
import 'package:flutter/material.dart';
import 'sdk_client_page.dart';
import 'package:web3_smartwatch_sdk/web3_smartwatch_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();
  AuthenticationController.initialize(navigatorKey);

  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    home: const WalletSdkClientPage(),
  ));
}
