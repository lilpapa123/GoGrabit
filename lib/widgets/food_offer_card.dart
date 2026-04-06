import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/currency_provider.dart';
import 'package:go_grabit/widgets/custom_image_loader.dart';
import 'package:animate_do/animate_do.dart';

class FoodOfferCard extends StatelessWidget {
  final String title;
  final String image;
  final String price;
  final String rate;
  final String rateCount;
  final String? restaurantName;
  final VoidCallback? onTap;
  final VoidCallback? onRescue;

  const FoodOfferCard({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.rate,
    required this.rateCount,
    this.restaurantName,
    this.onTap,
    this.onRescue,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate a fake original price for the "discount" effect (e.g., +40%)
    final double currentPrice = double.tryParse(price) ?? 0.0;
    final double originalPrice = currentPrice * 1.4;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Discount Badge
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Hero(
                        tag: image,
                        child: CustomImageLoader(
                          imagePath: image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Rescue / Discount Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF2762E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FadeInLeft(
                        delay: const Duration(milliseconds: 300),
                        child: const Text(
                          "SAVE 40%",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        if (restaurantName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            restaurantName!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Consumer<CurrencyProvider>(
                              builder: (context, currencyProvider, child) {
                                return Text(
                                  currencyProvider.convert(originalPrice),
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Consumer<CurrencyProvider>(
                              builder: (context, currencyProvider, child) {
                                return Text(
                                  currencyProvider.convert(price),
                                  style: const TextStyle(
                                    color: Color(0xffF2762E),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onRescue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF2762E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          "Reserve Now !",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
