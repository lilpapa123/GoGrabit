import 'package:flutter/material.dart';
import 'package:go_grabit/services/api_service.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantOrdersScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getRestaurantOrders(widget.restaurantId);
      if (res['statusCode'] == 200) {
        setState(() => _orders = res['body']['orders'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      final res = await _api.updateOrderStatus(orderId, newStatus);
      if (res['statusCode'] == 200) {
        _fetchOrders();
      }
    } catch (e) {
      debugPrint('Error updating order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Orders'),
        backgroundColor: const Color(0xffF2762E),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return _buildOrderCard(order);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    String status = order['status'] ?? 'PENDING';
    Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['_id'].toString().substring(order['_id'].toString().length - 6).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...(order['items'] as List).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['quantity']}x ${item['name']}'),
                    Text('\$${item['price']}'),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order['totalAmount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xffF2762E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (status == 'ACCEPTED')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(order['_id'], 'READY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('MARK READY'),
                    ),
                  ),
                if (status == 'READY')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(order['_id'], 'DELIVERED'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('MARK DELIVERED'),
                    ),
                  ),
                if (status == 'PENDING')
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _updateStatus(order['_id'], 'ACCEPTED'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('ACCEPT'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _updateStatus(order['_id'], 'REJECTED'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('REJECT'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.blue;
      case 'READY':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
