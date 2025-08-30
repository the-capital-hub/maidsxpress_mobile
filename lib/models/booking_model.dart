class Booking {
  final String? id;
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

  Booking({
    this.id,
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
  });

  factory Booking.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Booking(
        title: 'New Booking',
        service: BookingService(
          id: '',
          name: 'Service',
          tag: 'service',
          image: '',
          include: [],
          exclude: [],
          subServices: [],
          selectedSubServices: [],
          isFavorite: false,
        ),
        selectTimeAndDate: SelectTimeAndDate(date: '', time: ''),
        location: Location(
          locationAddress: LocationAddress(name: 'Home', address: 'Unknown'),
          phoneNumber: null,
          pincode: null,
          latitude: null,
          longitude: null,
        ),
        transactionNumber: 'PAY_LATER',
        paymentStatus: 'pending',
        amount: 0.0,
      );
    }

    // Safely parse service
    BookingService service;
    try {
      if (json["service"] is String) {
        service = BookingService(
          id: '',
          name: json["service"].toString(),
          tag: 'service',
          image: '',
          include: [],
          exclude: [],
          subServices: [],
          selectedSubServices: [],
          isFavorite: false,
        );
      } else {
        service = BookingService.fromJson(json["service"] is Map
            ? Map<String, dynamic>.from(json["service"])
            : {});
      }
    } catch (e) {
      service = BookingService(
        id: '',
        name: 'Service',
        tag: 'service',
        image: '',
        include: [],
        exclude: [],
        subServices: [],
        selectedSubServices: [],
        isFavorite: false,
      );
    }

    // Safely parse selectTimeAndDate
    SelectTimeAndDate timeAndDate;
    try {
      if (json["selectTimeAndDate"] is String) {
        timeAndDate = SelectTimeAndDate(
          date: json["selectTimeAndDate"].toString(),
          time: '',
        );
      } else {
        timeAndDate = SelectTimeAndDate.fromJson(
            json["selectTimeAndDate"] is Map
                ? Map<String, dynamic>.from(json["selectTimeAndDate"])
                : {});
      }
    } catch (e) {
      timeAndDate = SelectTimeAndDate(date: '', time: '');
    }

    // Safely parse location
    Location location;
    try {
      location = Location.fromJson(json["location"] is Map
          ? Map<String, dynamic>.from(json["location"])
          : {});
    } catch (e) {
      location = Location(
        locationAddress: LocationAddress(name: 'Home', address: 'Unknown'),
        phoneNumber: null,
        pincode: null,
        latitude: null,
        longitude: null,
      );
    }

    // Parse other fields with null safety
    return Booking(
      id: json["_id"]?.toString() ?? json["id"]?.toString(),
      title: json["title"]?.toString() ??
          json["service"]?["name"]?.toString() ??
          "Service",
      service: service,
      selectTimeAndDate: timeAndDate,
      location: location,
      transactionNumber: json["transactionNumber"]?.toString() ?? "PAY_LATER",
      paymentStatus:
          (json["paymentStatus"]?.toString() ?? "pending").toLowerCase(),
      amount:
          (json["amount"] is num) ? (json["amount"] as num).toDouble() : 0.0,
      bookingStatus: json["bookingStatus"]?.toString(),
      progressStatus: json["progressStatus"]?.toString(),
      isRecurring: json["isRecurring"] == true,
      nextPaymentDate: json["nextPaymentDate"] is String
          ? DateTime.tryParse(json["nextPaymentDate"])
          : null,
      createdAt: json["createdAt"] is String
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] is String
          ? DateTime.tryParse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "service": service.toJson(),
      "selectTimeAndDate": selectTimeAndDate.toJson(),
      "location": location.toJson(),
      "transactionNumber": transactionNumber,
      "paymentStatus": paymentStatus,
      "amount": amount,
      "bookingStatus": bookingStatus,
      "progressStatus": progressStatus,
      "isRecurring": isRecurring,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
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
      id: json['_id'],
      title: json['title'] ?? 'Service',
      amount: (json['amount'] is num ? json['amount'].toDouble() : 0.0),
      status: json['status'] ?? 'pending',
      date: json['date'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class BookingService {
  final String id;
  final String name;
  final String tag;
  final String image;
  final List<Map<String, dynamic>> include;
  final List<Map<String, dynamic>> exclude;
  final List<Map<String, dynamic>> subServices;
  bool isFavorite;
  final List<Map<String, dynamic>> selectedSubServices;

  BookingService({
    required this.id,
    required this.name,
    required this.tag,
    required this.image,
    required this.include,
    required this.exclude,
    required this.subServices,
    required this.selectedSubServices,
    this.isFavorite = false,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Service',
      tag: json['tag']?.toString() ?? 'Service',
      image: json['image']?.toString() ?? '',
      include: json['include'] != null
          ? List<Map<String, dynamic>>.from(json['include'])
          : [],
      exclude: json['exclude'] != null
          ? List<Map<String, dynamic>>.from(json['exclude'])
          : [],
      subServices: json['subServices'] != null
          ? List<Map<String, dynamic>>.from(json['subServices'])
          : [],
      selectedSubServices: json['selectedSubServices'] != null
          ? List<Map<String, dynamic>>.from(json['selectedSubServices'])
          : [],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'image': image,
      'include': include,
      'exclude': exclude,
      'subServices': subServices,
      'selectedSubServices': selectedSubServices,
      'isFavorite': isFavorite,
    };
  }
}

class SelectTimeAndDate {
  final String date;
  final String time;
  final String? gender;
  final String? instructions;

  SelectTimeAndDate({
    required this.date,
    required this.time,
    this.gender,
    this.instructions,
  });

  factory SelectTimeAndDate.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SelectTimeAndDate(
        date: '',
        time: '',
      );
    }

    return SelectTimeAndDate(
      date: json["date"]?.toString() ?? "",
      time: json["time"]?.toString() ?? "",
      gender: json["gender"]?.toString(),
      instructions: json["instructions"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "time": time,
      if (gender != null) "gender": gender,
      if (instructions != null) "instructions": instructions,
    };
  }
}

class Location {
  final LocationAddress? locationAddress;
  final String? phoneNumber;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  Location({
    this.locationAddress,
    this.phoneNumber,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Location(
        locationAddress: null,
        phoneNumber: null,
        pincode: null,
        latitude: null,
        longitude: null,
      );
    }

    return Location(
      locationAddress: json["locationAddress"] is Map<String, dynamic>
          ? LocationAddress.fromJson(
              Map<String, dynamic>.from(json["locationAddress"]))
          : null,
      phoneNumber: json["phoneNumber"]?.toString(),
      pincode: json["pincode"]?.toString(),
      latitude: json["latitude"] is num ? json["latitude"].toDouble() : null,
      longitude: json["longitude"] is num ? json["longitude"].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "locationAddress": locationAddress?.toJson(),
      "phoneNumber": phoneNumber,
      "pincode": pincode,
      "latitude": latitude,
      "longitude": longitude,
    };
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
        name: "Home",
        address: "Unknown Address",
      );
    }

    return LocationAddress(
      name: json["name"]?.toString() ?? "Home",
      address: json["address"]?.toString() ?? "Unknown Address",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
    };
  }
}
