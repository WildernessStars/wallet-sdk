import 'dart:async';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'provider1193.dart';
import 'authentication.dart';

/// 桥接操作类型枚举，定义了所有支持的Web3操作
enum BridgeAction {
  getAccounts,    // 获取账户列表
  getChainId,     // 获取链ID
  sign,           // 签名消息
  send,           // 发送交易
  call,           // 调用合约
  getBalance,     // 获取余额
  sendMessage,    // 发送消息
  walletDisconnect, // 断开钱包连接
  getter,         // 调用合约getter方法
  setter,         // 调用合约setter方法
}

/// BridgeAction的扩展方法，用于获取对应的Web3方法名
extension BridgeActionExtension on BridgeAction {
  /// 获取对应的Web3方法名
  String get method {
    switch (this) {
      case BridgeAction.getAccounts:
        return 'eth_requestAccounts';
      case BridgeAction.getChainId:
        return 'eth_chainId';
      case BridgeAction.sign:
        return 'personal_sign';
      case BridgeAction.send:
        return 'eth_sendTransaction';
      case BridgeAction.call:
        return 'eth_call';
      case BridgeAction.walletDisconnect:
        return 'wallet_disconnect';
      case BridgeAction.getBalance:
        return 'eth_getBalance';
      case BridgeAction.sendMessage:
        return 'eth_sendMessage';
      case BridgeAction.getter:
        return 'eth_callGetter';
      case BridgeAction.setter:
        return 'eth_callSetter';
    }
  }

  /// 从方法名获取对应的BridgeAction
  static BridgeAction? from(String value) {
    try {
      return BridgeAction.values.firstWhere((a) => a.method == value);
    } catch (_) {
      return null;
    }
  }
}

/// 桥接错误类，用于处理桥接过程中的错误
class BridgeError implements Exception {
  final String code;      // 错误代码
  final String message;   // 错误信息
  final dynamic details;  // 错误详情

  BridgeError({required this.code, required this.message, this.details});

  @override
  String toString() => 'BridgeError($code): $message';
}

/// 桥接客户端类，用于处理JavaScript和Flutter之间的通信
class BridgeClient {
  final EIP1193Provider provider;           // Web3提供者实例
  final InAppWebViewController webViewController;  // WebView控制器
  final Duration timeout;                   // 请求超时时间
  final bool debug;                         // 是否开启调试模式

  BridgeClient({
    required this.webViewController,
    this.timeout = const Duration(seconds: 10),
    this.debug = false,
    required this.provider,
  }){
    _registerJsHandler();
  }

  /// 注册JavaScript消息处理器
  void _registerJsHandler(){
    webViewController.addJavaScriptHandler(
    handlerName: 'jsBridgeHandler',
    callback: (args) async {
      if (args.isEmpty || args.first is! Map) {
        throw BridgeError(
          code: 'INVALID_MESSAGE',
          message: 'No message payload received or wrong format',
        );
      }
      final message = args.first;
      final String actionStr = message['action'];
      final dynamic data = message['data'];
      final String callbackId = message['callbackId'];

      try {
          final BridgeAction? action = BridgeActionExtension.from(actionStr);
          if (action == null) {
            throw BridgeError(
              code: 'INVALID_ACTION',
              message: 'Invalid action: $actionStr',
            );
          }
          if (debug) {
            print('[BridgeClient] received action: $action, data: $data');
          }
          // 处理不同的请求操作
          final result = await _processJsAction(action, data).timeout(Duration(seconds: 10), onTimeout: () {
            throw BridgeError(
              code: 'BRIDGE_TIMEOUT',
              message: 'Request Timeout ($action)',
            );
          });

          // 返回结果给JavaScript
          await webViewController.evaluateJavascript(source: """
              window.flutterBridge.receiveFromFlutter('$callbackId', true, ${jsonEncode(result)});
          """);

          return true;
      } catch (e) {
          if (debug) {
            print('[BridgeClient] Error: $e');
          }
          // 返回错误给JavaScript
          await webViewController.evaluateJavascript(source: """
              window.flutterBridge.receiveFromFlutter('$callbackId', false, "${e.toString()}");
          """);
          return false;
      }
    },
    );
  }

  /// 处理JavaScript请求的具体操作
  Future<dynamic> _processJsAction(BridgeAction action, dynamic data) async { 
    switch (action) {
      case BridgeAction.getAccounts:
        // 请求连接钱包
        final approve = await AuthenticationController.showDialog(
          title: 'Connect Wallet',
          message: 'Allow connection to wallet?',
        );
        if (!approve) {
          throw BridgeError(code: 'USER_REJECTED', message: 'User rejected the connection');
        }
        return provider.connect();
      case BridgeAction.sign:
        // 签名消息
        print("sign: $data");
        if (data is! String) {
          throw BridgeError(code: 'INVALID_PARAMS', message: 'personalSign expects a string');
        }
        return provider.signMessage(data);
      case BridgeAction.sendMessage:
        // 发送消息
        if (data is! Map<String, dynamic>) {
          throw BridgeError(code: 'INVALID_PARAMS', message: 'sendMessage expects a map');
        }
        return provider.sendMessage(data);
      case BridgeAction.getChainId:
        // 获取链ID
        final approve = await AuthenticationController.showDialog(
          title: 'Get Chain ID',
          message: 'Allow to get chain ID?',
        );
        if (!approve) {
          throw BridgeError(code: 'USER_REJECTED', message: 'User rejected the request');
        }
        return await provider.getChainId();
      case BridgeAction.send:
        // 发送交易
        if (data is! Map<String, dynamic>) {
          throw BridgeError(code: 'INVALID_PARAMS', message: 'sendTransaction expects a map');
        }
        return provider.sendTransaction(data);
      case BridgeAction.getBalance:
        // 获取余额
        return provider.getBalance();
      case BridgeAction.call:
        // 调用合约
        if (data is! Map<String, dynamic>) {
          throw BridgeError(code: 'INVALID_PARAMS', message: 'call expects a map');
        }
        return await provider.call(data);
      case BridgeAction.getter:
        // 调用合约getter方法
        if (data is! Map<String, dynamic>) {
          throw BridgeError(code: 'INVALID_PARAMS', message: 'getter expects a map');
        }
        return await provider.callGetter(data);
      case BridgeAction.setter:
        // 调用合约setter方法
        if (data is! Map<String, dynamic>) {
          throw BridgeError(code: 'INVALID_PARAMS', message: 'setter expects a map');
        }
        return await provider.callSetter(data);
      default:
        throw BridgeError(code: 'UNKNOWN_ACTION', message: 'Unknown action: $action');
    }
  }
}

/// BridgeClient的调试扩展
extension BridgeClientDebug on BridgeClient {
  /// 调试调用方法
  Future<dynamic> debugCall(BridgeAction action, dynamic data) {
    return _processJsAction(action, data);
  }
}
