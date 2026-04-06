import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:go_grabit/profile/billing_screen.dart';
import 'package:go_grabit/profile/edit_profile_screen.dart';
import 'package:go_grabit/profile/information_screen.dart';
import 'package:go_grabit/profile/settings_screen.dart';
import 'package:go_grabit/profile/user_management_screen.dart';
import 'package:go_grabit/providers/user_provider.dart';
import 'package:go_grabit/screens/auth/login_screen.dart';
import 'package:go_grabit/theme_provider.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?['id'];

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() => _uploading = true);

    try {
      final api = ApiService();
      final res = await api.uploadImage(image, userId: userId);

      if (res['statusCode'] == 200 && res['body']['asset'] != null) {
        await userProvider.updateUser({'profile_image': res['body']['asset']});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated!")),
          );
        }
      } else {
        throw res['body']['error'] ?? "Upload failed";
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final isGuest = userProvider.isGuest;

    if (isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LineAwesomeIcons.user_slash,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                "Guest User",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              const Text(
                "Sign in to access your profile",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    await userProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (c) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          (user != null &&
                                  user['profile_image'] != null &&
                                  user['profile_image'] is Map &&
                                  user['profile_image']['url'] != null)
                              ? Image.network(
                                  user['profile_image']['url'],
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        LineAwesomeIcons.user_circle,
                                        size: 120,
                                        color: Colors.grey,
                                      ),
                                )
                              : const Icon(
                                  LineAwesomeIcons.user_circle,
                                  size: 120,
                                  color: Colors.grey,
                                ),
                          if (_uploading)
                            Container(
                              width: 120,
                              height: 120,
                              color: Colors.black26,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _uploading
                          ? null
                          : () => _pickAndUploadImage(context),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: const Icon(
                          LineAwesomeIcons.alternate_pencil,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                user?['name'] ?? "User",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                user?['email'] ?? "",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              // MENU
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    LineAwesomeIcons.moon,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(
                  "Dark Mode",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Switch(
                  value: Provider.of<ThemeProvider>(context).isDarkMode,
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).toggleTheme(value);
                  },
                ),
              ),
              ProfileMenuWidget(
                title: "Settings",
                icon: LineAwesomeIcons.cog,
                onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const SettingsScreen()),
                ),
              ),
              ProfileMenuWidget(
                title: "Billing Details",
                icon: LineAwesomeIcons.wallet,
                onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const BillingScreen()),
                ),
              ),
              ProfileMenuWidget(
                title: "User Management",
                icon: LineAwesomeIcons.user_check,
                onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const UserManagementScreen(),
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: "Information",
                icon: LineAwesomeIcons.info,
                onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const InformationScreen()),
                ),
              ),
              ProfileMenuWidget(
                title: "Logout",
                icon: LineAwesomeIcons.alternate_sign_out,
                textColor: Colors.red,
                endIcon: false,
                onPress: () async {
                  await Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (c) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.apply(color: textColor),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              child: const Icon(
                LineAwesomeIcons.angle_right,
                size: 18.0,
                color: Colors.grey,
              ),
            )
          : null,
    );
  }
}
