import 'package:flutter/material.dart';
import 'package:go_grabit/model.dart';
import 'package:go_grabit/providers/cart_provider.dart';
import 'package:go_grabit/providers/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/widgets/custom_image_loader.dart';
import 'package:animate_do/animate_do.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: FadeInLeft(child: const BackButton(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image with Hero animation
            Hero(
              tag: product.image,
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: CustomImageLoader(
                    imagePath: product.image,
                    fit: BoxFit.contain,
                    height: 250,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      product.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                  if (product.restaurantName != null) ...[
                    const SizedBox(height: 4),
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 16,
                            color: Color(0xffF2762E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.restaurantName!,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: const Color(0xffF2762E),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rate} (${product.rateCount} reviews)',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        Consumer<CurrencyProvider>(
                          builder: (context, currencyProvider, child) {
                            return Text(
                              currencyProvider.convert(product.price),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xffF2762E),
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      product.description ??
                          'Fresh and high-quality ${product.title.toLowerCase()} from our curated collection. Enjoy the best taste and ingredients.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Provider.of<CartProvider>(
              context,
              listen: false,
            ).addToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.title} added to cart'),
                backgroundColor: const Color(0xffF2762E),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffF2762E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Add To Cart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
