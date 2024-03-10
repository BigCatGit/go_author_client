import 'package:event_bus/event_bus.dart';
import 'package:go_author_client/app/models/module.dart';

class Global {
  static final List<Module> modules = [];
  // 权限url列表
  static final Set<String> permissions = {};
  // 初始化事件
  static final EventBus eventBus = EventBus();
}
