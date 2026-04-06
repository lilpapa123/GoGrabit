import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:go_grabit/widgets/custom_image_loader.dart';

class ManageOffersScreen extends StatefulWidget {
  final String restaurantId;
  const ManageOffersScreen({super.key, required this.restaurantId});

  @override
  State<ManageOffersScreen> createState() => _ManageOffersScreenState();
}

class _ManageOffersScreenState extends State<ManageOffersScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<dynamic> _menu = [];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getRestaurant(widget.restaurantId);
      if (res['statusCode'] == 200) {
        setState(() => _menu = res['body']['data']['menu'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching menu: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleAvailability(String itemId, bool currentStatus) async {
    try {
      final res = await _api.toggleItemAvailability(
        widget.restaurantId,
        itemId,
        !currentStatus,
      );
      if (res['statusCode'] == 200) {
        _fetchMenu();
      }
    } catch (e) {
      debugPrint('Error toggling availability: $e');
    }
  }

  void _showAddOfferDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    XFile? selectedImage;
    bool isUploading = false;
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create New Offer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Image Picker UI
                        GestureDetector(
                          onTap: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 70,
                            );
                            if (image != null) {
                              setModalState(() => selectedImage = image);
                            }
                          },
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                style: BorderStyle.none,
                              ),
                            ),
                            child: selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: kIsWeb
                                        ? FutureBuilder<Uint8List>(
                                            future: selectedImage!
                                                .readAsBytes(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Image.memory(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                );
                                              }
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                          )
                                        : Image.file(
                                            File(selectedImage!.path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 40,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Upload Offer Photo',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          'Offer Name',
                          nameController,
                          Icons.fastfood_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          'Price',
                          priceController,
                          Icons.attach_money,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          'Description',
                          descriptionController,
                          Icons.description_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty ||
                              priceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill name and price'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isUploading = true);

                          String imageUrl =
                              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500';

                          try {
                            if (selectedImage != null) {
                              final uploadRes = await _api.uploadImage(
                                selectedImage!,
                                restaurantId: widget.restaurantId,
                                target: 'offer',
                              );
                              if (uploadRes['statusCode'] == 200) {
                                imageUrl = uploadRes['body']['asset']['url'];
                              }
                            }

                            final res = await _api
                                .addMenuItem(widget.restaurantId, {
                                  'name': nameController.text,
                                  'price': double.parse(priceController.text),
                                  'description': descriptionController.text,
                                  'image_url': imageUrl,
                                });
                            if (res['statusCode'] == 201) {
                              if (context.mounted) Navigator.pop(context);
                              _fetchMenu();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Offer published!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            debugPrint('Upload/Add error: $e');
                          } finally {
                            if (mounted) {
                              setModalState(() => isUploading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF2762E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Publish Offer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2D3436),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xffF2762E), size: 20),
            filled: true,
            fillColor: const Color(0xffF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Rescue Management',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff2D3436),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _fetchMenu,
            icon: const Icon(Icons.refresh_rounded),
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xffF2762E),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOfferDialog,
        backgroundColor: const Color(0xff2D3436),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Offer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffF2762E)),
            )
          : _menu.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No offers active',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first rescue offer today!',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final item = _menu[index];
                bool available = item['is_available'] ?? false;
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 140,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomImageLoader(
                                imagePath:
                                    item['image_url'] ??
                                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (available
                                                ? Colors.green
                                                : Colors.grey[800])!
                                            .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    available ? 'Live' : 'Hidden',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2D3436),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '\$${item['price']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xffF2762E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['description'] ??
                                    'No description provided.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Text(
                                    available
                                        ? 'Disable Offer'
                                        : 'Enable Offer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const Spacer(),
                                  Switch(
                                    value: available,
                                    onChanged: (val) => _toggleAvailability(
                                      item['_id'],
                                      available,
                                    ),
                                    activeThumbColor: Colors.green,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
