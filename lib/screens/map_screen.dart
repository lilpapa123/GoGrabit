import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_grabit/model.dart';
import 'package:go_grabit/widgets/food_offer_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_grabit/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_grabit/widgets/custom_image_loader.dart';
import 'package:go_grabit/services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Maslak 1453 Center (Fallback)
  final LatLng maslakCenter = const LatLng(41.1122, 29.0202);
  final MapController _mapController = MapController();
  final _api = ApiService();
  bool _locationPermissionGranted = false;
  LatLng? _currentPosition;
  List<RestaurantModel> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _startLocationUpdates();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      final resData = await _api.getAllRestaurants();
      if (mounted) {
        setState(() {
          _restaurants = resData
              .map((m) => RestaurantModel.fromMap(m))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  Future<void> _checkPermissions() async {
    final platform = Theme.of(context).platform;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    if (!mounted) return;
    // Permission handler for mobile
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      final status = await Permission.location.request();
      if (status.isGranted) {
        setState(() {
          _locationPermissionGranted = true;
        });
        _goToUserLocation();
      }
    } else {
      // For Windows/other platforms
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          setState(() {
            _locationPermissionGranted = true;
          });
          _goToUserLocation();
        }
      } catch (e) {
        debugPrint('Error checking location permission: $e');
      }
    }
  }

  Future<void> _goToUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, 15.0);
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // If primary fails, try a fast low-accuracy fallback
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && mounted) {
          setState(() {
            _currentPosition = LatLng(lastKnown.latitude, lastKnown.longitude);
          });
          _mapController.move(_currentPosition!, 15.0);
        }
      } catch (_) {}
    }
  }

  Future<void> _launchMaps(double lat, double lng, String label) async {
    // Try universal geo scheme first (works well on mobile)
    final Uri geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    // Fallback for web/desktop browser
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    final Uri appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?q=$label&ll=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Force launch google maps as last resort
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch maps: $e');
      // If even that fails, try standard browser launch
      try {
        await launchUrl(googleMapsUrl);
      } catch (_) {}
    }
  }

  void _showRestaurantDetails(
    BuildContext context,
    RestaurantModel restaurant,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              // Header Image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CustomImageLoader(
                  imagePath: restaurant.image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Title and Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          restaurant.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.green, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Directions Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchMaps(
                    restaurant.latitude,
                    restaurant.longitude,
                    restaurant.name,
                  ),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text(
                    "Get Directions",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Active Offers
              const Text(
                "Active Offers",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurant.currentOffers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 15),
                  itemBuilder: (context, index) {
                    final offer = restaurant.currentOffers[index];
                    return SizedBox(
                      width: 200,
                      child: FoodOfferCard(
                        title: offer.title,
                        image: offer.image,
                        price: offer.price,
                        rate: offer.rate,
                        rateCount: offer.rateCount,
                        restaurantName: restaurant.name,
                        onRescue: () {
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).addToCart(offer);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reserved ${offer.title}!'),
                              backgroundColor: const Color(0xffF2762E),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Reviews
              const Text(
                "Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...restaurant.reviews.map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xffF2762E),
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            review,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: maslakCenter, initialZoom: 15.0),
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  -1,  0,  0, 0, 255,
                   0, -1,  0, 0, 255,
                   0,  0, -1, 0, 255,
                   0,  0,  0, 1,   0,
                ]),
                child: TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.gograbit.app',
                ),
              ),
              MarkerLayer(
                markers: [
                  // User Location Marker
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 80,
                      height: 80,
                      child: _UserLocationMarker(),
                    ),

                  // Restaurant Markers
                  ..._restaurants.map((restaurant) {
                    return Marker(
                      point: LatLng(restaurant.latitude, restaurant.longitude),
                      width: 60,
                      height: 60,
                      child: _RestaurantMarker(
                        restaurant: restaurant,
                        onTap: () =>
                            _showRestaurantDetails(context, restaurant),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Floating Search Bar/Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Search in Maslak 1453",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                        const Icon(Icons.search, color: Color(0xffF2762E)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom FAB-like Location Button
          Positioned(
            right: 16,
            bottom: 30,
            child: GestureDetector(
              onTap: () {
                if (_locationPermissionGranted) {
                  _goToUserLocation();
                } else {
                  _checkPermissions();
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location, color: Color(0xffF2762E)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffF2762E).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xffF2762E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RestaurantMarker extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const _RestaurantMarker({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Marker Arrow/Pin Shape
          CustomPaint(size: const Size(45, 55), painter: _MarkerPainter()),
          // Content Circle
          Positioned(
            top: 4,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CustomImageLoader(
                  imagePath: restaurant.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffF2762E)
      ..style = PaintingStyle.fill;

    final path = ui.Path();
    // Circle part
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.width));
    // Triangle part
    path.moveTo(size.width / 4, size.width * 0.85);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width * 3 / 4, size.width * 0.85);
    path.close();

    canvas.drawShadow(path, Colors.black, 4, true);
    canvas.drawPath(path, paint);

    // Inner White Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width / 2, size.width / 2),
      (size.width / 2) - 1,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
