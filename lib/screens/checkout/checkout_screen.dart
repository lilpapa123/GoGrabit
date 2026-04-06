import 'package:flutter/material.dart';
import 'package:go_grabit/providers/cart_provider.dart';
import 'package:go_grabit/providers/user_provider.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = ApiService();
  bool _isProcessing = false;
  String _paymentMethod = 'Credit Card';

  Future<void> _handlePayment() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place an order')),
      );
      return;
    }

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    setState(() => _isProcessing = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      // 1. Place the order
      final orderData = {
        'restaurantId': cart.items.first.restaurantId ?? 'r_default',
        'customerId': userProvider.user!['id'],
        'items': cart.items
            .map(
              (item) => {
                'menuItemId': item.id ?? 'm_default',
                'name': item.title,
                'quantity': 1,
                'price': double.tryParse(item.price) ?? 0.0,
              },
            )
            .toList(),
        'totalAmount': cart.totalPrice,
      };

      final orderRes = await _api.placeOrder(orderData);
      if (orderRes['statusCode'] != 201) {
        throw Exception(orderRes['body']?['message'] ?? 'Order failed');
      }

      final orderId = orderRes['body']['orderId'];

      // 2. Create Payment Intent
      final intentRes = await _api.createPaymentIntent(orderId);
      if (intentRes['statusCode'] != 200) {
        throw Exception('Payment initiation failed');
      }

      // 3. Confirm Payment (Simulating successful Stripe confirmation)
      final confirmRes = await _api.confirmPayment(orderId);
      if (confirmRes['statusCode'] != 200) {
        throw Exception('Payment confirmation failed');
      }

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Success!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your order has been paid and is being prepared!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  cart.clearCart();
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close checkout
                  Navigator.of(context).pop(); // Close cart
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF2762E),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Continue Shopping"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Shipping Address',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Payment Method',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildPaymentOption('Credit Card', Icons.credit_card),
              const SizedBox(height: 10),
              _buildPaymentOption('Cash on Delivery', Icons.money),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '\$${cart.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffF2762E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF2762E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirm & Pay',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    bool isSelected = _paymentMethod == method;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xffF2762E) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? const Color(0xffF2762E).withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xffF2762E) : Colors.grey,
        ),
        title: Text(
          method,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xffF2762E))
            : null,
        onTap: () => setState(() => _paymentMethod = method),
      ),
    );
  }
}
