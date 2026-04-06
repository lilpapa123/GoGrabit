import 'dart:io' as io;
import 'dart:typed_data' as typed_data;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_grabit/profile/change_password_screen.dart';
import 'package:go_grabit/providers/user_provider.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  XFile? _imageFile;
  final _picker = ImagePicker();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?['name'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
    _addressController = TextEditingController(text: user?['address'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final api = ApiService();
    final userId = userProvider.user?['id'];

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error: User ID not found")));
      setState(() => _loading = false);
      return;
    }

    try {
      // 1. Upload Image if selected
      if (_imageFile != null) {
        final res = await api.uploadImage(_imageFile!, userId: userId);
        if (res['statusCode'] == 200) {
          // Update local provider with new image URL if returned
          if (res['body']['asset'] != null) {
            await userProvider.updateUser({
              'profile_image': res['body']['asset'],
            });
          }
        } else {
          throw "Image upload failed: ${res['body']}";
        }
      }

      // 2. Update Profile Info
      final Map<String, dynamic> updateData = {
        'name': _nameController.text,
        'email':
            _emailController.text, // Normally email update needs verification
        'phone': _phoneController.text,
        'address': _addressController.text,
      };

      final updateRes = await api.updateProfile(userId, updateData);

      if (updateRes['statusCode'] == 200) {
        await userProvider.updateUser(updateRes['body']['user'] ?? updateData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated successfully!")),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw "Profile update failed: ${updateRes['body']}";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final String? networkImage = (user != null && user['profile_image'] != null)
        ? user['profile_image']['url']
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // -- IMAGE with ICON
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _imageFile != null
                          ? (kIsWeb
                                ? FutureBuilder<typed_data.Uint8List>(
                                    future: _imageFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  )
                                : Image.file(
                                    io.File(_imageFile!.path),
                                    fit: BoxFit.cover,
                                  ))
                          : (networkImage != null
                                ? Image.network(networkImage, fit: BoxFit.cover)
                                : const Icon(
                                    LineAwesomeIcons.user_circle,
                                    size: 120,
                                    color: Colors.grey,
                                  )),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: const Icon(
                          LineAwesomeIcons.camera,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // -- Form Fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        label: Text("Full Name"),
                        prefixIcon: Icon(LineAwesomeIcons.user),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Name cannot be empty" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        label: Text("Email"),
                        prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Email cannot be empty" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        label: Text("Phone Number"),
                        prefixIcon: Icon(LineAwesomeIcons.phone),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        label: Text("Address"),
                        prefixIcon: Icon(LineAwesomeIcons.map_marker),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Change Password Flow
                          // Need to import ChangePasswordScreen first
                          // I'll assume I can add the import at the top in a separate chunk or rely on auto-import if IDE was here.
                          // But I should probably add the import too.
                          // I'll use Navigator.push
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // -- Form Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
