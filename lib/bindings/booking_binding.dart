import 'package:get/get.dart';
import '../../controller/booking/bookings_controller.dart';
import '../../controller/booking/coupon_controller.dart';

class BookingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingsController>(() => BookingsController(), fenix: true);
    Get.lazyPut<CouponController>(() => CouponController(), fenix: true);
  }
}
