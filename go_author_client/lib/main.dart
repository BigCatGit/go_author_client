import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/consts/consts.dart';
import 'package:go_author_client/app/routes/app_pages.dart';
import 'package:go_author_client/window_size_service.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 自定义窗口大小
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowSizeService.instance.initialize();
  }
  initializeDateFormatting();

  GetMaterialApp app = GetMaterialApp(
    title: Consts.title,
    theme: ThemeData.light().copyWith(
      textTheme: TextTheme(
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
        ),
        // 设置其他文本样式
      ),
    ),
    darkTheme: ThemeData.dark().copyWith(
      textTheme: TextTheme(
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
        ),
        // 设置其他文本样式
      ),
    ),
    // theme: ThemeData.dark().copyWith(
    //   scaffoldBackgroundColor: bgColor,
    //   textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
    //   canvasColor: secondaryColor,
    // ),
    debugShowCheckedModeBanner: false,
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      SfGlobalLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', 'US'), // 美式英语
      const Locale('zh', 'CN'), // 中文简体
    ],
    locale: const Locale('zh', 'CN'), // 中文简体
    // 首页
    initialRoute: AppPages.INITIAL,
    getPages: AppPages.routes,
    // 实现pc端的鼠标拖动页面
    scrollBehavior: MaterialScrollBehavior().copyWith(
      scrollbars: true,
    ),
    builder: BotToastInit(), // 初始化BotToast
    navigatorObservers: [BotToastNavigatorObserver()], // 注册BotToast观察者
  );
  //初始化设置 LogUtil
  LogUtil.init(tag: "[Log] ", isDebug: true);
  runApp(app);
}
