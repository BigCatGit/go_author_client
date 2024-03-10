import 'package:get/get.dart';

import 'module_manage_controller.dart';

class ModuleManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModuleManageController>(
      () => ModuleManageController(),
    );
  }
}
