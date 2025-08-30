import 'package:get/get.dart';
import '../../controller/booking/bookings_controller.dart';

class BookingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingsController>(() => BookingsController(), fenix: true);
  }
}
