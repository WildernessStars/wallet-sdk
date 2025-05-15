
import 'dart:async';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'provider1193.dart';

enum BridgeAction {
  ethRequestAccounts,
  ethAccounts,
  ethChainId,
  personalSign,
  ethSendTransaction,
  ethCall,
  walletDisconnect, 
}

extension BridgeActionExtension on BridgeAction {
  String get method {
    switch (this) {
      case BridgeAction.ethRequestAccounts:
        return 'eth_requestAccounts';
      case BridgeAction.ethAccounts:
        return 'eth_accounts';
      case BridgeAction.ethChainId:
        return 'eth_chainId';
      case BridgeAction.personalSign:
        return 'personal_sign';
      case BridgeAction.ethSendTransaction:
        return 'eth_sendTransaction';
      case BridgeAction.ethCall:
        return 'eth_call';
      case BridgeAction.walletDisconnect:
        return 'wallet_disconnect';
    }
  }

  static BridgeAction? from(String value) {
    try {
      return BridgeAction.values.firstWhere((a) => a.method == value);
    } catch (_) {
      return null;
    }
  }
}



class BridgeError implements Exception {
  final String code;
  final String message;
  final dynamic details;

  BridgeError({required this.code, required this.message, this.details});

  @override
  String toString() => 'BridgeError($code): $message';
}


class BridgeClient {
  final EIP1193Provider provider;
  final InAppWebViewController webViewController;
  final Duration timeout;
  final bool debug;

  BridgeClient({
    required this.webViewController,
    this.timeout = const Duration(seconds: 10),
    this.debug = false,
    required this.provider,
  }){
    _registerJsHandler();
  }

  void _registerJsHandler(){
    webViewController.addJavaScriptHandler(
    handlerName: 'jsBridgeHandler',
    callback: (args) async {
        final message = args.first;
        final String actionStr = message['action'];
        final dynamic data = message['data'];
        final String callbackId = message['callbackId'];

        try {
            final BridgeAction? action = BridgeActionExtension.from(actionStr);

            // handle different requests based on the action field in the payload
            final result = await _processJsAction(action, data).timeout(Duration(seconds: 10), onTimeout: () {
              throw BridgeError(
                code: 'BRIDGE_TIMEOUT',
                message: 'Request Timeout ($action)',
              );
            });

            // return result to JS
            await webViewController.evaluateJavascript(source: """
                window.flutterBridge.receiveFromFlutter('$callbackId', true, ${jsonEncode(result)});
            """);

            return true;
        } catch (e) {
            // return error to JS
            await webViewController.evaluateJavascript(source: """
                window.flutterBridge.receiveFromFlutter('$callbackId', false, "${e.toString()}");
            """);
            return false;
        }
    },
    );
  }

  Future<dynamic> _processJsAction(BridgeAction? action, dynamic data) async { 
    if (action == null) {
      throw Exception('Invalid action or callbackId');
    }
    switch (action) {
      case BridgeAction.ethRequestAccounts:
        return provider.connect();
      case BridgeAction.personalSign:
        return provider.signMessage(data);
      // case BridgeAction.disconnect:
      //   return provider.disconnect();
      // case BridgeAction.getAccounts:
      //   return provider.getAccounts();
      // case BridgeAction.getChainId:
      //   return await provider.getChainId();
      case BridgeAction.ethSendTransaction:
        return provider.sendTransaction(data);
      // case BridgeAction.callRpc:
      //   return await provider.callRpc(data);
      default:
        throw Exception('Unknown action: $action');
    }
  }

}
