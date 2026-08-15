import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/session_provider.dart';
import '../services/locale_provider.dart';

/// Shown only once, the very first time the app is opened (no staff exist yet).
class SetupAdminScreen extends StatefulWidget {
  const SetupAdminScreen({super.key});

  @override
  State<SetupAdminScreen> createState() => _SetupAdminScreenState();
}

class _SetupAdminScreenState extends State<SetupAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _pin = TextEditingController();
  final _confirmPin = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pin.text != _confirmPin.text) {
      setState(() => _error = context.tr('pins_no_match'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final staff = await AuthService.createFirstAdmin(
        name: _name.text.trim(),
        username: _username.text.trim(),
        pin: _pin.text.trim(),
      );
      if (mounted) context.read<SessionProvider>().login(staff);
    } catch (e) {
      setState(() => _error = context.tr('username_taken'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.tr('welcome')),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.storefront, size: 64, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(context.tr('welcome'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('setup_subtitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(labelText: context.tr('your_name')),
                    validator: (v) => (v == null || v.trim().isEmpty) ? context.tr('required') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _username,
                    decoration: InputDecoration(labelText: context.tr('username')),
                    validator: (v) => (v == null || v.trim().isEmpty) ? context.tr('required') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(labelText: context.tr('pin')),
                    validator: (v) =>
                        (v == null || v.length < 4) ? context.tr('required') : null,
                  ),
                  TextFormField(
                    controller: _confirmPin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(labelText: context.tr('confirm_pin')),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(context.tr('create_account')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
