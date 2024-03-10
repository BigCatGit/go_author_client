import 'package:get/get.dart';
import 'package:go_author_client/app/modules/home/channel_manage/channel_manage_controller.dart';
import 'package:go_author_client/app/modules/home/group_manage/group_manage_controller.dart';
import 'package:go_author_client/app/modules/home/sysconfig_manage/sys_config_manage_controller.dart';

import '../modules/home/channel_manage/channel_manage_binding.dart';
import '../modules/home/channel_manage/channel_manage_view.dart';
import '../modules/home/group_manage/group_manage_binding.dart';
import '../modules/home/group_manage/group_manage_view.dart';
import '../modules/home/sysconfig_manage/sys_config_manage_binding.dart';
import '../modules/home/sysconfig_manage/sys_config_manage_view.dart';
import '../modules/home/base_page.dart';
import '../modules/home/dashboard/dashboard_controller.dart';
import '../modules/home/dashboard/dashboard_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/home/module_manage/module_manage_controller.dart';
import '../modules/home/module_manage/module_manage_view.dart';
import '../modules/home/permission_manage/permission_manage_binding.dart';
import '../modules/home/permission_manage/permission_manage_controller.dart';
import '../modules/home/permission_manage/permission_manage_view.dart';
import '../modules/home/role_manage/role_manage_binding.dart';
import '../modules/home/role_manage/role_manage_controller.dart';
import '../modules/home/role_manage/role_manage_view.dart';
import '../modules/home/user_manage/user_manage_binding.dart';
import '../modules/home/user_manage/user_manage_controller.dart';
import '../modules/home/user_manage/user_manage_view.dart';
import '../modules/loading/loading_binding.dart';
import '../modules/loading/loading_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();
  // 首页
  static const String INITIAL = Routes.LOADING;

  static final routes = [
    // 非管理页面放在最前面
    GetPage(
      name: _Paths.LOADING,
      page: () => LoadingView(),
      binding: LoadingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    // 管理页面不需要添加到路由列表
    GetPage(
      name: _Paths.PERMISSION_MANAGE,
      page: () => PermissionManageView(),
      binding: PermissionManageBinding(),
    ),
    GetPage(
      name: _Paths.ROLE_MANAGE,
      page: () => RoleManageView(),
      binding: RoleManageBinding(),
    ),
    GetPage(
      name: _Paths.USER_MANAGE,
      page: () => UserManageView(),
      binding: UserManageBinding(),
    ),
    GetPage(
      name: _Paths.GROUP_MANAGE,
      page: () => GroupManageView(),
      binding: GroupManageBinding(),
    ),
    GetPage(
      name: _Paths.SYS_CONFIG_MANAGE,
      page: () => SysConfigManageView(),
      binding: SysConfigManageBinding(),
    ),
    GetPage(
      name: _Paths.CHANNEL_MANAGE,
      page: () => ChannelManageView(),
      binding: ChannelManageBinding(),
    ),
  ];

  // 将需要显示到PageView的管理页面手动添加到下面的列表
  // path必须与后台的对应
  static List<BasePage> pages = [
    BasePage(
      path: "/admin/dashboard",
      page: GetBuilder<DashboardController>(
        init: DashboardController(),
        builder: (controller) => DashboardView(),
      ),
    ),
    BasePage(
      path: "/admin/system/module",
      page: GetBuilder<ModuleManageController>(
        init: ModuleManageController(),
        builder: (controller) => ModuleManageView(),
      ),
    ),
    BasePage(
      path: "/admin/system/permission",
      page: GetBuilder<PermissionManageController>(
        init: PermissionManageController(),
        builder: (controller) => PermissionManageView(),
      ),
    ),
    BasePage(
      path: "/admin/system/role",
      page: GetBuilder<RoleManageController>(
        init: RoleManageController(),
        builder: (controller) => RoleManageView(),
      ),
    ),
    BasePage(
      path: "/admin/system/user",
      page: GetBuilder<UserManageController>(
        init: UserManageController(),
        builder: (controller) => UserManageView(),
      ),
    ),
    BasePage(
      path: "/admin/system/group",
      page: GetBuilder<GroupManageController>(
        init: GroupManageController(),
        builder: (controller) => GroupManageView(),
      ),
    ),
    BasePage(
      path: "/admin/system/sysConfig",
      page: GetBuilder<SysConfigManageController>(
        init: SysConfigManageController(),
        builder: (controller) => SysConfigManageView(),
      ),
    ),
    BasePage(
      path: "/admin/business/channel",
      page: GetBuilder<ChannelManageController>(
        init: ChannelManageController(),
        builder: (controller) => ChannelManageView(),
      ),
    ),
  ];
}
