import 'package:get/get.dart';

import 'channel_manage_controller.dart';

class ChannelManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChannelManageController>(
      () => ChannelManageController(),
    );
  }
}
