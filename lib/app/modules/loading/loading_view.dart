import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_author_client/app/routes/app_pages.dart';
import 'package:go_author_client/app/utils/local_storage.dart';

import 'loading_controller.dart';

class LoadingView extends GetView<LoadingController> {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 初始化异步数据
    initAsyncData().then((value) {
      // 初始化完成过后则关闭进度条，跳转到登录页面
      Get.offAllNamed(Routes.LOGIN);
      controller.isLoading.value = false;
    });
    return Obx(() {
      return Scaffold(
        body: Stack(
          children: [
            // 背景图片
            // Positioned.fill(
            //   child: Image.asset(
            //     "assets/images/loading_bg.jpg",
            //     fit: BoxFit.cover, // 适应方式，可根据需要调整
            //   ),
            // ),
            Column(
              children: [
                SizedBox(height: 50),
                Text(
                  "请稍候",
                  style: TextStyle(fontSize: 36),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      controller.isLoading.value
                          ? Center(
                              child: CircularProgressIndicator(
                                semanticsLabel: "正在初始化...",
                              ),
                            )
                          : Center(
                              child: Text('初始化已完成...'),
                            ),
                      SizedBox(
                        height: 24,
                      ),
                      Text("加载中..."),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Future<void> initAsyncData() async {
    // 执行异步初始化操作
    // await Future.delayed(Duration(seconds: 2)); // 模拟异步加载
    await LocalStorage.initStore();
    if (LocalStorage.get("remember-me") == null) {
      LocalStorage.set("remember-me", true);
    }
    if (LocalStorage.get("agreement") == null) {
      LocalStorage.set("agreement", true);
    }
  }
}
