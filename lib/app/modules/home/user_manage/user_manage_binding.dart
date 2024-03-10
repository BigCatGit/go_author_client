import 'package:get/get.dart';

import 'user_manage_controller.dart';

class UserManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserManageController>(
      () => UserManageController(),
    );
  }
}
