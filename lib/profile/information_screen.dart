import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: Text(
          "Information",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              LineAwesomeIcons.info_circle,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              "GoGrabit App",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text("Version 1.0.0"),
            const SizedBox(height: 40),
            ListTile(
              title: const Text("Privacy Policy"),
              trailing: const Icon(LineAwesomeIcons.angle_right, size: 18),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text("Terms of Service"),
              trailing: const Icon(LineAwesomeIcons.angle_right, size: 18),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text("Third-Party Licenses"),
              trailing: const Icon(LineAwesomeIcons.angle_right, size: 18),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
