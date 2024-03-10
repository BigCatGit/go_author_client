import 'package:get/get.dart';
import 'package:go_author_client/window_size_service.dart';

class LoadingController extends GetxController {
  final RxBool isLoading = true.obs; // 用于表示是否正在加载数据

  final count = 0.obs;
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

  void increment() => count.value++;
}
