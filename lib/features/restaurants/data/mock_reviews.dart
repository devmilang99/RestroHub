import 'package:restro_hub/features/restaurants/data/models/review_model.dart';

final List<ReviewModel> mockReviews = [
  const ReviewModel(
    name: 'Alex Rivera',
    rating: 5,
    time: '2 days ago',
    comment:
        'The food was absolutely delicious! Especially the pasta was so creamy and flavorful. Must try for everyone.',
    images: [
      'https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=2070&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
    ],
  ),
  const ReviewModel(
    name: 'Mia Thompson',
    rating: 4,
    time: '5 days ago',
    comment:
        'Great service and ambiance. The pizza was fresh and hot, exactly how I like it. Will come back for sure!',
    images: [],
  ),
  const ReviewModel(
    name: 'James Wilson',
    rating: 4.5,
    time: '1 week ago',
    comment:
        'Amazing place for family dinner. The dessert menu is a must-try! Highly recommended for weekend vibes.',
    images: [],
  ),
];
