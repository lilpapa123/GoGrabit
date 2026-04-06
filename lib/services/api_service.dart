import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config.dart';

class ApiService {
  final String base;
  ApiService({String? base}) : base = base ?? apiBase;

  Uri _uri(String path) => Uri.parse(base + path);

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    print('Registering with $name, $email');
    try {
      final res = await http.post(
        _uri('/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': 'Customer',
        }),
      );
      print('Register Response: ${res.statusCode} ${res.body}');
      return _parse(res);
    } catch (e) {
      print('Register Error: $e');
      return {
        'statusCode': 500,
        'body': {'error': 'Connection Error: $e'}
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      _uri('/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parse(res);
  }

  Future<List<dynamic>> getNearbyRestaurants(
    double lat,
    double lng, {
    int distance = 10000,
    String? category,
    String? sortBy,
  }) async {
    String q = 'lat=${lat.toString()}&lng=${lng.toString()}&distance=$distance';
    if (category != null && category.isNotEmpty && category != 'All') {
      q += '&category=$category';
    }
    if (sortBy != null) q += '&sortBy=$sortBy';

    final res = await http.get(_uri('/restaurants/nearby?$q'));
    final parsed = _parse(res);
    if (parsed['statusCode'] == 200) {
      return parsed['body']['data'] ?? [];
    }
    return [];
  }

  Future<List<dynamic>> getFeaturedRestaurants() async {
    final res = await http.get(_uri('/restaurants/featured'));
    final parsed = _parse(res);
    if (parsed['statusCode'] == 200) {
      return parsed['body']['data'] ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> createPaymentIntent(String orderId) async {
    final res = await http.post(
      _uri('/orders/payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> confirmPayment(String orderId) async {
    final res = await http.post(
      _uri('/orders/$orderId/confirm-payment'),
      headers: {'Content-Type': 'application/json'},
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> order) async {
    final res = await http.post(
      _uri('/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );
    return _parse(res);
  }

  Future<List<dynamic>> getAllRestaurants() async {
    final res = await http.get(_uri('/restaurants'));
    final parsed = _parse(res);
    if (parsed['statusCode'] == 200) {
      return parsed['body']['data'] ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> getRestaurant(String id) async {
    final res = await http.get(_uri('/restaurants/$id'));
    return _parse(res);
  }

  Future<List<dynamic>> getCustomerOrders(String customerId) async {
    final res = await http.get(_uri('/orders/customer/$customerId'));
    final parsed = _parse(res);
    if (parsed['statusCode'] == 200) {
      return parsed['body']['orders'] ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      _uri('/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _parse(res);
  }

  Map<String, dynamic> _parse(http.Response res) {
    try {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      return {'statusCode': res.statusCode, 'body': body};
    } catch (e) {
      return {
        'statusCode': res.statusCode,
        'body': {'error': 'Invalid JSON'},
      };
    }
  }

  Future<Map<String, dynamic>> uploadImage(
    XFile file, {
    String? userId,
    String? restaurantId,
    String? menuItemId,
    String? target,
  }) async {
    var request = http.MultipartRequest('POST', _uri('/upload'));
    if (userId != null) request.fields['userId'] = userId;
    if (restaurantId != null) request.fields['restaurantId'] = restaurantId;
    if (menuItemId != null) request.fields['menuItemId'] = menuItemId;
    if (target != null) request.fields['target'] = target;

    final bytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: file.name),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _parse(response);
  }

  Future<Map<String, dynamic>> changePassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    final res = await http.post(
      _uri('/auth/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> registerPartner(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      _uri('/partner/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> getDashboardStats(String restaurantId) async {
    final res = await http.get(_uri('/partner/dashboard/$restaurantId'));
    return _parse(res);
  }

  Future<Map<String, dynamic>> addMenuItem(
    String restaurantId,
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      _uri('/restaurants/$restaurantId/menu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> updateRestaurant(
    String restaurantId,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      _uri('/restaurants/$restaurantId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> toggleItemAvailability(
    String restaurantId,
    String itemId,
    bool available,
  ) async {
    final res = await http.put(
      _uri('/restaurants/$restaurantId/menu/availability'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'itemId': itemId, 'is_available': available}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> getRestaurantOrders(String restaurantId) async {
    final res = await http.get(_uri('/orders/restaurant/$restaurantId'));
    return _parse(res);
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    final res = await http.patch(
      _uri('/orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(
      _uri('/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    final res = await http.post(
      _uri('/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> sendVerificationEmail(String email) async {
    final res = await http.post(
      _uri('/auth/send-verification-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    final res = await http.post(
      _uri('/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    return _parse(res);
  }
}
