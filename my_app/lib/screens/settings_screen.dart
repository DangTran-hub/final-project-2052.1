import 'package:flutter/material.dart';
import 'vehicle_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoRepelEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildSectionHeader("Device Settings"),
          ListTile(
            leading: const Icon(Icons.perm_device_information),
            title: const Text("Device ID"),
            subtitle: const Text("ESP32_001"),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Device ID copied")),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text("Firmware Version"),
            subtitle: const Text("v1.0.2"),
            trailing: const Chip(
              label: Text("Up to date"),
              backgroundColor: Colors.greenAccent,
            ),
          ),

          _buildSectionHeader("Preferences"),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive alerts when rodent detected"),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.autorenew),
            title: const Text("Auto-Repelling Mode"),
            subtitle: const Text(
              "Automatically activate repeller on detection",
            ),
            value: _autoRepelEnabled,
            onChanged: (val) {
              setState(() => _autoRepelEnabled = val);
            },
          ),

          _buildSectionHeader("Management"),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text("Vehicle Management"),
            subtitle: const Text("Manage registered vehicles"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VehicleListScreen(),
                ),
              );
            },
          ),

          _buildSectionHeader("Account"),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
            onTap: () {
              // Handle sign out
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
