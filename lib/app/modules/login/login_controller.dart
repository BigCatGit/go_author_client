import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:go_author_client/app/api/user_api.dart';
import 'package:go_author_client/app/routes/app_pages.dart';
import 'package:go_author_client/app/utils/local_storage.dart';
import 'package:go_author_client/window_size_service.dart';

class LoginController extends GetxController {
  final RxBool rememberMe = RxBool(true);
  final RxBool agreement = RxBool(true);
  final RxBool isObscure = RxBool(true);
  RxString username = RxString("");
  RxString password = RxString("");

  @override
  void onInit() {
    super.onInit();
    WindowSizeService.instance.setWindowSize();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> onLogin() async {
    try {
      // 只要勾选了记住我，不管有没有填登录信息都要保存，以便包含清空的场景
      if (rememberMe.value) {
        LocalStorage.set("username", username.value);
        LocalStorage.set("password", password.value);
        LocalStorage.set("remember-me", rememberMe.value);
      }
      Get.log("账号: ${username.value}, 密码: ${password.value}");
      if (username.isEmpty || password.isEmpty) {
        BotToast.showText(text: "请输入用户名和密码");
        return;
      }
      Map<String, dynamic>? resp = await UserApi().login(username.value, password.value);
      if (resp == null) {
        BotToast.showText(text: "登录失败");
        return;
      }
      if (resp["code"] != 200 && resp["message"] != null) {
        BotToast.showText(text: resp["message"]);
        return;
      }
      LocalStorage.set("x-token", resp["data"]["token"]);
      BotToast.showText(text: "登录成功");
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      BotToast.showText(text: "登录失败, 请求失败");
      return;
    }
  }
}
