import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/main_screen.dart';
import '../../services/auth_service.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final bool isLogin; // If true, pop to login instead of pushing MainScreen?
                      // Actually, if we verify, we probably want to log them in automatically or redirect.
                      // For now, let's assume successful verification leads to Login or MainScreen.

  const VerificationScreen({
    super.key,
    required this.email,
    this.isLogin = false,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verify() async {
    if (_codeController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final auth = AuthService();
      final res = await auth.verifyEmail(widget.email, _codeController.text);
      if (res['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified successfully')),
        );
        // After verification, we could auto-login if the backend returns a token, 
        // OR ask them to login. 
        // Based on typical flows, asking to login is safer unless we cached credentials.
        // Or if we came from signup, maybe we can just close this screen or go to login.
        Navigator.popUntil(context, (route) => route.isFirst); 
        // Ideally navigate to login if not already there, but popUntil first is safe.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['body']['error'] ?? 'Verification failed'),
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

  Future<void> _resend() async {
    setState(() => _isLoading = true);
    try {
      final auth = AuthService();
      final res = await auth.sendVerificationEmail(widget.email);
       if (res['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code resent')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['body']['error'] ?? 'Failed to resend code'),
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
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Please enter the code sent to ${widget.email}'),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Verification Code'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verify,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
            TextButton(
              onPressed: _isLoading ? null : _resend,
              child: const Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
