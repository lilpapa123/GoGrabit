import 'package:flutter/material.dart';
import 'package:go_grabit/providers/user_provider.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  final ApiService _api = ApiService();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?['_id'];

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID not found")));
      setState(() => _loading = false);
      return;
    }

    try {
      final res = await _api.changePassword(
        userId,
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (res['statusCode'] == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully!")),
        );
        Navigator.of(context).pop();
      } else {
        throw res['body']['message'] ?? 'Password change failed';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: Text(
          "Change Password",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text("Current Password"),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Enter current password" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text("New Password"),
                  prefixIcon: Icon(LineAwesomeIcons.lock),
                ),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter new password";
                  }
                  if (val.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text("Confirm New Password"),
                  prefixIcon: Icon(LineAwesomeIcons.lock),
                ),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Confirm your password";
                  }
                  if (val != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _changePassword,
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
                          "Change Password",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
