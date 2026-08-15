import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_provider.dart';
import '../services/locale_provider.dart';
import 'inventory_list_screen.dart';
import 'pos_screen.dart';
import 'sales_history_screen.dart';
import 'staff_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('log_out_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.tr('log_out'))),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<SessionProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final staff = session.currentStaff;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app_name')),
        actions: [
          TextButton(
            onPressed: () => context.read<LocaleProvider>().toggle(),
            child: Text(
              localeProvider.isArabic ? 'EN' : 'AR',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (session.isAdmin)
            IconButton(
              icon: const Icon(Icons.manage_accounts),
              tooltip: context.tr('staff_accounts'),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const StaffManagementScreen())),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.tr('log_out'),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (staff != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('${context.tr('hi')}, ${staff.name} 👋',
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _MenuCard(
                  icon: Icons.inventory_2_outlined,
                  label: context.tr('inventory'),
                  color: Colors.green,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InventoryListScreen())),
                ),
                _MenuCard(
                  icon: Icons.point_of_sale,
                  label: context.tr('new_sale'),
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const POSScreen())),
                ),
                _MenuCard(
                  icon: Icons.receipt_long,
                  label: context.tr('sales_history'),
                  color: Colors.orange,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SalesHistoryScreen())),
                ),
                _MenuCard(
                  icon: Icons.qr_code_scanner,
                  label: context.tr('quick_scan'),
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const POSScreen(startWithScanner: true))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
