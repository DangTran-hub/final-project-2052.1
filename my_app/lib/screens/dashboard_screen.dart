import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/device_model.dart';
import '../services/database_service.dart';

class DashboardScreen extends StatelessWidget {
  // In a real app, this ID would come from the user's selected device or profile
  final String deviceId = "ESP32_001";

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
      body: StreamBuilder<DeviceModel>(
        stream: dbService.getDeviceStream(deviceId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final device = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildConnectionStatus(device),
                const SizedBox(height: 20),
                _buildRepellerControl(context, dbService, device),
                const SizedBox(height: 20),
                _buildInfoCard(device),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(DeviceModel device) {
    final isOnline = device.isOnline;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              size: 64,
              color: isOnline ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isOnline ? "Device Online" : "Device Offline",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isOnline ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Last update: ${DateFormat('HH:mm:ss dd/MM/yyyy').format(device.lastSeen)}",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepellerControl(
    BuildContext context,
    DatabaseService db,
    DeviceModel device,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.surround_sound, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Repelling System",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                device.isRepellerActive ? "Active" : "Inactive",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Ultrasonic waves emission"),
              value: device.isRepellerActive,
              activeThumbColor: Colors.blue,
              onChanged: (bool value) {
                db.toggleRepeller(device.id, value);
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: device.isRepellerActive
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volume_up,
                  color: device.isRepellerActive ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(DeviceModel device) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.perm_device_information,
              "Device ID",
              device.id,
            ),
            const Divider(),
            _buildInfoRow(Icons.battery_std, "Power Source", "External (12V)"),
            const Divider(),
            _buildInfoRow(Icons.system_update, "Firmware", "v1.0.2"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
