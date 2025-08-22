import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<void> checkLocationPermission() async {
    LocationPermission permission;

    // Check if permission is already granted
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied again, show dialog or error
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, open app settings
      await Geolocator.openAppSettings();
      throw Exception("Location permission permanently denied");
    }
  }
}
