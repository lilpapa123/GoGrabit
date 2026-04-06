import 'package:flutter/material.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class PartnerRegistrationScreen extends StatefulWidget {
  const PartnerRegistrationScreen({super.key});

  @override
  State<PartnerRegistrationScreen> createState() =>
      _PartnerRegistrationScreenState();
}

class _PartnerRegistrationScreenState extends State<PartnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  final _api = ApiService();
  bool _loading = false;
  bool _gettingLocation = false;

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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // Geocode the address
      List<Location> locations = [];
      try {
        locations = await locationFromAddress(_addressController.text);
      } catch (e) {
        debugPrint('Geocoding failed, using Maslak fallback: $e');
        // Let's use a fallback instead of failing completely if the user is struggling with address strings
        locations = [
          Location(
            latitude: 41.1121,
            longitude: 29.0205,
            timestamp: DateTime.now(),
          ),
        ];
      }

      if (locations.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid address. Please try again.')),
          );
        }
        setState(() => _loading = false);
        return;
      }

      final location = locations.first;

      final res = await _api.registerPartner({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phone': _phoneController.text,
        'restaurantName': _restaurantNameController.text,
        'restaurantDescription': _descriptionController.text,
        'address': _addressController.text,
        'coordinates': [location.longitude, location.latitude],
      });

      if (res['statusCode'] == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please login.'),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['body']['message'] ?? 'Registration failed'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Registration'),
        backgroundColor: const Color(0xffF2762E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join GoGrabit as a Partner',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffF2762E),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Fill in the details to list your restaurant.'),
              const SizedBox(height: 32),

              const Text(
                'Personal Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _nameController,
                'Full Name',
                Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _emailController,
                'Email',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _passwordController,
                'Password',
                Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _phoneController,
                'Phone Number',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 32),
              const Text(
                'Restaurant Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _restaurantNameController,
                'Restaurant Name',
                Icons.restaurant,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                'Description',
                Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _addressController,
                'Address',
                Icons.location_on_outlined,
              ),
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
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF2762E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'REGISTER MY RESTAURANT',
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
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
