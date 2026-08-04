// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Restro Hub';

  @override
  String get findYourFavorite => 'Find Your Favorite';

  @override
  String get searchHint => 'Search restaurants or cuisines...';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get cuisines => 'Cuisines';

  @override
  String get recommended => 'Recommended';

  @override
  String get all => 'All';

  @override
  String get topRated => 'Top Rated';

  @override
  String get fastDelivery => 'Fast Delivery';

  @override
  String get costEffective => 'Cost Effective';

  @override
  String get premium => 'Premium';

  @override
  String get viewCart => 'VIEW CART';

  @override
  String get restaurant => 'RESTAURANT';

  @override
  String get food => 'FOOD';

  @override
  String get searchRestaurants => 'Search restaurants...';

  @override
  String get searchCuisines => 'Search cuisines...';

  @override
  String get searchRecommended => 'Search recommended...';

  @override
  String addedToCart(String name) {
    return '$name added to cart';
  }

  @override
  String get myOrders => 'My Orders';

  @override
  String get inProgress => 'In Progress';

  @override
  String get success => 'Success';

  @override
  String get cancelled => 'Cancelled';

  @override
  String noOrdersFound(String status) {
    return 'No $status orders found';
  }

  @override
  String orderId(String id) {
    return 'Order #$id';
  }

  @override
  String get deliveredSuccessfully => 'Delivered successfully';

  @override
  String get cancelledOrder => 'Order Cancelled';

  @override
  String get refunded => 'Refunded';

  @override
  String get reorder => 'Reorder';

  @override
  String get viewDetails => 'View Details';

  @override
  String get trackOrder => 'Track Order';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get minOrder => 'Min Order';

  @override
  String get deliveryTime => 'Delivers in';

  @override
  String get reviews => 'Reviews';

  @override
  String get writeAReview => 'Write a review';

  @override
  String get shareExperience => 'Share your experience';

  @override
  String get rating => 'Rating';

  @override
  String get comment => 'Comment';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get menu => 'Menu';

  @override
  String get about => 'About';

  @override
  String get searchMenu => 'Search menu...';
}
