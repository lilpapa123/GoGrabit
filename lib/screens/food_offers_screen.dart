import 'package:flutter/material.dart';
import 'package:go_grabit/model.dart';

import 'package:go_grabit/screens/product/product_detail_screen.dart';
import 'package:go_grabit/providers/cart_provider.dart';
import 'package:go_grabit/widgets/food_offer_card.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FoodOffersScreen extends StatefulWidget {
  const FoodOffersScreen({super.key});

  @override
  State<FoodOffersScreen> createState() => _FoodOffersScreenState();
}

class _FoodOffersScreenState extends State<FoodOffersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _api = ApiService();
  List<ProductModel> _offers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    setState(() => _loading = true);
    try {
      final restaurants = await _api.getAllRestaurants();
      List<ProductModel> allOffers = [];
      for (var resData in restaurants) {
        final restaurant = RestaurantModel.fromMap(resData);
        allOffers.addAll(restaurant.currentOffers);
      }
      // Shuffle for variety or sort by some criteria
      allOffers.shuffle();
      setState(() => _offers = allOffers);
      _controller.reset();
      _controller.forward();
    } catch (e) {
      debugPrint("Error fetching offers: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Food Rescue Offers",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Banner
              FadeTransition(
                opacity: _controller,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffF2762E), Color(0xffE66722)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffF2762E).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.volunteer_activism,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: const Text(
                            "Save food, save money, save the planet! Grab these discounted items before they go.",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Animated Grid
              _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: CircularProgressIndicator(
                          color: Color(0xffF2762E),
                        ),
                      ),
                    )
                  : _offers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.no_meals_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No active offers found",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : AnimationLimiter(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 20,
                            ),
                        itemCount: _offers.length,
                        itemBuilder: (context, index) {
                          final item = _offers[index];
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            columnCount: 2,
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: FoodOfferCard(
                                  title: item.title,
                                  image: item.image,
                                  price: item.price,
                                  rate: item.rate,
                                  rateCount: item.rateCount,
                                  restaurantName: item.restaurantName,
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
                                        content: Text('Rescued ${item.title}!'),
                                        backgroundColor: const Color(
                                          0xffF2762E,
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
