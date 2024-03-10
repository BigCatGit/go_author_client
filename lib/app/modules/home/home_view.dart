import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/consts/global.dart';
import 'package:go_author_client/app/models/big_notification.dart';
import 'package:go_author_client/app/models/module.dart';
import 'package:go_author_client/app/modules/components/dialog/big_alert.dart';
import 'package:go_author_client/app/routes/app_pages.dart';
import 'package:go_author_client/app/utils/local_storage.dart';

import 'home_controller.dart';

// 登录过后的主框架页面

class HomeView extends GetView<HomeController> {
  late BuildContext context;

  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      // 必须显示标题栏，才能显示抽屉菜单
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.refresh),
      //       onPressed: () {},
      //     )
      //   ],
      // ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("测试"),
            ),
          ],
        ),
        // FutureBuilder<List<Module>>(
        //   future: controller.fetchData(),
        // ),
      ),
      body: Row(
        children: [
          // 左侧菜单
          Obx(
            () => SizedBox(
              width: controller.leftMenuWidth.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 36, 36, 36), // 设置背景颜色
                  // borderRadius: BorderRadius.circular(10), // 设置圆角
                ),
                child: buildMenu(),
              ),
            ),
          ),

          // 垂直分割线
          // VerticalDivider(
          //   // color: Colors.grey,
          //   thickness: 1,
          //   endIndent: 0,
          //   width: 20,
          // ),

          // 可滚动内容
          Expanded(
            child: Container(
              // decoration: BoxDecoration(
              // color: Color.fromARGB(255, 36, 36, 36),
              // // borderRadius: BorderRadius.circular(15.0),
              // ),
              padding: EdgeInsets.all(0.0),
              child: PageView.builder(
                controller: controller.pageController,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return AppPages.pages[index].page;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder<Map<String, dynamic>> buildProfileView() {
    return FutureBuilder(
      future: controller.fetchProfile(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 加载中的UI
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // 错误时的UI
        } else {
          Map<String, dynamic> profile = snapshot.data!;
          if (profile.isEmpty) {
            profile["nickname"] = "请求失败";
            profile["email"] = "请求失败";
          }
          Global.eventBus.fire(BigNotification(id: "profile", msg: profile));
          // 抽屉头部
          return UserAccountsDrawerHeader(
            // margin: EdgeInsets.only(right: 16.0), // 设置右侧空白
            accountName: Text(profile["nickname"]),
            accountEmail: Text(profile["email"]),
            // 头像图标
            currentAccountPicture: CircleAvatar(
              foregroundImage: AssetImage("assets/images/avatar.png"),
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              // 背景图片
              // image: DecorationImage(
              //   image: AssetImage("assets/images/vector-3.png"),
              //   fit: BoxFit.cover,
              // ),
            ),
            otherAccountsPictures: <Widget>[
              Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () async {
                        // 退出登录
                        if (!await BigAlert.showConfirm(context: context, title: "警告", content: "确定要退出登录吗?")) {
                          return;
                        }
                        LocalStorage.remove("x-token");
                        Get.offAllNamed(Routes.LOGIN);
                      },
                      icon: Icon(
                        Icons.exit_to_app,
                        size: 24.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            onDetailsPressed: () {
              BotToast.showText(text: "点击详情");
            },
          );
        }
      }),
    );
  }

  bool isSingleNode(Module module) {
    if (module.childs == null) {
      return true;
    }
    for (var m in module.childs!) {
      if (!m.hidden) {
        return false;
      }
    }
    return true;
  }

  // index为不可展开的菜单项的累计下标
  Widget buildMenuItem(Module module, int level) {
    if (isSingleNode(module)) {
      // module.index = index;
      return Obx(() {
        return ListTile(
          // leading: CircleAvatar(
          //   backgroundColor: Colors.transparent,
          //   child: Icon(Icons.menu),
          // ),
          // leading: Icon(Icons.menu),
          // title: Text(module.name),
          selected: module.id == controller.selectedModule.value.id,
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(level * 8.0, 0, 0, 0),
                // flutter暂时无法通过图标名称来获取IconData
                child: Icon(module.name == "仪表盘" ? Icons.dashboard : Icons.view_module),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(module.name),
              ),
            ],
          ),
          // contentPadding: EdgeInsets.symmetric(horizontal: module.name == "仪表盘" ? 8.0 : 16.0), // 调整水平间距
          onTap: () {
            // 处理 ListTile 的点击事件
            controller.selectedModule.value = module;
            // 根据module动态查找对应path的下标
            var index = controller.getMenuIndexByPath(module.path);
            if (index >= 0) {
              controller.pageController.jumpToPage(index);
            }
          },
        );
      });
    } else {
      return ExpansionTile(
        // leading: CircleAvatar(
        //   backgroundColor: Colors.transparent,
        //   child: Icon(Icons.menu),
        // ),
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(level * 8.0, 0, 0, 0),
              // flutter暂时无法通过图标名称来获取IconData
              child: Icon(Icons.view_list),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(module.name),
            ),
          ],
        ),
        onExpansionChanged: (bool expanded) {},
        // 控制是否展开的属性
        initiallyExpanded: false,
        children: module.childs!.map((child) {
          return buildMenuItem(child, level + 1);
        }).toList(),
      );
    }
  }

  FutureBuilder<List<Module>> buildMenu() {
    return FutureBuilder<List<Module>>(
      future: controller.fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 加载中的UI
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}"); // 错误时的UI
        } else {
          List<Module> modules = snapshot.data!;
          return ListView.builder(
            itemCount: modules.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return buildProfileView();
              }
              var module = modules[index - 1];
              return buildMenuItem(module, 0);
            },
          );
        }
      },
    );
  }
}
