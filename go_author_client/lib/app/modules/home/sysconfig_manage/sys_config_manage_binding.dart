import 'package:get/get.dart';

import 'sys_config_manage_controller.dart';

class SysConfigManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SysConfigManageController>(
      () => SysConfigManageController(),
    );
  }
}
