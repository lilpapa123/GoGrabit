import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final SocketService _socket = SocketService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null || _isGuest;

  bool _isGuest = false;
  bool get isGuest => _isGuest;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      final userData = await _auth.getUser();
      _user = userData != null ? _normalizeUser(userData) : null;
      if (_user != null) {
        final token = await _auth.getToken();
        _socket.connect(token);
        if (_user!['role'] == 'Restaurant_Owner' ||
            _user!['role'] == 'Manager') {
          if (_user!['restaurantId'] != null) {
            _socket.joinRestaurantRoom(_user!['restaurantId']);
          }
        }
        _socket.joinCustomerRoom(_user!['id']);
      }
    } catch (e) {
      debugPrint("Error loading user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(Map<String, dynamic> userData) async {
    _user = _normalizeUser(userData);
    _isGuest = false;
    final token = await _auth.getToken();
    _socket.connect(token);
    if (_user!['role'] == 'Restaurant_Owner' || _user!['role'] == 'Manager') {
      if (_user!['restaurantId'] != null) {
        _socket.joinRestaurantRoom(_user!['restaurantId']);
      }
    }
    _socket.joinCustomerRoom(_user!['id']);
    notifyListeners();
  }

  void loginAsGuest() {
    _isGuest = true;
    _user = null;
    notifyListeners();
  }

  Future<void> updateUser(Map<String, dynamic> updatedData) async {
    if (_user == null) return;

    // Merge and normalize
    _user = _normalizeUser({..._user!, ...updatedData});
    await _auth.updateLocalUser(_user!);
    notifyListeners();
  }

  Future<void> updateLocation(String address, double lat, double lng) async {
    await updateUser({
      'address': address,
      'location': {
        'type': 'Point',
        'coordinates': [lng, lat]
      }
    });
    // Also sync to backend
    await _auth.api.updateProfile(_user!['id'], {
      'address': address,
      'location': {
        'type': 'Point',
        'coordinates': [lng, lat]
      }
    });
  }

  Future<bool> uploadProfilePicture(XFile file) async {
    if (_user == null) return false;
    try {
      final res = await _auth.uploadProfileImage(file, _user!['id']);
      if (res['statusCode'] == 200 && res['body']['asset'] != null) {
        await updateUser({'profile_image': res['body']['asset']});
        return true;
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
    }
    return false;
  }

  Map<String, dynamic> _normalizeUser(Map<String, dynamic> data) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(data);
    if (normalized.containsKey('_id') && !normalized.containsKey('id')) {
      normalized['id'] = normalized['_id'];
    } else if (normalized.containsKey('id') && !normalized.containsKey('_id')) {
      normalized['_id'] = normalized['id'];
    }
    return normalized;
  }

  Future<void> logout() async {
    await _auth.logout();
    _socket.disconnect();
    _user = null;
    _isGuest = false;
    notifyListeners();
  }

  void refreshUser() {
    _init();
  }
}
