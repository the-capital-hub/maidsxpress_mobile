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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      city: json['city'],
      address: json['address'],
      gender: json['gender'],
      profilePicture: json['profilePicture'],
      token: json['token'],
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
    };
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
