import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_grabit/model.dart';
import 'package:go_grabit/product_item.dart';
import 'package:go_grabit/screens/product/product_detail_screen.dart';
import 'package:go_grabit/screens/cart/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/cart_provider.dart';
import 'package:go_grabit/screens/popular_products_screen.dart';
import 'package:go_grabit/widgets/custom_image_loader.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> items = [
    "assets/banner/Slider 1.png",
    "assets/banner/Slider 2.png",
    "assets/banner/Slider 3.png",
  ];

  List<CategoryModel> category = [
    CategoryModel(
      image: "https://img.icons8.com/3d-fluency/94/fruit-basket.png",
      title: "Fruits",
    ),
    CategoryModel(
      image: "https://img.icons8.com/3d-fluency/94/milk-bottle.png",
      title: "Milk & Egg",
    ),
    CategoryModel(
      image: "https://img.icons8.com/3d-fluency/94/soda-bottle.png",
      title: "Beverages",
    ),
    CategoryModel(
      image: "https://img.icons8.com/3d-fluency/94/ingredients.png",
      title: "Vegetables",
    ),
  ];

  final _api = ApiService();
  bool _loading = true;
  List<ProductModel> _fruits = [];
  List<ProductModel> _vegetables = [];
  List<ProductModel> _bestSellers = [];

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
        // Simple filtering for demo, in production we should use backend categories
        _fruits = all
            .where(
              (p) =>
                  p.title.toLowerCase().contains('fruit') ||
                  p.title.toLowerCase().contains('banana') ||
                  p.title.toLowerCase().contains('orange') ||
                  p.title.toLowerCase().contains('apple'),
            )
            .toList();

        _vegetables = all
            .where(
              (p) =>
                  p.title.toLowerCase().contains('veg') ||
                  p.title.toLowerCase().contains('pepper') ||
                  p.title.toLowerCase().contains('tomato') ||
                  p.title.toLowerCase().contains('carrot'),
            )
            .toList();

        _bestSellers = all.where((p) {
          try {
            return double.parse(p.rate) >= 4.5;
          } catch (_) {
            return true;
          }
        }).toList();

        // If categories are empty, fill with some random ones for visual completeness
        if (_fruits.isEmpty && all.isNotEmpty) {
          _fruits = all.take(5).toList();
        }
        if (_vegetables.isEmpty && all.length > 5) {
          _vegetables = all.skip(5).take(5).toList();
        }
        if (_bestSellers.isEmpty && all.isNotEmpty) {
          _bestSellers = all.take(4).toList();
        }
      });
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Row(
          children: [
            SvgPicture.asset('assets/icons/motor.svg'),
            const SizedBox(width: 10),
            const Text("61 Hopper street...", style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              child: SvgPicture.asset('assets/icons/Icons.svg'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //banner
            FadeIn(
              duration: const Duration(seconds: 1),
              child: CarouselSlider.builder(
                itemCount: items.length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) =>
                        Image.asset(items[itemIndex]),
                options: CarouselOptions(
                  height: 170,
                  aspectRatio: 1,
                  viewportFraction: 0.6,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(seconds: 1),
                  autoPlayCurve: Curves.linear,
                  enlargeCenterPage: true,
                ),
              ),
            ),

            //category
            SizedBox(
              height: 110,
              child: AnimationLimiter(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: category.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PopularProductsScreen(
                                    categoryTitle: category[index].title,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 65,
                                  height: 65,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: CustomImageLoader(
                                      imagePath: category[index].image,
                                      width: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category[index].title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 24),
            const _SectionHeader(title: "Fresh Fruits"),
            const SizedBox(height: 16),

            // Fruits product
            SizedBox(
              height: 260,
              child: _loading
                  ? _buildShimmerList()
                  : _fruits.isEmpty
                  ? const Center(child: Text("No fruits currently available"))
                  : AnimationLimiter(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: _fruits.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final item = _fruits[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: SizedBox(
                                  width: 170,
                                  child: ProductItem(
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
                                              ProductDetailScreen(
                                                product: item,
                                              ),
                                        ),
                                      );
                                    },
                                    onAddToCart: () {
                                      Provider.of<CartProvider>(
                                        context,
                                        listen: false,
                                      ).addToCart(item);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${item.title} added to cart',
                                          ),
                                          backgroundColor: const Color(
                                            0xffF2762E,
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 24),
            const _SectionHeader(title: "Fresh Vegetables"),
            const SizedBox(height: 16),

            // Vegetables Section
            SizedBox(
              height: 260,
              child: _loading
                  ? _buildShimmerList()
                  : _vegetables.isEmpty
                  ? const Center(child: Text("No vegetables found"))
                  : AnimationLimiter(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: _vegetables.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final item = _vegetables[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: SizedBox(
                                  width: 170,
                                  child: ProductItem(
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
                                              ProductDetailScreen(
                                                product: item,
                                              ),
                                        ),
                                      );
                                    },
                                    onAddToCart: () {
                                      Provider.of<CartProvider>(
                                        context,
                                        listen: false,
                                      ).addToCart(item);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${item.title} added to cart',
                                          ),
                                          backgroundColor: const Color(
                                            0xffF2762E,
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 24),
            const _SectionHeader(title: "Best Sellers"),
            const SizedBox(height: 16),

            // Best Sellers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _loading
                  ? _buildShimmerGrid()
                  : _bestSellers.isEmpty
                  ? const Center(child: Text("No best sellers found"))
                  : AnimationLimiter(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _bestSellers.length,
                        itemBuilder: (context, index) {
                          final item = _bestSellers[index];
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            columnCount: 2,
                            child: ScaleAnimation(
                              child: FadeInAnimation(
                                child: ProductItem(
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
                                        content: Text(
                                          '${item.title} added to cart',
                                        ),
                                        backgroundColor: const Color(
                                          0xffF2762E,
                                        ),
                                        duration: const Duration(seconds: 1),
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
            ),
            const SizedBox(height: 30),

            //cart wedgit
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) => Container(
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Poppins',
              letterSpacing: -0.5,
            ),
          ),
          const Text(
            "See All",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xffF2762E),
            ),
          ),
        ],
      ),
    );
  }
}
