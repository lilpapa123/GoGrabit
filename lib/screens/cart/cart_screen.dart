import 'package:flutter/material.dart';
import 'package:go_grabit/providers/cart_provider.dart';
import 'package:go_grabit/screens/checkout/checkout_screen.dart';
import 'package:go_grabit/providers/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/widgets/custom_image_loader.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), centerTitle: true),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: cart.items.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CustomImageLoader(
                              imagePath: item.image,
                              width: 60,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Consumer<CurrencyProvider>(
                                builder: (context, currencyProvider, child) {
                                  return Text(
                                    currencyProvider.convert(item.price),
                                    style: const TextStyle(
                                      color: Color(0xffF2762E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            cart.removeFromCart(item);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isNotEmpty
          ? Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return Text(
                            currencyProvider.convert(cart.totalPrice),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xffF2762E),
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
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
                        'Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
