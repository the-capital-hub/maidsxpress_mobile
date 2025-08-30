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

  Service copyWith({
    String? id,
    String? name,
    String? tag,
    String? image,
    List<ServiceDetail>? include,
    List<ServiceDetail>? exclude,
    List<SubService>? subServices,
    bool? isFavorite,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      image: image ?? this.image,
      include: include ?? List<ServiceDetail>.from(this.include),
      exclude: exclude ?? List<ServiceDetail>.from(this.exclude),
      subServices: subServices ?? List<SubService>.from(this.subServices),
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ServiceDetail {
  final String description;

  ServiceDetail({
    required this.description,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
    };
  }
}

class SubService {
  final String key;
  final String name;
  final List<ServiceOption> options;
  final ServiceOption? selectedOption;
  final bool isSelected;

  SubService({
    required this.key,
    required this.name,
    required this.options,
    this.selectedOption,
    this.isSelected = false,
  });

  SubService copyWith({
    String? key,
    String? name,
    List<ServiceOption>? options,
    ServiceOption? selectedOption,
    bool? isSelected,
  }) {
    return SubService(
      key: key ?? this.key,
      name: name ?? this.name,
      options: options ?? this.options,
      selectedOption: selectedOption ?? this.selectedOption,
      isSelected: isSelected ?? this.isSelected,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'options': options.map((x) => x.toJson()).toList(),
      'isSelected': isSelected,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'price': price,
    };
  }
}
