import 'package:flutter/foundation.dart';
import '../models/staff.dart';

class SessionProvider extends ChangeNotifier {
  Staff? _currentStaff;

  Staff? get currentStaff => _currentStaff;
  bool get isLoggedIn => _currentStaff != null;
  bool get isAdmin => _currentStaff?.role == StaffRole.admin;

  void login(Staff staff) {
    _currentStaff = staff;
    notifyListeners();
  }

  void logout() {
    _currentStaff = null;
    notifyListeners();
  }
}
