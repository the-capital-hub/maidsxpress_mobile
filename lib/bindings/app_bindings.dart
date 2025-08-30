import 'package:get/get.dart';
import 'package:maidxpress/bindings/address_binding.dart';
import 'package:maidxpress/bindings/auth_binding.dart';
import 'package:maidxpress/bindings/booking_binding.dart';
import 'package:maidxpress/bindings/home_binding.dart';
import 'package:maidxpress/bindings/service_binding.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize all bindings
    AuthBinding().dependencies();
    HomeBinding().dependencies();
    AddressBinding().dependencies();
    BookingBinding().dependencies();
    ServiceBinding().dependencies();
  }
}
