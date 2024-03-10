// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 我们必须将对话窗口创建为有状态的，在关闭时销毁，
// 打开时重新加载数据, 这样以便于放在全局页面中打开时自动更新数据

class BigDialog extends StatefulWidget {
  final String title;
  final double width;
  final double height;
  final Function(Widget widget)? onClose;
  final Function(Widget widget)? onShow;
  final Widget child;
  final bool buttonsVisible;
  final List<Widget> otherButtons;
  final Function(BigDialog dialog)? onCancel;
  final Function(BigDialog dialog)? onConfirm;

  const BigDialog({
    Key? key,
    required this.title,
    this.width = 600,
    this.height = 720,
    this.onClose,
    this.onShow,
    this.buttonsVisible = false,
    this.otherButtons = const [],
    required this.child,
    this.onCancel,
    this.onConfirm,
  }) : super(key: key);

  @override
  State<BigDialog> createState() => _BigDialogState();
}

class _BigDialogState extends State<BigDialog> {
  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKey);
  }

  void _handleKey(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (widget.onClose != null) {
        widget.onClose!(widget);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onShow != null) {
      widget.onShow!(widget);
    }
    return Center(
      child: Stack(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(0xFF, 0x24, 0x24, 0x24),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey,
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 3.0),
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题控件
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),

                Expanded(
                  child: widget.child,
                ),

                if (widget.buttonsVisible) SizedBox(height: 16.0),

                if (widget.buttonsVisible)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (var btn in widget.otherButtons)
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: btn,
                        ),
                      SizedBox(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.onCancel != null) {
                              widget.onCancel!(widget);
                            }
                          },
                          icon: Icon(Icons.close),
                          label: Text('取消'),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      SizedBox(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.onConfirm != null) {
                              widget.onConfirm!(widget);
                            }
                          },
                          icon: Icon(Icons.done),
                          label: Text('确定'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // 关闭按钮
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close),
              iconSize: 32,
              onPressed: () {
                if (widget.onClose != null) {
                  widget.onClose!(widget);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
