import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/modules/components/dialog/big_alert.dart';
import 'package:go_author_client/app/utils/local_storage.dart';

import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  Color _eyeColor = Colors.grey;
  final _textFieldFontSize = 16.0;
  final _textFieldLabelSize = 18.0;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.username.value = _usernameController.text;
    controller.password.value = _passController.text;
    controller.rememberMe.value = LocalStorage.hasKey("remember-me") ? LocalStorage.get("remember-me") : false;
    // 如果当前是需要记住我，且当前没有设置默认值的情况
    if (controller.rememberMe.value && _usernameController.text.isEmpty && _passController.text.isEmpty) {
      controller.username.value = LocalStorage.get("username").toString();
      _usernameController.text = controller.username.value;
      controller.password.value = LocalStorage.get("password").toString();
      _passController.text = controller.password.value;
    }
    return Scaffold(
      key: _formKey,
      // backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand, // 让背景图片占满整个屏幕
        children: [
          // 背景图片
          // Image.asset(
          //   "assets/images/login_bg.jpg", // 你的背景图片路径
          //   fit: BoxFit.cover, // 图片适应方式，可根据需要调整
          // ),
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 0),
            children: [
              // Image.asset(
              //   "assets/images/vector-1.png",
              //   // width: 413,
              //   // height: 457,
              // ),
              SizedBox(
                height: 18,
              ),
              Form(
                // 我们这里不自动检验，检验提示会影响输入框样式
                // autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: Column(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '登录',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 27,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: 320,
                        child: Column(
                          children: [
                            buildAccountField(context),
                            SizedBox(
                              height: 30,
                            ),
                            buildPasswordField(context),
                            SizedBox(
                              height: 25,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9F7BFF),
                                  ),
                                  child: Text(
                                    '登录',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onPressed: () {
                                    controller.onLogin();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 使元素两端对齐
                              children: [
                                InkWell(
                                  onTap: () {
                                    // 处理记住我逻辑
                                    controller.rememberMe.value = !controller.rememberMe.value;
                                  },
                                  child: Row(
                                    children: [
                                      Obx(
                                        () => Checkbox(
                                          value: controller.rememberMe.value,
                                          shape: CircleBorder(),
                                          onChanged: (bool? newValue) {
                                            controller.rememberMe.value = newValue!;
                                          },
                                        ),
                                      ),
                                      Text("记住我"),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // 同意协议逻辑
                                    controller.agreement.value = !controller.agreement.value;
                                  },
                                  child: Row(
                                    children: [
                                      Obx(
                                        () => Checkbox(
                                          value: controller.agreement.value,
                                          shape: CircleBorder(),
                                          onChanged: (bool? newValue) {
                                            controller.agreement.value = newValue!;
                                          },
                                        ),
                                      ),
                                      Text("同意协议"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Text(
                                  '还没有账号?',
                                  style: TextStyle(
                                    color: Color(0xFF837E93),
                                    fontSize: _textFieldFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: 2.5,
                                ),
                                InkWell(
                                  onTap: () {
                                    // widget.controller.animateToPage(1, duration:  Duration(milliseconds: 500), curve: Curves.ease);
                                  },
                                  child: Text(
                                    '注册',
                                    style: TextStyle(
                                      color: Color(0xFF755DC1),
                                      fontSize: _textFieldFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Text(
                                    '忘记密码?',
                                    style: TextStyle(
                                      color: Color(0xFF755DC1),
                                      fontSize: _textFieldFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    BigAlert.showConfirm(
                                      context: context,
                                      title: "警告",
                                      content: "确定要清除缓存吗?",
                                      onYesCallback: () {
                                        LocalStorage.clear();
                                        _usernameController.text = "";
                                        _passController.text = "";
                                        controller.username.value = "";
                                        controller.password.value = "";
                                        controller.rememberMe.value = false;
                                        BotToast.showText(text: "缓存清除完成");
                                      },
                                    );
                                  },
                                  child: Text(
                                    '清除缓存?',
                                    style: TextStyle(
                                      color: Color(0xFF755DC1),
                                      fontSize: _textFieldFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 36,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAccountField(BuildContext context) {
    _usernameController.addListener(() {
      controller.username.value = _usernameController.text;
    });
    return Obx(() {
      return TextFormField(
        controller: _usernameController,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _textFieldFontSize,
          fontWeight: FontWeight.w400,
        ),
        // 检验规则
        validator: (v) {
          if (v == null || v.length < 3) {
            return "长度不能小于3位";
          }
          // var reg = RegExp(r"1[3-9]\d{9}$");
          // if (!reg.hasMatch(v!)) {
          //   return '请输入合法的手机号码';
          // }
          return null;
        },
        onChanged: (value) {
          if (value.isNotEmpty) {}
        },
        decoration: InputDecoration(
          labelText: '账号',
          labelStyle: TextStyle(
            color: Color(0xFF755DC1),
            fontSize: _textFieldLabelSize,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFF837E93),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFF9F7BFF),
            ),
          ),
          // 空图标占位，保持两个输入框文本对齐
          suffixIcon: controller.username.value.isEmpty
              ? Icon(Icons.clear_sharp, color: Colors.transparent)
              : IconButton(
                  icon: Icon(Icons.clear_sharp),
                  // color: Colors.transparent,
                  onPressed: () {
                    controller.username.value = "";
                    _usernameController.text = "";
                  },
                ),
        ),
      );
    });
  }

  Widget buildPasswordField(BuildContext context) {
    _passController.addListener(() {
      controller.password.value = _passController.text;
    });
    return Obx(() {
      return TextFormField(
        controller: _passController,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _textFieldFontSize,
          fontWeight: FontWeight.w400,
        ),
        validator: (v) {
          if (v == null || v.length < 3) {
            return "长度不能小于3位";
          }
          return null;
        },
        obscureText: controller.isObscure.value, // 是否显示文字
        decoration: InputDecoration(
          labelText: '密码',
          labelStyle: TextStyle(
            color: Color(0xFF755DC1),
            fontSize: _textFieldLabelSize,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFF837E93),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFF9F7BFF),
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isObscure.value ? Icons.visibility_off : Icons.visibility,
              color: _eyeColor,
            ),
            onPressed: () {
              // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
              controller.isObscure.value = !controller.isObscure.value;
              _eyeColor = (controller.isObscure.value ? Colors.grey : Theme.of(context).iconTheme.color)!;
            },
          ),
        ),
      );
    });
  }
}
