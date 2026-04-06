import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: Text(
          "User Management",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LineAwesomeIcons.users, color: Colors.purple),
              ),
              title: Text(
                "Manage Accounts",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: const Text("Linked accounts and family members"),
              trailing: const Icon(LineAwesomeIcons.angle_right, size: 18),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LineAwesomeIcons.map_marker,
                  color: Colors.red,
                ),
              ),
              title: Text(
                "Saved Addresses",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: const Text("Manage delivery locations"),
              trailing: const Icon(LineAwesomeIcons.angle_right, size: 18),
              onTap: () {},
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
