import 'package:get/get.dart';
import '../../controller/address/address_controller.dart';

class AddressBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
  }
}
