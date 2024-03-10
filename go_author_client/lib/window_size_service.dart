// ignore_for_file: unused_element

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:window_size/window_size.dart';

class WindowSizeService {
  // static const double width = 1170 / 3.0;
  // static const double height = 2532 / 3.0;
  static const double width = 1800 / 3.0;
  static const double height = 1800 / 3.0;

  // 单例模式的私有构造函数，防止外部直接实例化
  WindowSizeService._();
  // 单例实例
  static WindowSizeService? _instance;
  // 获取单例实例的方法
  static WindowSizeService get instance {
    // 如果实例不存在，创建一个新的实例
    _instance ??= WindowSizeService._();
    return _instance!;
  }

  Future<PlatformWindow> getPlatformWindow() async {
    return await window_size.getWindowInfo();
  }

  // 设置窗口最大化
  void setWindowMaximize() async {
    var platformWindow = await getPlatformWindow();
    final Rect frame = Rect.fromCenter(
      center: Offset(
        platformWindow.frame.center.dx,
        platformWindow.frame.center.dy,
      ),
      width: platformWindow.screen!.visibleFrame.width,
      height: platformWindow.screen!.visibleFrame.height,
    );
    window_size.setWindowFrame(frame);
  }

  // 控制大小的核心代码
  void setWindowSize() async {
    var platformWindow = await getPlatformWindow();
    final Rect frame = Rect.fromCenter(
      center: Offset(
        platformWindow.frame.center.dx,
        platformWindow.frame.center.dy,
      ),
      width: width,
      height: height,
    );
    window_size.setWindowFrame(frame);
    if (Platform.isMacOS || Platform.isWindows) {
      // 如果最大尺寸和最大尺寸相同，则是禁止调整窗口大小
      // window_size.setWindowMinSize(Size(width, height));
      // window_size.setWindowMaxSize(Size(width, height));
    }
  }

  Future<void> initialize() async {
    PlatformWindow platformWindow = await getPlatformWindow();
    if (platformWindow.screen != null) {
      // 判断初始时不等于指定的尺寸，则修改尺寸
      // if (platformWindow.screen?.visibleFrame.width != 800 || platformWindow.screen?.visibleFrame.height != 500) {
      //  setWindowSize(platformWindow);
      // }
      // 强制设置窗口大小
      // setWindowSize(platformWindow);
      // 设置窗口最大化
      // setWindowMaximize(platformWindow);
    }

    // 修改标题, 这个设置可以禁止修改窗口大小
    // setWindowTitle(Consts.title);
  }

  void setWindowTitle(String title) {
    window_size.setWindowTitle(title);
  }
}
