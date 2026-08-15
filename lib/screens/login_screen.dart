import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/session_provider.dart';
import '../services/locale_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _pin = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _pin.text.trim().isEmpty) {
      setState(() => _error = context.tr('enter_login'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final staff = await AuthService.login(_username.text, _pin.text);
    setState(() => _loading = false);

    if (staff == null) {
      setState(() => _error = context.tr('incorrect_login'));
      return;
    }
    if (mounted) context.read<SessionProvider>().login(staff);
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('login')),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.read<LocaleProvider>().toggle(),
            child: Text(
              localeProvider.isArabic ? 'EN' : 'AR',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.storefront, size: 64, color: Colors.green),
                const SizedBox(height: 12),
                Text(context.tr('app_name'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _username,
                  decoration: InputDecoration(
                    labelText: context.tr('username'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: context.tr('pin'),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(context.tr('login')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
