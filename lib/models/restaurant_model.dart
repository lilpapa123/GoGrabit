class MenuItemModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final List<String> ingredients;
  final bool isAvailable;
  final String? category;

  MenuItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    required this.ingredients,
    required this.isAvailable,
    this.category,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] != null ? json['image']['url'] : null,
      ingredients: (json['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isAvailable: json['is_available'] ?? true,
      category: json['category'],
    );
  }
}

class RestaurantModel {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final List<double> coordinates;
  final String? logo;
  final String? banner;
  final String status;
  final List<MenuItemModel> menu;
  final double averageRating;
  final int ratingCount;

  RestaurantModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    required this.coordinates,
    this.logo,
    this.banner,
    required this.status,
    required this.menu,
    required this.averageRating,
    required this.ratingCount,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    var rawMenu = json['menu'] as List<dynamic>? ?? [];
    var menuItems = rawMenu.map((i) => MenuItemModel.fromJson(i)).toList();

    return RestaurantModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      address: json['location']?['address'],
      coordinates: (json['location']?['coordinates'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [0.0, 0.0],
      logo: json['brand']?['logo']?['url'],
      banner: json['brand']?['banner']?['url'],
      status: json['status'] ?? 'Closed',
      menu: menuItems,
      averageRating: (json['avgRating'] ?? 0).toDouble(),
      ratingCount: (json['ratings'] as List?)?.length ?? 0, 
    );
  }
}
