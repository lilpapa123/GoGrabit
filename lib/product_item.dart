import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/currency_provider.dart';
import 'package:go_grabit/widgets/custom_image_loader.dart';
import 'package:animate_do/animate_do.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.rate,
    required this.rateCount,
    this.onTap,
    this.onAddToCart,
  });

  final String title;
  final String image;
  final String price;
  final String rate;
  final String rateCount;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8), // Small margin for shadow
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Hero(
                          tag: image,
                          child: CustomImageLoader(
                            imagePath: image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Add to Cart Button (Floating Style)
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xffF2762E),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4DF2762E), // 30% opacity
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Details Section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rate,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "($rateCount)",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<CurrencyProvider>(
                          builder: (context, currencyProvider, child) {
                            return Text(
                              currencyProvider.convert(price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xffF2762E),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
