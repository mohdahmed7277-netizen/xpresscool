import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/staff.dart';

class AuthService {
  /// Hashes a PIN with SHA-256 before storing. PINs are never stored in
  /// plain text, and this app never transmits them anywhere (fully offline).
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  /// Creates the very first account, which is always an admin.
  static Future<Staff> createFirstAdmin({
    required String name,
    required String username,
    required String pin,
  }) async {
    final staff = Staff(
      id: const Uuid().v4(),
      name: name,
      username: username.trim().toLowerCase(),
      pinHash: hashPin(pin),
      role: StaffRole.admin,
      createdAt: DateTime.now(),
    );
    await DBHelper.instance.insertStaff(staff);
    return staff;
  }

  static Future<Staff> createStaffAccount({
    required String name,
    required String username,
    required String pin,
    required StaffRole role,
  }) async {
    final staff = Staff(
      id: const Uuid().v4(),
      name: name,
      username: username.trim().toLowerCase(),
      pinHash: hashPin(pin),
      role: role,
      createdAt: DateTime.now(),
    );
    await DBHelper.instance.insertStaff(staff);
    return staff;
  }

  /// Returns the matching Staff if username/PIN are correct, else null.
  static Future<Staff?> login(String username, String pin) async {
    final staff = await DBHelper.instance.getStaffByUsername(username.trim().toLowerCase());
    if (staff == null) return null;
    if (staff.pinHash != hashPin(pin)) return null;
    return staff;
  }
}
