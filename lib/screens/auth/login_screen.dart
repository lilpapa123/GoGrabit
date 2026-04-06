import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_grabit/main_screen.dart';
import 'package:go_grabit/screens/partner/restaurant_dashboard_screen.dart';
import 'package:go_grabit/services/api_service.dart';
import 'package:go_grabit/services/auth_service.dart';
import 'package:go_grabit/screens/auth/signup_screen.dart';
import 'package:go_grabit/screens/auth/forgot_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _api = ApiService();
  final _auth = AuthService();
  bool _loading = false;
  bool _googleLoading = false;
  bool _isPartnerLogin = false;
  String? _errorMessage;

  Future<void> _doLogin() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final navigator = Navigator.of(context);
    final userProvider = context.read<UserProvider>();

    try {
      final res = await _api.login(_email.text, _password.text);
      if (!mounted) return;

      if (res['statusCode'] == 200 || res['statusCode'] == 201) {
        final userData = res['body']['user'];
        // Update UserProvider
        await userProvider.login(userData);

        final role = userData['role'];
        final restaurantId = userData['restaurantId'];

        bool isPartner =
            (role == 'Restaurant_Owner' || role == 'Manager') &&
            restaurantId != null;

        if (!mounted) return;

        if (isPartner) {
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDashboardScreen(restaurantId: restaurantId),
            ),
          );
        } else {
          // Default to customer view for all other roles or if restaurantId is missing
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = res['body']?.toString() ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
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
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage =
              res['body']?['error']?.toString() ?? 'Google Login failed';
        });
      }
    } catch (e) {
      debugPrint('🔥 Handle Google Login Exception: $e');
      if (context.mounted) {
        setState(() {
          _errorMessage =
              'Login Error: $e\n(Check if popups are blocked or if the origin is authorized)';
        });
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _googleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: SvgPicture.asset('assets/logo/logo.svg', height: 100),
              ),
              const SizedBox(height: 40),
              Text(
                _isPartnerLogin ? 'Partner Login' : 'Welcome Back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_isPartnerLogin)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Manage your restaurant from here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),

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

              // Login Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _doLogin,
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
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                // Google Login Button
                SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _googleLoading ? null : _handleGoogleLogin,
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
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xffF2762E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<UserProvider>().loginAsGuest();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isPartnerLogin = !_isPartnerLogin;
                  });
                },
                child: Text(
                  _isPartnerLogin ? 'Login as a Customer' : 'Login as a Partner',
                  style: const TextStyle(
                    color: Color(0xffF2762E),
                    fontWeight: FontWeight.bold,
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
