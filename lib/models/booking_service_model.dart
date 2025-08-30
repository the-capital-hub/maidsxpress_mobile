import 'package:maidxpress/models/service_model.dart' as service_models;

class BookingService {
  final String id;
  final String name;
  final String tag;
  final String image;
  final List<service_models.ServiceDetail> include;
  final List<service_models.ServiceDetail> exclude;
  final List<service_models.SubService> subServices;
  bool isFavorite;
  final List<service_models.SubService> selectedSubServices;

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

  factory BookingService.fromService(service_models.Service service, 
      {List<service_models.SubService>? selectedSubServices}) {
    return BookingService(
      id: service.id,
      name: service.name,
      tag: service.tag,
      image: service.image,
      include: service.include,
      exclude: service.exclude,
      subServices: service.subServices,
      selectedSubServices: selectedSubServices ?? [],
      isFavorite: service.isFavorite,
    );
  }

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Service',
      tag: json['tag']?.toString() ?? 'Service',
      image: json['image']?.toString() ?? '',
      include: json['include'] != null
          ? (json['include'] as List)
              .map((x) => service_models.ServiceDetail.fromJson(x))
              .toList()
          : [],
      exclude: json['exclude'] != null
          ? (json['exclude'] as List)
              .map((x) => service_models.ServiceDetail.fromJson(x))
              .toList()
          : [],
      subServices: json['subServices'] != null
          ? (json['subServices'] as List)
              .map((x) => service_models.SubService.fromJson(x))
              .toList()
          : [],
      selectedSubServices: json['selectedSubServices'] != null
          ? (json['selectedSubServices'] as List).map((x) {
              if (x is Map<String, dynamic>) {
                // Handle the case where selectedSubServices is already a list of maps
                return service_models.SubService(
                  key: x['key']?.toString() ?? '',
                  name: x['name']?.toString() ?? '',
                  options: x['options'] != null 
                      ? (x['options'] as List).map((o) => service_models.ServiceOption.fromJson(o)).toList()
                      : [],
                  isSelected: true,
                );
              } else {
                // Fallback to regular parsing if format is different
                return service_models.SubService.fromJson(x);
              }
            }).toList()
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
      'include': include.map((x) => x.toJson()).toList(),
      'exclude': exclude.map((x) => x.toJson()).toList(),
      'subServices': subServices.map((x) => x.toJson()).toList(),
      'selectedSubServices': selectedSubServices.map((x) => x.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }
}
