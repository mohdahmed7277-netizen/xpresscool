import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/db_helper.dart';
import '../services/session_provider.dart';
import 'setup_admin_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

/// Decides what to show first: first-run admin setup, the login screen,
/// or straight to the home screen if already logged in this session.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _hasStaff = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final hasStaff = await DBHelper.instance.hasAnyStaff();
    setState(() {
      _hasStaff = hasStaff;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<SessionProvider>(
      builder: (context, session, _) {
        if (session.isLoggedIn) return const HomeScreen();
        if (!_hasStaff) return const SetupAdminScreen();
        return const LoginScreen();
      },
    );
  }
}
