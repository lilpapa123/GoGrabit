import 'package:flutter/material.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class EditRestaurantScreen extends StatefulWidget {
  final String restaurantId;
  const EditRestaurantScreen({super.key, required this.restaurantId});

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;

  bool _loading = true;
  bool _saving = false;
  bool _gettingLocation = false;
  bool _uploading = false;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRestaurant();
  }

  Future<void> _fetchRestaurant() async {
    try {
      final res = await _api.getRestaurant(widget.restaurantId);
      if (res['statusCode'] == 200) {
        final data = res['body']['data'];
        _nameController = TextEditingController(text: data['name']);
        _descriptionController = TextEditingController(
          text: data['description'],
        );
        _addressController = TextEditingController(
          text: data['location']['address'],
        );
        _imageUrl = data['image_url'] ?? data['brand']?['logo']?['url'];
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() => _uploading = true);

    try {
      final res = await _api.uploadImage(image);
      if (res['statusCode'] == 200 && res['body']['asset'] != null) {
        setState(() {
          _imageUrl = res['body']['asset']['url'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      List<Location> locations = [];
      try {
        locations = await locationFromAddress(_addressController.text);
      } catch (e) {
        // Fallback for demo if precise geocoding fails
        debugPrint('Geocoding failed, using previous coordinates: $e');
      }

      double lat = 41.1121;
      double lon = 29.0205;
      if (locations.isNotEmpty) {
        lat = locations.first.latitude;
        lon = locations.first.longitude;
      }

      final res = await _api.updateRestaurant(widget.restaurantId, {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': {
          'address': _addressController.text,
          'coordinates': [lon, lat],
        },
      });
      if (res['statusCode'] == 200) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
        navigator.pop();
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Restaurant Profile'),
        backgroundColor: const Color(0xffF2762E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200],
                        image: _imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageUrl == null
                          ? const Icon(
                              Icons.restaurant,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    if (_uploading)
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black26,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _uploading ? null : _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xffF2762E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                _nameController,
                'Restaurant Name',
                Icons.restaurant,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                'Description',
                Icons.description,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildTextField(_addressController, 'Address', Icons.location_on),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _gettingLocation ? null : _getCurrentLocation,
                icon: _gettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(
                  _gettingLocation
                      ? 'Getting Location...'
                      : 'Use My Current Location',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xffF2762E),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF2762E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SAVE CHANGES',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
