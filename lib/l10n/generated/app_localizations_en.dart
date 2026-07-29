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
  String get all => 'All';

  @override
  String get topRated => 'Top Rated';

  @override
  String get fastDelivery => 'Fast Delivery';

  @override
  String get costEffective => 'Cost Effective';

  @override
  String get premium => 'Premium';
}
