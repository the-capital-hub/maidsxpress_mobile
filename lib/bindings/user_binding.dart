import 'package:get/get.dart';
import 'package:maidxpress/controller/user/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
  }
}
