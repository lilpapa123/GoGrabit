import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_grabit/main_screen.dart';
import 'package:go_grabit/services/auth_service.dart';
import 'package:go_grabit/screens/auth/partner_registration_screen.dart';
import 'package:go_grabit/screens/auth/verification_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/user_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _googleLoading = false;
  String? _errorMessage;

  Future<void> _doRegister() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final navigator = Navigator.of(context);
    final userProvider = context.read<UserProvider>();

    try {
      final res = await _auth.register(_name.text, _email.text, _password.text);
      if (!mounted) return;
      if (res['statusCode'] == 200 || res['statusCode'] == 201) {
         // Instead of login immediately, go to verification
         Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VerificationScreen(email: _email.text),
            ),
         );
      } else {
        setState(() {
          final body = res['body'];
          // For debugging, show the whole body if possible
          final error =
              body?['message'] ??
              body?['error'] ??
              'Failed: Status ${res['statusCode']} \nBody: $body';
          _errorMessage = error.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() {
      _googleLoading = true;
      _errorMessage = null;
    });

    final navigator = Navigator.of(context);
    final userProvider = context.read<UserProvider>();

    try {
      final res = await _auth.signInWithGoogle();
      if (!mounted) return;
      if (res['statusCode'] == 200) {
        final userData = res['body']['user'];
        await userProvider.login(userData);
        if (!mounted) return;
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage =
              res['body']?['error']?.toString() ?? 'Google Registration failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _googleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Logo
              Center(
                child: SvgPicture.asset('assets/logo/logo.svg', height: 80),
              ),
              const SizedBox(height: 30),
              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to get started',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Name Field
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Sign Up Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _doRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF2762E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Google Signup Button
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _googleLoading ? null : _handleGoogleRegister,
                  icon: _googleLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login, color: Colors.blue),
                  label: const Text(
                    'CONTINUE WITH GOOGLE',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xffF2762E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PartnerRegistrationScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.business_center_outlined,
                  color: Color(0xffF2762E),
                ),
                label: const Text(
                  'REGISTER AS PARTNER',
                  style: TextStyle(
                    color: Color(0xffF2762E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffF2762E)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
