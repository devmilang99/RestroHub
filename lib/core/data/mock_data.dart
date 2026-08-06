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
];

final List<MenuItemModel> mockMenuItems = [
  const MenuItemModel(
    id: 'item1',
    categoryId: 'cat1',
    name: 'Spaghetti Carbonara',
    description: 'Authentic Italian pasta with homemade sauce and fresh herbs.',
    price: 450,
    imageUrl:
        'https://images.unsplash.com/photo-1612874742237-6526221588e3?q=80&w=1000&auto=format&fit=crop',
    dietaryFlags: ['non-vegetarian'],
    rating: 4.8,
  ),
  const MenuItemModel(
    id: 'item2',
    categoryId: 'cat1',
    name: 'Margherita Pizza',
    description:
        'Traditional thin-crust pizza with fresh basil and mozzarella.',
    price: 550,
    imageUrl:
        'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=1000&auto=format&fit=crop',
    dietaryFlags: ['vegetarian'],
    rating: 4.7,
  ),
  const MenuItemModel(
    id: 'item3',
    categoryId: 'cat2',
    name: 'Classic Cheeseburger',
    description: 'Juicy beef patty with melted cheese, lettuce, and tomato.',
    price: 350,
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1000&auto=format&fit=crop',
    dietaryFlags: ['non-vegetarian'],
    rating: 4.5,
  ),
];

final List<MenuCategoryModel> mockCategories = [
  MenuCategoryModel(
    id: 'cat1',
    restaurantId: 'rest1',
    name: 'Italian Classics',
    items: [mockMenuItems[0], mockMenuItems[1]],
  ),
  MenuCategoryModel(
    id: 'cat2',
    restaurantId: 'rest1',
    name: 'Burgers & Sides',
    items: [mockMenuItems[2]],
  ),
];

final List<RestaurantModel> restaurantsList = [
  RestaurantModel(
    id: 'rest1',
    name: 'RoadSide Cafe',
    description: 'Friendly neighborhood cafe with great coffee and snacks.',
    logoUrl:
        'https://images.unsplash.com/photo-1517248135467-4c7ed9d42c77?q=80&w=1000&auto=format&fit=crop',
    bannerUrl:
        'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=1000&auto=format&fit=crop',
    rating: 4.8,
    status: RestaurantStatus.open,
    locationAddress: 'Sajha Chowk, Kathmandu',
    categories: mockCategories,
  ),
  RestaurantModel(
    id: 'rest2',
    name: 'Italian Bistro',
    description: 'Authentic Italian flavors in the heart of the city.',
    logoUrl:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1000&auto=format&fit=crop',
    bannerUrl:
        'https://images.unsplash.com/photo-1517248135467-4c7ed9d42c77?q=80&w=1000&auto=format&fit=crop',
    rating: 4.6,
    status: RestaurantStatus.open,
    locationAddress: 'New Road, Kathmandu',
    categories: mockCategories,
  ),
];

final List<RestaurantModel> exploreRestaurants = restaurantsList;
final List<MenuItemModel> topRated = mockMenuItems;
final List<MenuItemModel> latestOffers = mockMenuItems;
final List<MenuItemModel> cuisines = mockMenuItems;
