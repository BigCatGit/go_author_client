import 'package:get/get.dart';

import 'group_manage_controller.dart';

class GroupManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupManageController>(
      () => GroupManageController(),
    );
  }
}
