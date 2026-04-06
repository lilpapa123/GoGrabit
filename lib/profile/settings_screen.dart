import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_grabit/providers/currency_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailUpdates = false;
  String _selectedLanguage = "English";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _emailUpdates = prefs.getBool('email_updates') ?? false;
      _selectedLanguage = prefs.getString('language') ?? "English";
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: Text(
          "Settings",
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LineAwesomeIcons.bell, color: Colors.blue),
              ),
              title: Text(
                "Push Notifications",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                  _updateSetting('notifications_enabled', val);
                },
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LineAwesomeIcons.envelope,
                  color: Colors.green,
                ),
              ),
              title: Text(
                "Email Updates",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: Switch(
                value: _emailUpdates,
                onChanged: (val) {
                  setState(() => _emailUpdates = val);
                  _updateSetting('email_updates', val);
                },
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LineAwesomeIcons.globe, color: Colors.orange),
              ),
              title: Text(
                "Language",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: Text(
                _selectedLanguage,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text("Select Language"),
                    children: ["English", "Turkish", "Arabic", "French"].map((
                      lang,
                    ) {
                      return SimpleDialogOption(
                        onPressed: () {
                          setState(() => _selectedLanguage = lang);
                          _updateSetting('language', lang);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(lang),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LineAwesomeIcons.money_bill,
                      color: Colors.purple,
                    ),
                  ),
                  title: Text(
                    "Currency",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: Text(
                    currencyProvider.currencyCode == 'TL'
                        ? "Turkish Lira (₺)"
                        : "USD (\$)",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text("Select Currency"),
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              currencyProvider.setCurrency('TL');
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text("Turkish Lira (TL)"),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              currencyProvider.setCurrency('USD');
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text("USD (\$)"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
