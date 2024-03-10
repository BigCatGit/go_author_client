import 'dart:async';

import 'package:get/get.dart';
import 'package:go_author_client/app/consts/global.dart';
import 'package:go_author_client/app/models/big_notification.dart';

class DashboardController extends GetxController {
  final RxInt count = RxInt(0);
  late Timer timer;
  final RxString nickname = RxString("");

  @override
  void onInit() {
    super.onInit();
    Global.eventBus.on<BigNotification>().listen((event) {
      if (event.id == "profile") {
        this.nickname.value = event.msg["nickname"] ?? "";
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    startTimer();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      count.value++;
    });
  }
}
