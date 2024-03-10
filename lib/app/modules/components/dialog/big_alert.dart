import 'package:flutter/material.dart';

class BigAlert {
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? content,
    String? buttonTitle,
  }) async {
    // 弹出对话框
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ""),
          content: Text(content ?? ""),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(buttonTitle ?? "确定"),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showConfirm({
    required BuildContext context,
    String? title,
    String? content,
    String? yesButtonTitle,
    String? noButtonTitle,
    Function()? onYesCallback,
    Function()? onNoCallback,
  }) async {
    // 弹出对话框
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ""),
          content: Text(content ?? ""),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (onNoCallback != null) {
                  onNoCallback();
                }
                Navigator.of(context).pop(false);
              },
              child: Text(noButtonTitle ?? "取消"),
            ),
            TextButton(
              onPressed: () {
                if (onYesCallback != null) {
                  onYesCallback();
                }
                Navigator.of(context).pop(true);
              },
              child: Text(yesButtonTitle ?? "确定"),
            ),
          ],
        );
      },
    );
    return result;
  }
}
