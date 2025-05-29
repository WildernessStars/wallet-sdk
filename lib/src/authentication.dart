import 'package:flutter/material.dart';

/// 认证控制器类，用于处理用户认证相关的对话框
class AuthenticationController {
  /// 全局导航键，用于获取当前上下文
  static late GlobalKey<NavigatorState> navigatorKey;

  /// 初始化认证控制器
  /// [key] 全局导航键
  static void initialize(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// 显示认证对话框
  /// [title] 对话框标题
  /// [message] 对话框消息内容
  /// [approveText] 确认按钮文本，默认为"确认"
  /// [rejectText] 取消按钮文本，默认为"取消"
  /// 返回用户的选择结果（true表示确认，false表示取消）
  static Future<bool> showDialog({
    required String title,
    required String message,
    String approveText = '确认',
    String rejectText = '取消',
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) {
      throw Exception("Navigator context 未初始化");
    }

    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: false,  // 禁止点击背景关闭对话框
          barrierLabel: "AuthDialog",
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, __, ___) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(rejectText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(approveText),
              ),
            ],
          ),
        ) ??
        false;
  }
}