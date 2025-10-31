class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? city;
  final String? address;
  final String? gender;
  final String? profilePicture;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.city,
    this.address,
    this.gender,
    this.profilePicture,
    this.token,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      token: json['token']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'address': address,
      'gender': gender,
      'profilePicture': profilePicture,
      'token': token,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? address,
    String? gender,
    String? profilePicture,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      profilePicture: profilePicture ?? this.profilePicture,
      token: token ?? this.token,
    );
  }
}
