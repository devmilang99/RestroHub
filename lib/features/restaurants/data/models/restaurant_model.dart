import 'package:equatable/equatable.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';

/// Restaurant Model representing a dining establishment.
class RestaurantModel extends Equatable {
  final String? id;
  final String? ownerId;
  final String name;
  final String description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? phone;
  final String? email;
  final RestaurantStatus status;
  final double rating;
  final String priceRange;
  final double taxPercent;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final List<MenuCategoryModel> categories;

  const RestaurantModel({
    required this.name,
    required this.description,
    this.id,
    this.ownerId,
    this.logoUrl,
    this.bannerUrl,
    this.phone,
    this.email,
    this.status = RestaurantStatus.closed,
    this.rating = 0.0,
    this.priceRange = r'$$',
    this.taxPercent = 0.0,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.categories = const [],
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: (json['id'] ?? json['restaurant_id'])?.toString(),
      ownerId: (json['owner_id'] ?? json['ownerId'])?.toString(),
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      logoUrl: (json['logo_url'] ?? json['logoUrl']) as String?,
      bannerUrl: (json['banner_url'] ?? json['bannerUrl']) as String?,
      phone: (json['phone'] ?? json['phoneNumber']) as String?,
      email: json['email'] as String?,
      status: RestaurantStatus.fromString(
        (json['status'] ?? 'closed').toString(),
      ),
      rating: ((json['rating'] ?? 0.0) as num).toDouble(),
      priceRange: (json['price_range'] ?? json['priceRange'] ?? r'$$')
          .toString(),
      taxPercent: ((json['tax_percent'] ?? json['taxPercent'] ?? 0.0) as num)
          .toDouble(),
      locationAddress: (json['location_address'] ?? json['address']) as String?,
      latitude: ((json['latitude'] ?? json['lat']) as num?)?.toDouble(),
      longitude: ((json['longitude'] ?? json['lng']) as num?)?.toDouble(),
      categories: json['menu_categories'] != null
          ? (json['menu_categories'] as List)
                .map(
                  (i) => MenuCategoryModel.fromJson(i as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'phone': phone,
      'email': email,
      'status': status.toSnakeCase(),
      'rating': rating,
      'price_range': priceRange,
      'tax_percent': taxPercent,
      'location_address': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    description,
    logoUrl,
    bannerUrl,
    phone,
    email,
    status,
    rating,
    priceRange,
    taxPercent,
    locationAddress,
    latitude,
    longitude,
    categories,
  ];
}
