import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/api/user_api.dart';
import 'package:go_author_client/app/consts/consts.dart';
import 'package:go_author_client/app/consts/global.dart';
import 'package:go_author_client/app/models/module.dart';
import 'package:go_author_client/app/routes/app_pages.dart';
import 'package:go_author_client/app/utils/local_storage.dart';
import 'package:go_author_client/window_size_service.dart';

// 注意这里我们需要多次添加tab, 所以不能使用GetSingleTickerProviderStateMixin
// 这种Mixin不能多次实例化tabController
// 使用Drawer作为左侧功能菜单，但是每次点击菜单都会自动关闭菜单
class HomeController extends GetxController with GetTickerProviderStateMixin {
  int currentPage = 0;
  // 全局控件对象，可以取context
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Module> modules = <Module>[];
  List<Widget> tiles = <Widget>[];
  Rx<Module> selectedModule = Module(id: 0, name: "", path: "", hidden: false).obs;
  RxDouble leftMenuWidth = RxDouble(200);
  PageController pageController = PageController(initialPage: 0);

  @override
  void onInit() async {
    super.onInit();
    WindowSizeService.instance.setWindowMaximize();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // 从服务器获取模块列表
  Future<List<Module>>? fetchData() async {
    try {
      Map<String, dynamic>? resp = await UserApi().getModuleTree();
      if (resp == null || resp["code"] != 200) {
        BotToast.showText(text: "获取模块列表失败: ${resp?["message"]}");
        return [];
      }
      // 使用map方法将List<Map>转换为List<Module>
      List<Map<String, dynamic>> jsonList = resp["data"].cast<Map<String, dynamic>>();
      modules = jsonList.map((jsonMap) => Module.fromJson(jsonMap)).toList();
      if (modules.isNotEmpty) {
        selectedModule.value = modules[0];
      }
      Global.modules.clear();
      Global.modules.addAll(modules);
      Global.permissions.clear();
      this.modulesToList(modules);
      // 模拟延迟
      await Future<void>.delayed(Duration(milliseconds: Consts.debug_delay), () {});
      return modules;
    } catch (e) {
      BotToast.showText(text: "获取模块列表失败");
      return [];
    }
  }

  // 从服务器获取用户信息
  Future<Map<String, dynamic>>? fetchProfile() async {
    try {
      Map<String, dynamic>? resp = await UserApi().getProfile();
      if (resp == null || resp["code"] != 200) {
        BotToast.showText(text: "获取模块列表失败: ${resp?["message"]}");
        return {};
      }
      LocalStorage.saveMap("profile", resp["data"]);
      return resp["data"];
    } catch (e) {
      BotToast.showText(text: "获取用户信息失败");
      return {};
    }
  }

  // 根据module动态查找对应path的下标
  int getMenuIndexByPath(String path) {
    for (int i = 0; i < AppPages.pages.length; i++) {
      var page = AppPages.pages[i];
      if (page.path == path) {
        return i;
      }
    }
    return -1;
  }

  void modulesToList(List<Module> modules) {
    for (var m in modules) {
      Global.permissions.add(m.path);
      if (m.childs != null) {
        modulesToList(m.childs!);
      }
    }
  }
}
