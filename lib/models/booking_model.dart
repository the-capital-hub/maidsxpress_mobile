import 'package:flutter/material.dart';

class BookingService {
  final String name;
  final String? image;
  final List<SelectedSubService> selectedSubServices;

  BookingService({
    required this.name,
    this.image,
    required this.selectedSubServices,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      name: json['name']?.toString() ?? 'Unnamed Service',
      image: json['image']?.toString(),
      selectedSubServices: json['selectedSubServices'] != null
          ? (json['selectedSubServices'] as List)
              .map((x) => SelectedSubService.fromJson(x))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'selectedSubServices':
          selectedSubServices.map((x) => x.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}

class SelectedSubService {
  final String key;
  final String name;
  final SelectedOption? selectedOption;

  SelectedSubService({
    required this.key,
    required this.name,
    this.selectedOption,
  });

  factory SelectedSubService.fromJson(Map<String, dynamic> json) {
    return SelectedSubService(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      selectedOption: json['selectedOption'] != null
          ? SelectedOption.fromJson(json['selectedOption'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'selectedOption': selectedOption?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}

class SelectedOption {
  final String label;
  final String value;
  final double price;

  SelectedOption({
    required this.label,
    required this.value,
    required this.price,
  });

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      price: (json['price'] is num) ? json['price'].toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'price': price,
    };
  }
}

class SelectTimeAndDate {
  final DateTime date;
  final String time;
  final String? gender;
  final String? instructions;

  const SelectTimeAndDate({
    required this.date,
    required this.time,
    this.gender,
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'time': time,
      'gender': gender,
      'instructions': instructions,
    }..removeWhere((key, value) => value == null);
  }

  factory SelectTimeAndDate.fromJson(Map<String, dynamic> json) {
    return SelectTimeAndDate(
      date: DateTime.parse(
          json['date']?.toString() ?? DateTime.now().toIso8601String()),
      time: json['time']?.toString() ?? '',
      gender: json['gender']?.toString(),
      instructions: json['instructions']?.toString(),
    );
  }

  SelectTimeAndDate copyWith({
    DateTime? date,
    String? time,
    String? gender,
    String? instructions,
  }) {
    return SelectTimeAndDate(
      date: date ?? this.date,
      time: time ?? this.time,
      gender: gender ?? this.gender,
      instructions: instructions ?? this.instructions,
    );
  }
}

class BookingOrder {
  final String orderId;
  final String paymentStatus;
  final String? transactionNumber;
  final DateTime? createdAt;

  BookingOrder({
    required this.orderId,
    required this.paymentStatus,
    this.transactionNumber,
    this.createdAt,
  });

  factory BookingOrder.fromJson(Map<String, dynamic> json) {
    return BookingOrder(
      orderId: json['orderId']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      transactionNumber: json['transactionNumber']?.toString(),
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'paymentStatus': paymentStatus,
      'transactionNumber': transactionNumber,
      'createdAt': createdAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }
}

class Booking {
  final String? id;
  final String? user;
  final String title;
  final BookingService service;
  final SelectTimeAndDate selectTimeAndDate;
  final Location location;
  final String transactionNumber;
  final String paymentStatus;
  final double amount;
  final String? bookingStatus;
  final String? progressStatus;
  final bool? isRecurring;
  final DateTime? nextPaymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<BookingOrder> orders;
  final double? discountAmount;
  final String? orderId; // Add orderId field

  Booking({
    this.id,
    this.user,
    required this.title,
    required this.service,
    required this.selectTimeAndDate,
    required this.location,
    required this.transactionNumber,
    required this.paymentStatus,
    required this.amount,
    this.bookingStatus,
    this.progressStatus,
    this.isRecurring,
    this.nextPaymentDate,
    this.createdAt,
    this.updatedAt,
    List<BookingOrder>? orders,
    this.discountAmount,
    this.orderId,
  }) : orders = orders ?? [];

  // Method to expand this booking into multiple bookings based on orders
  List<Booking> expandToOrders() {
    if (orders.isEmpty) {
      return [this];
    }
    
    return orders.map((order) {
      return Booking(
        id: id,
        user: user,
        title: title,
        service: service,
        selectTimeAndDate: selectTimeAndDate,
        location: location,
        transactionNumber: order.transactionNumber ?? transactionNumber,
        paymentStatus: order.paymentStatus,
        amount: amount,
        bookingStatus: bookingStatus,
        progressStatus: progressStatus,
        isRecurring: isRecurring,
        nextPaymentDate: nextPaymentDate,
        createdAt: order.createdAt ?? createdAt,
        updatedAt: updatedAt,
        orders: [],
        discountAmount: discountAmount,
        orderId: order.orderId,
      );
    }).toList();
  }

  factory Booking.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      final now = TimeOfDay.now();
      return Booking(
        title: 'New Booking',
        service: BookingService(
          name: 'Service',
          selectedSubServices: [],
        ),
        selectTimeAndDate: SelectTimeAndDate(
          date: DateTime.now(),
          time:
              '${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'am' : 'pm'}',
        ),
        location: Location(
          locationAddress: LocationAddress(name: 'Home', address: 'Unknown'),
          phoneNumber: '',
        ),
        transactionNumber: 'PAY_LATER',
        paymentStatus: 'pending',
        amount: 0.0,
      );
    }

    // Parse orders array
    final orders = json['orders'] is List
        ? (json['orders'] as List)
            .map((order) => BookingOrder.fromJson(
                order is Map ? Map<String, dynamic>.from(order) : {}))
            .toList()
        : <BookingOrder>[];

    return Booking(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      user: json['user']?.toString(),
      title: json['title']?.toString() ??
          json['service']?['name']?.toString() ??
          'Service',
      service: BookingService.fromJson(json['service'] is Map
          ? Map<String, dynamic>.from(json['service'])
          : {}),
      selectTimeAndDate: SelectTimeAndDate.fromJson(
          json['selectTimeAndDate'] is Map
              ? Map<String, dynamic>.from(json['selectTimeAndDate'])
              : {}),
      location: Location.fromJson(json['location'] is Map
          ? Map<String, dynamic>.from(json['location'])
          : {}),
      transactionNumber: json['transactionNumber']?.toString() ?? 'PAY_LATER',
      paymentStatus:
          (json['paymentStatus']?.toString() ?? 'pending').toLowerCase(),
      amount: (json['amount'] is num) ? json['amount'].toDouble() : 0.0,
      bookingStatus: json['bookingStatus']?.toString(),
      progressStatus: json['progressStatus']?.toString(),
      isRecurring: json['isRecurring'] == true,
      nextPaymentDate: json['nextPaymentDate'] is String
          ? DateTime.tryParse(json['nextPaymentDate'])
          : null,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      orders: orders,
      discountAmount: json['discountAmount'] is num ? json['discountAmount'].toDouble() : null,
      orderId: json['orderId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      '_id': id,
      'user': user,
      'title': title,
      'service': service.toJson(),
      'selectTimeAndDate': selectTimeAndDate.toJson(),
      'location': location.toJson(),
      'transactionNumber': transactionNumber,
      'paymentStatus': paymentStatus,
      'amount': amount,
      'bookingStatus': bookingStatus ?? 'booked',
      'progressStatus': progressStatus ?? 'upcoming',
      'isRecurring': isRecurring ?? false,
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'orders': orders.map((o) => o.toJson()).toList(),
      'discountAmount': discountAmount,
      'orderId': orderId,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }

  Booking copyWith({
    String? id,
    String? user,
    String? title,
    BookingService? service,
    SelectTimeAndDate? selectTimeAndDate,
    Location? location,
    String? transactionNumber,
    String? paymentStatus,
    double? amount,
    String? bookingStatus,
    String? progressStatus,
    bool? isRecurring,
    DateTime? nextPaymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BookingOrder>? orders,
    double? discountAmount,
    String? orderId,
  }) {
    return Booking(
      id: id ?? this.id,
      user: user ?? this.user,
      title: title ?? this.title,
      service: service ?? this.service,
      selectTimeAndDate: selectTimeAndDate ?? this.selectTimeAndDate,
      location: location ?? this.location,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amount: amount ?? this.amount,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      progressStatus: progressStatus ?? this.progressStatus,
      isRecurring: isRecurring ?? this.isRecurring,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orders: orders ?? this.orders,
      discountAmount: discountAmount ?? this.discountAmount,
      orderId: orderId ?? this.orderId,
    );
  }
}

class AllBookingsResponse {
  final BookingListData data;
  final String message;

  AllBookingsResponse({required this.data, required this.message});

  factory AllBookingsResponse.fromJson(Map<String, dynamic> json) {
    return AllBookingsResponse(
      data: BookingListData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class BookingListData {
  final BookingCategories bookings;

  BookingListData({required this.bookings});

  factory BookingListData.fromJson(Map<String, dynamic> json) {
    return BookingListData(
      bookings: BookingCategories.fromJson(json['bookings'] ?? {}),
    );
  }
}

class BookingCategories {
  final int totalBookings;
  final List<Booking> completed;
  final List<Booking> upcoming;
  final List<Booking> cancelled;

  BookingCategories({
    this.totalBookings = 0,
    List<Booking>? completed,
    List<Booking>? upcoming,
    List<Booking>? cancelled,
  })  : completed = completed ?? [],
        upcoming = upcoming ?? [],
        cancelled = cancelled ?? [];

  factory BookingCategories.fromJson(Map<String, dynamic> json) {
    return BookingCategories(
      totalBookings: json['totalBookings'] ?? 0,
      completed: (json['Completed'] as List<dynamic>? ?? [])
          .map((e) => Booking.fromJson(e))
          .toList(),
      upcoming: (json['Upcoming'] as List<dynamic>? ?? [])
          .map((e) => Booking.fromJson(e))
          .toList(),
      cancelled: (json['Cancelled'] as List<dynamic>? ?? [])
          .map((e) => Booking.fromJson(e))
          .toList(),
    );
  }
}

class BookingSummary {
  final String? id;
  final String title;
  final double amount;
  final String status;
  final String date;
  final String? imageUrl;

  BookingSummary({
    this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
    this.imageUrl,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      id: json['_id']?.toString(),
      title: json['title']?.toString() ?? 'Service',
      amount: (json['amount'] is num) ? json['amount'].toDouble() : 0.0,
      status: json['status']?.toString() ?? 'pending',
      date: json['date']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class Location {
  final LocationAddress locationAddress;
  final String phoneNumber;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  Location({
    required this.locationAddress,
    required this.phoneNumber,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Location(
        locationAddress: LocationAddress(name: 'Home', address: 'Unknown'),
        phoneNumber: '',
      );
    }

    return Location(
      locationAddress: LocationAddress.fromJson(json['locationAddress'] is Map
          ? Map<String, dynamic>.from(json['locationAddress'])
          : {}),
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      pincode: json['pincode']?.toString(),
      latitude: json['latitude'] is num ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] is num ? json['longitude'].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationAddress': locationAddress.toJson(),
      'phoneNumber': phoneNumber,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
    }..removeWhere((key, value) => value == null);
  }
}

class LocationAddress {
  final String name;
  final String address;

  LocationAddress({
    required this.name,
    required this.address,
  });

  factory LocationAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LocationAddress(
        name: 'Home',
        address: 'Unknown',
      );
    }

    return LocationAddress(
      name: json['name']?.toString() ?? 'Home',
      address: json['address']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
    };
  }
}
