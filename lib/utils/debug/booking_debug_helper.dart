import 'dart:developer' as developer;
import 'package:maidxpress/models/service_model.dart';

class BookingDebugHelper {
  static void debugBookingCreation({
    required Service service,
    required Map<String, Map<String, dynamic>> selectedOptions,
    required double calculatedTotal,
    required Map<String, dynamic> bookingDraft,
  }) {
    developer.log('=== BOOKING CREATION DEBUG START ===');
    
    // Debug Service Data
    developer.log('Service ID: ${service.id}');
    developer.log('Service Name: ${service.name}');
    developer.log('Service SubServices Count: ${service.subServices.length}');
    
    // Debug SubServices and their prices
    for (var subService in service.subServices) {
      developer.log('SubService: ${subService.name}');
      developer.log('  Key: ${subService.key}');
      developer.log('  Options Count: ${subService.options.length}');
      for (var option in subService.options) {
        developer.log('    Option: ${option.label} - Price: ${option.price}');
      }
    }
    
    // Debug Selected Options
    developer.log('Selected Options Count: ${selectedOptions.length}');
    selectedOptions.forEach((key, value) {
      developer.log('Selected Option - Key: $key');
      developer.log('  Value: ${value['value']}');
      developer.log('  Label: ${value['label']}');
      developer.log('  Price: ${value['price']}');
    });
    
    // Debug Price Calculation
    developer.log('Calculated Total: $calculatedTotal');
    
    // Debug Booking Draft
    developer.log('Booking Draft Amount: ${bookingDraft['amount']}');
    developer.log('Booking Draft Service: ${bookingDraft['service']}');
    
    // Debug Selected SubServices in Draft
    final serviceData = bookingDraft['service'] as Map<String, dynamic>?;
    if (serviceData != null) {
      final selectedSubServices = serviceData['selectedSubServices'] as List<dynamic>?;
      if (selectedSubServices != null) {
        developer.log('Selected SubServices in Draft: ${selectedSubServices.length}');
        for (var item in selectedSubServices) {
          developer.log('  Item: $item');
        }
      }
    }
    
    developer.log('=== BOOKING CREATION DEBUG END ===');
  }
  
  static void debugBookingResponse(Map<String, dynamic> response) {
    developer.log('=== BOOKING RESPONSE DEBUG START ===');
    developer.log('Response Status: ${response['status']}');
    developer.log('Response Data: ${response['data']}');
    
    if (response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      developer.log('Data Keys: ${data.keys.toList()}');
      
      if (data['booking'] != null) {
        final booking = data['booking'] as Map<String, dynamic>;
        developer.log('Booking Amount: ${booking['amount']}');
        developer.log('Booking Service: ${booking['service']}');
        
        // Debug service prices in response
        final service = booking['service'] as Map<String, dynamic>?;
        if (service != null) {
          final selectedSubServices = service['selectedSubServices'] as List<dynamic>?;
          if (selectedSubServices != null) {
            developer.log('Response Selected SubServices: ${selectedSubServices.length}');
            for (var item in selectedSubServices) {
              developer.log('  Response Item: $item');
            }
          }
        }
      }
    }
    
    developer.log('=== BOOKING RESPONSE DEBUG END ===');
  }
  
  static void debugPriceFlow({
    required Map<String, Map<String, dynamic>> selectedOptions,
    required double subtotal,
    required double tax,
    required double total,
  }) {
    developer.log('=== PRICE FLOW DEBUG START ===');
    
    developer.log('Selected Options:');
    selectedOptions.forEach((key, value) {
      developer.log('  $key: ${value['price']}');
    });
    
    developer.log('Subtotal: $subtotal');
    developer.log('Tax (18%): $tax');
    developer.log('Total: $total');
    
    developer.log('=== PRICE FLOW DEBUG END ===');
  }
}
