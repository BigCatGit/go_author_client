import 'package:get/get.dart';

import 'role_manage_controller.dart';

class RoleManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleManageController>(
      () => RoleManageController(),
    );
  }
}
