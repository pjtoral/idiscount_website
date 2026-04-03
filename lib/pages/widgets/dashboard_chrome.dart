import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userEmail;
  final VoidCallback onLogoutTap;

  const DashboardAppBar({
    super.key,
    required this.userEmail,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Dashboard'),
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(userEmail, style: const TextStyle(fontSize: 14)),
          ),
        ),
        IconButton(icon: const Icon(Icons.logout), onPressed: onLogoutTap),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DashboardWelcomeHeader extends StatelessWidget {
  final String userEmail;

  const DashboardWelcomeHeader({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(userEmail, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

Future<void> showDashboardLogoutDialog(
  BuildContext context, {
  required VoidCallback onConfirmLogout,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirmLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
