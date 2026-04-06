import 'package:flutter/material.dart';
import 'package:go_grabit/model.dart';
import 'package:go_grabit/widgets/food_offer_card.dart';
import 'package:go_grabit/screens/product/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/cart_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _selectedCategory = "All";
  final List<String> _categories = [
    "All",
    "Cafe",
    "Bistro",
    "Grill",
    "Sushi",
    "Bakery",
    "Pizzeria",
    "Burgers",
    "Dessert",
    "Healthy",
    "Steak",
  ];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _filteredProducts = _allProducts;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    // Collect all listings from maslakRestaurants
    _allProducts = maslakRestaurants
        .expand((restaurant) => restaurant.currentOffers)
        .toList();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesSearch =
            product.title.toLowerCase().contains(query) ||
            (product.restaurantName?.toLowerCase() ?? '').contains(query);
        final matchesCategory =
            _selectedCategory == "All" ||
            product.title.contains(_selectedCategory) ||
            (product.restaurantName ?? '').contains(_selectedCategory);
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _sortProducts(String criteria) {
    setState(() {
      if (criteria == "Price: Low to High") {
        _filteredProducts.sort(
          (a, b) => double.parse(a.price).compareTo(double.parse(b.price)),
        );
      } else if (criteria == "Price: High to Low") {
        _filteredProducts.sort(
          (a, b) => double.parse(b.price).compareTo(double.parse(a.price)),
        );
      } else if (criteria == "Top Rated") {
        _filteredProducts.sort(
          (a, b) => double.parse(b.rate).compareTo(double.parse(a.rate)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Search",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search Bar & Sort
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Food or restaurants...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Color(0xffF2762E)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Sort By",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildSortOption("Price: Low to High"),
                              _buildSortOption("Price: High to Low"),
                              _buildSortOption("Top Rated"),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF2762E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sort, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Categories chips
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _applyFilters();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xffF2762E)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No results found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _selectedCategory = "All";
                              _applyFilters();
                            });
                          },
                          child: const Text(
                            "Reset Filters",
                            style: TextStyle(color: Color(0xffF2762E)),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final item = _filteredProducts[index];
                      return FoodOfferCard(
                        title: item.title,
                        image: item.image,
                        price: item.price,
                        rate: item.rate,
                        rateCount: item.rateCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: item),
                            ),
                          );
                        },
                        onRescue: () {
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).addToCart(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${item.title} to cart!'),
                              backgroundColor: const Color(0xffF2762E),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _sortProducts(label);
        Navigator.pop(context);
      },
    );
  }
}
