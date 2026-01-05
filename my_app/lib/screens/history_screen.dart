import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatelessWidget {
  final String deviceId = "ESP32_001";

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<Map<String, int>>(
        future: dbService.getWeeklyStats(deviceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading stats"));
          }

          final stats = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Weekly Detection Stats",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildChart(stats),
                const SizedBox(height: 24),
                Text(
                  "History Log",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text("Use Alerts tab for detailed recent events."),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(Map<String, int> stats) {
    if (stats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text("No detection data for the last 7 days")),
        ),
      );
    }

    // Simple bar chart visualization using Rows/Containers
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: stats.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 50, child: Text(entry.key)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / 10.0, // Assuming max 10 for scale
                      backgroundColor: Colors.grey[200],
                      color: Colors.orange,
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("${entry.value}"),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
