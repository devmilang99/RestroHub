/// User roles for authorization and access control.
enum UserRole {
  customer,
  restaurantOwner,
  deliveryPartner,
  admin
  ;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => UserRole.customer,
    );
  }

  String toSnakeCase() => _toSnakeCase(name);
}

/// Types of exploration modes for the unified explore screen.
enum ExploreType { restaurant, food, recommended }

/// Statuses for the order lifecycle.
enum OrderStatus {
  pending,
  accepted,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled
  ;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String toSnakeCase() => _toSnakeCase(name);
}

/// Payment processing statuses.
enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded
  ;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => PaymentStatus.pending,
    );
  }

  String toSnakeCase() => _toSnakeCase(name);
}

/// Operational status of a restaurant.
enum RestaurantStatus {
  open,
  closed,
  busy
  ;

  static RestaurantStatus fromString(String value) {
    return RestaurantStatus.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => RestaurantStatus.closed,
    );
  }

  String toSnakeCase() => _toSnakeCase(name);
}

/// Image types for standardization and pre-caching.
enum AppImageType { banner, thumbnail, menuItem, cuisine, profile, custom }

/// Helper to convert camelCase to snake_case for DB compatibility.
String _toSnakeCase(String text) {
  final exp = RegExp('(?<=[a-z])[A-Z]');
  return text.replaceAllMapped(exp, (m) => '_${m.group(0)}').toLowerCase();
}
