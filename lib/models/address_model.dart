class Address {
  final String id;
  final String label;
  final String address;
  final String phone;
  final String pincode;
  final bool isServiceable;
  final String user;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.label,
    required this.address,
    required this.phone,
    required this.pincode,
    required this.isServiceable,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json["_id"],
      label: json["label"],
      address: json["address"],
      phone: json["phone"],
      pincode: json["pincode"],
      isServiceable: json["isServiceable"] ?? false,
      user: json["user"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "label": label,
      "address": address,
      "phone": phone,
      "pincode": pincode,
      "isServiceable": isServiceable,
      "user": user,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class AddressResponse {
  final bool status;
  final String message;
  final int totalAddresses;
  final List<Address> addresses;

  AddressResponse({
    required this.status,
    required this.message,
    required this.totalAddresses,
    required this.addresses,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      status: json["status"],
      message: json["message"],
      totalAddresses: json["data"]["totalAddresses"],
      addresses: (json["data"]["addresses"] as List)
          .map((e) => Address.fromJson(e))
          .toList(),
    );
  }
}
