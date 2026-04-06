import 'package:flutter/material.dart';
import 'package:go_grabit/model.dart';
import 'package:go_grabit/product_item.dart';
import 'package:go_grabit/screens/product/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/cart_provider.dart';

import 'package:go_grabit/services/api_service.dart';

class PopularProductsScreen extends StatefulWidget {
  final String categoryTitle;

  const PopularProductsScreen({super.key, required this.categoryTitle});

  @override
  State<PopularProductsScreen> createState() => _PopularProductsScreenState();
}

class _PopularProductsScreenState extends State<PopularProductsScreen> {
  final _api = ApiService();
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _loading = true);
    try {
      final restaurantsData = await _api.getAllRestaurants();
      List<ProductModel> all = [];
      for (var resData in restaurantsData) {
        final restaurant = RestaurantModel.fromMap(resData);
        all.addAll(restaurant.currentOffers);
      }

      setState(() {
        final cat = widget.categoryTitle.toLowerCase();
        if (cat.contains("fruit")) {
          _products = all
              .where(
                (p) =>
                    p.title.toLowerCase().contains('fruit') ||
                    p.title.toLowerCase().contains('banana') ||
                    p.title.toLowerCase().contains('orange') ||
                    p.title.toLowerCase().contains('apple') ||
                    p.title.toLowerCase().contains('strawberry') ||
                    p.title.toLowerCase().contains('grape'),
              )
              .toList();
        } else if (cat.contains("milk") ||
            cat.contains("egg") ||
            cat.contains("dairy")) {
          _products = all
              .where(
                (p) =>
                    p.title.toLowerCase().contains('milk') ||
                    p.title.toLowerCase().contains('egg') ||
                    p.title.toLowerCase().contains('yogurt') ||
                    p.title.toLowerCase().contains('cheese') ||
                    p.title.toLowerCase().contains('dairy'),
              )
              .toList();
        } else if (cat.contains("beverage") ||
            cat.contains("drink") ||
            cat.contains("tea")) {
          _products = all
              .where(
                (p) =>
                    p.title.toLowerCase().contains('drink') ||
                    p.title.toLowerCase().contains('beverage') ||
                    p.title.toLowerCase().contains('tea') ||
                    p.title.toLowerCase().contains('coffee') ||
                    p.title.toLowerCase().contains('juice') ||
                    p.title.toLowerCase().contains('ayran'),
              )
              .toList();
        } else if (cat.contains("vegetable") || cat.contains("green")) {
          _products = all
              .where(
                (p) =>
                    p.title.toLowerCase().contains('veg') ||
                    p.title.toLowerCase().contains('pepper') ||
                    p.title.toLowerCase().contains('tomato') ||
                    p.title.toLowerCase().contains('carrot') ||
                    p.title.toLowerCase().contains('cucumber'),
              )
              .toList();
        } else {
          _products = all;
        }

        // If specific category is empty, show a mix to avoid blank screen in demo
        if (_products.isEmpty && all.isNotEmpty) {
          _products = all.take(10).toList();
        }
      });
    } catch (e) {
      debugPrint("Error fetching popular products: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffF2762E)),
            )
          : _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No items found in this category",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: _products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final item = _products[index];
                  return ProductItem(
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
                    onAddToCart: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addToCart(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.title} added to cart'),
                          backgroundColor: const Color(0xffF2762E),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
