import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _codeSent = false;

  Future<void> _sendCode() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = AuthService();
      final res = await auth.forgotPassword(_emailController.text);
      if (res['statusCode'] == 200) {
        setState(() => _codeSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent to email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['body']['error'] ?? 'Failed to send code'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = AuthService();
      final res = await auth.resetPassword(
        _emailController.text,
        _codeController.text,
        _passwordController.text,
      );
      if (res['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['body']['error'] ?? 'Failed to reset password'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                enabled: !_codeSent,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (_codeSent) ...[
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Verification Code'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Reset Password'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendCode,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send Verification Code'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
