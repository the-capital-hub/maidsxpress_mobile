class ServiceResponse {
  final String? message;
  final List<Service> data;

  ServiceResponse({
    this.message,
    required this.data,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is List
          ? List<Service>.from(json['data'].map((x) => Service.fromJson(x)))
          : [],
    );
  }
}

class Service {
  final String id;
  final String name;
  final String tag;
  final String image;
  final List<ServiceDetail> include;
  final List<ServiceDetail> exclude;
  final List<SubService> subServices;
  bool isFavorite;

  Service({
    required this.id,
    required this.name,
    required this.tag,
    required this.image,
    required this.include,
    required this.exclude,
    required this.subServices,
    this.isFavorite = false,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Service',
      tag: json['tag']?.toString() ?? 'Service',
      image: json['image']?.toString() ?? '',
      include: json['include'] != null
          ? List<ServiceDetail>.from(
              json['include'].map((x) => ServiceDetail.fromJson(x)))
          : [],
      exclude: json['exclude'] != null
          ? List<ServiceDetail>.from(
              json['exclude'].map((x) => ServiceDetail.fromJson(x)))
          : [],
      subServices: json['subServices'] != null
          ? List<SubService>.from(
              json['subServices'].map((x) => SubService.fromJson(x)))
          : [],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

class ServiceDetail {
  final String title;
  final String description;

  ServiceDetail({
    required this.title,
    required this.description,
  });

  // Getter to handle empty or whitespace titles
  String get displayTitle =>
      title.trim().isNotEmpty ? title.trim() : 'Untitled';

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class SubService {
  final String key;
  final String name;
  final List<ServiceOption> options;

  SubService({
    required this.key,
    required this.name,
    required this.options,
  });

  factory SubService.fromJson(Map<String, dynamic> json) {
    return SubService(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      options: json['options'] != null
          ? List<ServiceOption>.from(
              json['options'].map((x) => ServiceOption.fromJson(x)))
          : [],
    );
  }
}

class ServiceOption {
  final String label;
  final String value;
  final double price;

  ServiceOption({
    required this.label,
    required this.value,
    required this.price,
  });

  factory ServiceOption.fromJson(Map<String, dynamic> json) {
    return ServiceOption(
      label: json['label']?.toString().trim() ?? '',
      value: json['value']?.toString() ?? '',
      price: (json['price'] is int
              ? json['price'].toDouble()
              : json['price']?.toDouble()) ??
          0.0,
    );
  }
}
