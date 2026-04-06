class CategoryModel {
  final String image;
  final String title;

  CategoryModel({required this.image, required this.title});
}

class ProductModel {
  final String? id;
  final String? restaurantId;
  final String image;
  final String title;
  final String price;
  final String rate;
  final String rateCount;
  final String? restaurantName;
  final String? description;

  ProductModel({
    this.id,
    this.restaurantId,
    required this.image,
    required this.title,
    required this.price,
    required this.rate,
    required this.rateCount,
    this.restaurantName,
    this.description,
  });

  factory ProductModel.fromMap(
    Map<String, dynamic> map, {
    String? resName,
    String? resId,
  }) {
    return ProductModel(
      id: map['_id']?.toString() ?? map['id']?.toString(),
      restaurantId: resId ?? map['restaurantId']?.toString(),
      title: map['name'] ?? '',
      image:
          map['image_url'] ??
          (map['image'] != null
              ? map['image']['url']
              : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500'),
      price: map['price']?.toString() ?? '0.00',
      rate: map['rating']?.toString() ?? '5.0',
      rateCount: map['reviewCount']?.toString() ?? '0',
      restaurantName: resName ?? map['restaurantName'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': title,
      'image_url': image,
      'price': price,
      'rating': rate,
      'reviewCount': rateCount,
      'restaurantName': restaurantName,
      'description': description,
    };
  }
}

class RestaurantModel {
  final String id;
  final String name;
  final String image; // URL
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final String address;
  final List<ProductModel> currentOffers;
  final List<String> reviews; // Simple list of reviews for now

  RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.currentOffers,
    required this.reviews,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    final name = map['name'] ?? 'Unknown Restaurant';
    final resId = map['_id'] ?? '';
    final menu = (map['menu'] as List? ?? []);
    final offers = menu
        .map((m) => ProductModel.fromMap(m, resName: name, resId: resId))
        .toList();

    return RestaurantModel(
      id: map['_id'] ?? '',
      name: name,
      image:
          map['brand']?['logo']?['url'] ??
          (map['image'] ??
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500'),
      rating: (map['avgRating'] ?? 4.0).toDouble(),
      reviewCount: (map['ratings'] as List? ?? []).length,
      latitude: (map['location']?['coordinates']?[1] ?? 41.1121).toDouble(),
      longitude: (map['location']?['coordinates']?[0] ?? 29.0205).toDouble(),
      address: map['address'] ?? '',
      currentOffers: offers,
      reviews: (map['ratings'] as List? ?? [])
          .map((r) => r['comment']?.toString() ?? '')
          .toList(),
    );
  }
}

// Comprehensive Mock Data for Maslak (55 Restaurants clustered around actual hubs)
final List<Map<String, double>> maslakClusters = [
  {'lat': 41.1121, 'lng': 29.0205}, // Maslak 1453 hub
  {'lat': 41.1085, 'lng': 29.0068}, // UNIQ Istanbul hub
  {'lat': 41.1054, 'lng': 29.0234}, // ITU Ayazaga / Business Towers hub
  {'lat': 41.1185, 'lng': 29.0200}, // Vadistanbul / Skyland hub
];

final List<RestaurantModel> maslakRestaurants = List.generate(55, (i) {
  final cluster = maslakClusters[i % maslakClusters.length];
  // Stable procedural offsets to keep pins together in clusters
  final randomLatOffset = ((i * 17) % 100 - 50) / 100000;
  final randomLngOffset = ((i * 23) % 100 - 50) / 100000;

  final types = [
    {
      'name': 'Artisan Cafe',
      'img':
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&q=80',
      'item': 'Morning Pastry Box',
      'itemImg':
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&q=80',
      'ingredients':
          'assorted buttery croissants, cinnamon rolls, and seasonal fruit danishes',
    },
    {
      'name': 'Urban Bistro',
      'img':
          'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=500&q=80',
      'item': 'Lunch Rescue Meal',
      'itemImg':
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
      'ingredients':
          'grilled chicken breast, quinoa salad with fresh herbs, roasted root vegetables, and a side of balsamic vinaigrette',
    },
    {
      'name': 'Flame Grill',
      'img':
          'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=500&q=80',
      'item': 'BBQ Chicken Platter',
      'itemImg':
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&q=80',
      'ingredients':
          'char-grilled chicken leg quarter, house-made smoky BBQ sauce, honey coleslaw, and buttered corn on the cob',
    },
    {
      'name': 'Zen Sushi',
      'img':
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80',
      'item': 'Sushi Roll Selection',
      'itemImg':
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80',
      'ingredients':
          'premium sushi-grade salmon, fresh avocado, cucumber, pickled ginger, wasabi, and seasoned vinegared rice',
    },
    {
      'name': 'Golden Bakery',
      'img':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&q=80',
      'item': 'Assorted Doughnut Bag',
      'itemImg':
          'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&q=80',
      'ingredients':
          'handcrafted doughnuts including glazed, chocolate sprinkle, strawberry jam filled, and powdered sugar varieties',
    },
    {
      'name': 'Roma Pizzeria',
      'img':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80',
      'item': 'XL Margherita Slice',
      'itemImg':
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&q=80',
      'ingredients':
          '24-hour fermented dough, San Marzano tomato sauce, fresh buffalo mozzarella, aromatic basil leaves, and extra virgin olive oil',
    },
    {
      'name': 'Classic Burgers',
      'img':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
      'item': 'Cheeseburger Combo',
      'itemImg':
          'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500&q=80',
      'ingredients':
          'grass-fed beef patty, melted Irish cheddar, caramelized onions, crisp lettuce, tomato, house secret sauce, and a side of sea salt fries',
    },
    {
      'name': 'Sweet Delights',
      'img':
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&q=80',
      'item': 'Dessert Surprise Box',
      'itemImg':
          'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=500&q=80',
      'ingredients':
          'a mix of our daily best-sellers: red velvet cupcake, sea salt caramel brownie, and a slice of New York cheesecake',
    },
    {
      'name': 'Healthy Bowls',
      'img':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
      'item': 'Vegan Buddha Bowl',
      'itemImg':
          'https://images.unsplash.com/photo-1543332164-6e82f355badc?w=500&q=80',
      'ingredients':
          'organic kale, sweet potato chunks, chickpeas, hemp seeds, tahini-lemon dressing, and a base of wild rice',
    },
    {
      'name': 'Steak House',
      'img':
          'https://images.unsplash.com/photo-1546241072-48010ad28c2c?w=500&q=80',
      'item': 'Steak & Fries Pack',
      'itemImg':
          'https://images.unsplash.com/photo-1432139555190-58521daec20b?w=500&q=80',
      'ingredients':
          'sous-vide then seared flank steak, garlic herb butter, triple-cooked chunky fries, and roasted cherry tomatoes',
    },
  ];

  final selected = types[i % types.length];
  final restaurantName = "${selected['name']} Maslak ${i + 1}";
  // Diversify the offer name: sometimes "Rescue", sometimes specific, sometimes "Surprise"
  final offerTitle = i % 3 == 0
      ? "Rescue ${selected['item']}"
      : (i % 3 == 1
            ? "Surprise ${selected['name']} Box"
            : selected['item'] as String);

  final description = i % 3 == 1
      ? "A mystery selection of our daily specialties. Usually includes ${selected['ingredients']} and other fresh items from our shop."
      : "A delicious serving of our ${selected['item']}, featuring ${selected['ingredients']}. Perfectly prepared and ready for a second life.";

  return RestaurantModel(
    id: "r_maslak_$i",
    name: restaurantName,
    image: selected['img']!,
    rating: 4.2 + (i % 8) / 10,
    reviewCount: 120 + (i * 15),
    latitude: cluster['lat']! + randomLatOffset,
    longitude: cluster['lng']! + randomLngOffset,
    address: i % 2 == 0
        ? "Agaoglu Maslak 1453, Sariyer"
        : "Maslak Mah. Business Plaza, Sariyer",
    currentOffers: [
      ProductModel(
        restaurantId: "r_maslak_$i",
        title: offerTitle,
        image: selected['itemImg']!,
        price: ((15.0 + (i % 5) * 10) / 10).toStringAsFixed(2),
        rate: (4.4 + (i % 6) / 10).toStringAsFixed(1),
        rateCount: "${10 + i}",
        restaurantName: restaurantName,
        description: description,
      ),
    ],
    reviews: [
      "Excellent food rescue!",
      "Great value for money.",
      "Fresh and delicious.",
    ],
  );
});
