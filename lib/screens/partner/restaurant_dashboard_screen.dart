import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:go_grabit/screens/partner/manage_offers_screen.dart';
import 'package:go_grabit/screens/partner/edit_restaurant_screen.dart';
import 'package:go_grabit/screens/partner/restaurant_orders_screen.dart';
import 'package:go_grabit/services/socket_service.dart';
import 'package:go_grabit/widgets/custom_image_loader.dart';
import 'dart:async';

class RestaurantDashboardScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantDashboardScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  final _api = ApiService();
  bool _loading = true;
  bool _uploadingLogo = false;
  bool _uploadingBanner = false;
  final _picker = ImagePicker();
  Map<String, dynamic>? _stats;
  final _socket = SocketService();
  StreamSubscription? _orderSubscription;

  // Mock data for new features
  final List<double> _weeklyRevenue = [
    420.0,
    380.0,
    510.0,
    440.0,
    590.0,
    620.0,
    480.0,
  ];
  final List<Map<String, dynamic>> _topSellers = [
    {
      'name': 'Gorgonzola Pizza',
      'sales': 45,
      'image':
          'https://images.unsplash.com/photo-1574071318508-1cdbad80ad38?w=500',
    },
    {
      'name': 'Mixed Salad',
      'sales': 32,
      'image':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
    },
  ];
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'title': 'New Order #4829',
      'time': '5 mins ago',
      'type': 'order',
      'icon': Icons.shopping_cart,
    },
    {
      'title': 'Review: 5 Stars from Alex',
      'time': '2 hours ago',
      'type': 'review',
      'icon': Icons.star,
    },
    {
      'title': 'Offer "Sushi Set" Expired',
      'time': '3 hours ago',
      'type': 'system',
      'icon': Icons.warning,
    },
  ];
  final List<Map<String, dynamic>> _recentReviews = [
    {
      'user': 'Alex M.',
      'rating': 5,
      'comment': 'The food was still hot and delicious. Great value!',
      'date': 'Today',
    },
    {
      'user': 'Sara K.',
      'rating': 4,
      'comment': 'Excellent sushi rescue. Very fresh.',
      'date': 'Yesterday',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _initSocket();
  }

  void _initSocket() {
    _socket.connect(
      null,
    ); // Assuming no token required or handled elsewhere for now
    _socket.joinRestaurantRoom(widget.restaurantId);
    final messenger = ScaffoldMessenger.of(context);
    _orderSubscription = _socket.orderStream.listen((data) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Order Received!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Order #${data['orderId'].toString().substring(data['orderId'].toString().length - 4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xffF2762E),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantOrdersScreen(
                        restaurantId: widget.restaurantId,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
        _fetchStats(); // Refresh stats automatically
      }
    });
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getDashboardStats(widget.restaurantId);
      if (res['statusCode'] == 200) {
        setState(() => _stats = res['body']['data']);
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadRestaurantImage(String target) async {
    final messenger = ScaffoldMessenger.of(context);
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    if (target == 'logo') {
      setState(() => _uploadingLogo = true);
    } else {
      setState(() => _uploadingBanner = true);
    }

    try {
      final res = await _api.uploadImage(
        image,
        restaurantId: widget.restaurantId,
        target: target,
      );

      if (res['statusCode'] == 200) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              "${target == 'logo' ? 'Logo' : 'Banner'} updated successfully!",
            ),
          ),
        );
        await _fetchStats();
      } else {
        throw res['body']['error'] ?? "Upload failed";
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text("Upload Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _uploadingLogo = false;
          _uploadingBanner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xffF2762E)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _buildStatusHeader(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Overview'),
                  const SizedBox(height: 16),
                  _buildStatGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Revenue Trends'),
                  const SizedBox(height: 16),
                  _buildRevenueChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 16),
                  _buildQuickActionGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Top Selling Offers'),
                  const SizedBox(height: 16),
                  _buildTopSellersList(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Customer Reviews'),
                  const SizedBox(height: 16),
                  _buildReviewCarousel(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recent Activity'),
                  const SizedBox(height: 16),
                  _buildActivityFeed(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xffF2762E),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _stats?['restaurantName'] ?? 'Dashboard',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CustomImageLoader(
              imagePath:
                  _stats?['bannerUrl'] ??
                  'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
              fit: BoxFit.cover,
            ),
            if (_uploadingBanner)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            // Edit Banner Icon
            Positioned(
              top: 40,
              right: 60,
              child: GestureDetector(
                onTap: () => _pickAndUploadRestaurantImage('banner'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 16,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CustomImageLoader(
                        imagePath:
                            _stats?['logoUrl'] ??
                            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                  if (_uploadingLogo)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickAndUploadRestaurantImage('logo'),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xffF2762E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _fetchStats,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xff2D3436),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildStatusHeader() {
    bool isOpen = _stats?['status'] == 'Open';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpen
              ? [Colors.green.shade50, Colors.white]
              : [Colors.red.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isOpen ? Colors.green : Colors.red).withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOpen ? Colors.green : Colors.red).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isOpen ? Colors.green : Colors.red).withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOpen ? Icons.store : Icons.store_outlined,
              color: isOpen ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen
                      ? 'Your store is currently live'
                      : 'Your store is currently offline',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isOpen
                      ? 'Ready to receive orders'
                      : 'Not accepting any orders now',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: isOpen,
              onChanged: (val) async {
                try {
                  final res = await _api.updateRestaurant(widget.restaurantId, {
                    'status': val ? 'Open' : 'Closed',
                  });
                  if (res['statusCode'] == 200) {
                    _fetchStats();
                  }
                } catch (e) {
                  debugPrint('Error toggling status: $e');
                }
              },
              activeThumbColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildGlassStatCard(
          'Orders',
          '${_stats?['totalOrders'] ?? 0}',
          Icons.shopping_bag,
          const Color(0xffF2762E),
        ),
        _buildGlassStatCard(
          'Revenue',
          '\$${_stats?['totalRevenue'] ?? 0}',
          Icons.monetization_on,
          Colors.green,
        ),
        _buildGlassStatCard(
          'Pending',
          '${_stats?['pendingOrders'] ?? 0}',
          Icons.timer,
          Colors.orange,
        ),
        _buildGlassStatCard(
          'Active Offers',
          '${_stats?['activeOffers'] ?? 0}',
          Icons.local_offer,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildGlassStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 60, color: color.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2D3436),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Sales',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+12.5%',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weeklyRevenue.asMap().entries.map((entry) {
              double height = (entry.value / 700) * 120;
              bool isToday = entry.key == 5;
              return Column(
                children: [
                  Container(
                    width: 30,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday
                            ? [const Color(0xffF2762E), const Color(0xffFF9F68)]
                            : [Colors.grey.shade100, Colors.grey.shade200],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][entry.key],
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday ? const Color(0xffF2762E) : Colors.grey,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    return Row(
      children: [
        _buildActionItem(
          'Manage\nOffers',
          Icons.restaurant_menu,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ManageOffersScreen(restaurantId: widget.restaurantId),
            ),
          ),
        ),
        _buildActionItem(
          'Orders\nHistory',
          Icons.history,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantOrdersScreen(restaurantId: widget.restaurantId),
            ),
          ),
        ),
        _buildActionItem(
          'Edit\nProfile',
          Icons.settings,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditRestaurantScreen(restaurantId: widget.restaurantId),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSellersList() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topSellers.length,
        itemBuilder: (context, index) {
          final item = _topSellers[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: CustomImageLoader(
                    imagePath: item['image'],
                    width: 90,
                    height: 160,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item['sales']} sales',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Icon(
                              Icons.star_half,
                              color: Colors.amber,
                              size: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityFeed() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentActivity.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey[100]),
        itemBuilder: (context, index) {
          final activity = _recentActivity[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activity['icon'],
                size: 20,
                color: const Color(0xff2D3436),
              ),
            ),
            title: Text(
              activity['title'],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              activity['time'],
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            trailing: const Icon(Icons.chevron_right, size: 16),
          );
        },
      ),
    );
  }

  Widget _buildReviewCarousel() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentReviews.length,
        itemBuilder: (context, index) {
          final review = _recentReviews[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review['user'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      review['date'],
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review['rating'] ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
