import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/features/country/data/models/country_model.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';

final List<CountryModel> countries = [
  const CountryModel(
    name: 'Italy',
    flag: '🇮🇹',
    image: 'assets/italy.webp',
    historicalImage:
        'https://images.unsplash.com/photo-1552832230-c0197dd311b5?q=80&w=1000&auto=format&fit=crop',
  ),
  const CountryModel(
    name: 'China',
    flag: '🇨🇳',
    image: 'assets/china.webp',
    historicalImage:
        'https://images.unsplash.com/photo-1547981609-4b6bfe67ca0b?q=80&w=1000&auto=format&fit=crop',
  ),
  // ... rest of countries can be added back if needed, but keeping it small for now
];

final List<MenuItemModel> mockMenuItems = [
  const MenuItemModel(
    id: 'item1',
    categoryId: 'cat1',
    name: 'Spaghetti Carbonara',
    description: 'Authentic Italian pasta with homemade sauce and fresh herbs.',
    price: 450,
    imageUrl: 'assets/food1.webp',
    dietaryFlags: ['non-vegetarian'],
  ),
  const MenuItemModel(
    id: 'item2',
    categoryId: 'cat1',
    name: 'Margherita Pizza',
    description:
        'Traditional thin-crust pizza with fresh basil and mozzarella.',
    price: 550,
    imageUrl: 'assets/food1.webp',
    dietaryFlags: ['vegetarian'],
  ),
];

final List<MenuCategoryModel> mockCategories = [
  const MenuCategoryModel(
    id: 'cat1',
    restaurantId: 'rest1',
    name: 'Italian Classics',
    items: [
      MenuItemModel(
        id: 'item1',
        categoryId: 'cat1',
        name: 'Spaghetti Carbonara',
        description:
            'Authentic Italian pasta with homemade sauce and fresh herbs.',
        price: 450,
        imageUrl: 'assets/food1.webp',
        dietaryFlags: ['non-vegetarian'],
      ),
      MenuItemModel(
        id: 'item2',
        categoryId: 'cat1',
        name: 'Margherita Pizza',
        description:
            'Traditional thin-crust pizza with fresh basil and mozzarella.',
        price: 550,
        imageUrl: 'assets/food1.webp',
        dietaryFlags: ['vegetarian'],
      ),
    ],
  ),
];

final List<RestaurantModel> restaurantsList = [
  RestaurantModel(
    id: 'rest1',
    name: 'RoadSide Cafe',
    description: 'Friendly neighborhood cafe with great coffee and snacks.',
    logoUrl: 'assets/food1.webp',
    bannerUrl: 'assets/food1.webp',
    rating: 4.8, // Increased for filtering
    status: RestaurantStatus.open,
    locationAddress: 'Sajha Chowk, Kathmandu', // Added Kathmandu
    categories: mockCategories,
  ),
  RestaurantModel(
    id: 'rest2',
    name: 'Italian Bistro',
    description: 'Authentic Italian flavors in the heart of the city.',
    logoUrl: 'assets/food1.webp',
    bannerUrl: 'assets/food1.webp',
    rating: 4.6,
    status: RestaurantStatus.open,
    locationAddress: 'New Road, Kathmandu',
    categories: mockCategories,
  ),
];

final List<RestaurantModel> exploreRestaurants = restaurantsList;
final List<MenuItemModel> topRated = mockMenuItems;
final List<MenuItemModel> latestOffers = mockMenuItems;
final List<MenuItemModel> cuisines = mockMenuItems; // keeping name for compat
