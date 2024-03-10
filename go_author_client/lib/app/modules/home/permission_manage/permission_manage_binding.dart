import 'package:get/get.dart';

import 'permission_manage_controller.dart';

class PermissionManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionManageController>(
      () => PermissionManageController(),
    );
  }
}
