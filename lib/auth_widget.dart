import 'package:flutter/material.dart';
import 'package:go_grabit/services/api_service.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _api = ApiService();
  String _message = '';
  bool _loading = false;

  Future<void> _doRegister() async {
    setState(() { _loading = true; _message = ''; });
    final res = await _api.register(_name.text, _email.text, _password.text);
    setState(() { _loading = false; _message = res['body']?.toString() ?? 'No response'; });
  }

  Future<void> _doLogin() async {
    setState(() { _loading = true; _message = ''; });
    final res = await _api.login(_email.text, _password.text);
    setState(() { _loading = false; _message = res['body']?.toString() ?? 'No response'; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading) Row(
              children: [
                ElevatedButton(onPressed: _doRegister, child: const Text('Register')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _doLogin, child: const Text('Login')),
              ],
            ),
            const SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
