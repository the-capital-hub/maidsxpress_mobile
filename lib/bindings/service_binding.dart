import 'package:get/get.dart';
import '../../controller/service/service_controller.dart' show ServicesController;

class ServiceBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicesController>(() => ServicesController(), fenix: true);
  }
}
