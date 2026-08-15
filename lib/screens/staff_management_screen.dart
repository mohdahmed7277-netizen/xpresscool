import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/staff.dart';
import '../services/auth_service.dart';
import '../services/locale_provider.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  List<Staff> _staff = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final staff = await DBHelper.instance.getAllStaff();
    setState(() => _staff = staff);
  }

  Future<void> _addStaff() async {
    final nameCtl = TextEditingController();
    final userCtl = TextEditingController();
    final pinCtl = TextEditingController();
    StaffRole role = StaffRole.staff;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(context.tr('add_staff_account')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtl, decoration: InputDecoration(labelText: context.tr('name'))),
              TextField(controller: userCtl, decoration: InputDecoration(labelText: context.tr('username'))),
              TextField(
                controller: pinCtl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(labelText: context.tr('pin')),
              ),
              DropdownButtonFormField<StaffRole>(
                initialValue: role,
                decoration: InputDecoration(labelText: context.tr('role')),
                items: [
                  DropdownMenuItem(value: StaffRole.staff, child: Text(context.tr('staff_role'))),
                  DropdownMenuItem(value: StaffRole.admin, child: Text(context.tr('admin_role'))),
                ],
                onChanged: (v) => setDialogState(() => role = v ?? StaffRole.staff),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('cancel'))),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.tr('add_staff'))),
          ],
        ),
      ),
    );

    if (result == true &&
        nameCtl.text.trim().isNotEmpty &&
        userCtl.text.trim().isNotEmpty &&
        pinCtl.text.trim().length >= 4) {
      try {
        await AuthService.createStaffAccount(
          name: nameCtl.text.trim(),
          username: userCtl.text.trim(),
          pin: pinCtl.text.trim(),
          role: role,
        );
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(context.tr('username_taken'))));
        }
      }
    }
  }

  Future<void> _removeStaff(Staff staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('remove_staff_title')),
        content: Text('"${staff.name}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.tr('remove'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper.instance.deleteStaff(staff.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('staff_accounts'))),
      body: ListView.builder(
        itemCount: _staff.length,
        itemBuilder: (ctx, i) {
          final s = _staff[i];
          return ListTile(
            leading: CircleAvatar(
              child: Icon(s.role == StaffRole.admin ? Icons.admin_panel_settings : Icons.person),
            ),
            title: Text(s.name),
            subtitle: Text('@${s.username} • ${s.role == StaffRole.admin ? context.tr('admin_role') : context.tr('staff_role')}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeStaff(s),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: Text(context.tr('add_staff')),
        onPressed: _addStaff,
      ),
    );
  }
}
