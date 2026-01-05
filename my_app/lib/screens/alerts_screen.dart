import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/database_service.dart';

class AlertsScreen extends StatelessWidget {
  final String deviceId = "ESP32_001"; // Hardcoded for now

  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<List<EventModel>>(
        stream: dbService.getRecentEvents(deviceId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No recent alerts",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getSeverityColor(event.severity),
                    child: Icon(_getEventIcon(event.type), color: Colors.white),
                  ),
                  title: Text(_formatEventType(event.type)),
                  subtitle: Text(
                    DateFormat('HH:mm dd/MM/yyyy').format(event.timestamp),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showEventDetails(context, event);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getEventIcon(String type) {
    if (type == 'RODENT_DETECTED') return Icons.pest_control_rodent;
    if (type == 'SYSTEM_START') return Icons.power_settings_new;
    return Icons.info;
  }

  String _formatEventType(String type) {
    return type.replaceAll('_', ' ');
  }

  void _showEventDetails(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Event Details",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text("Type: ${event.type}"),
            Text(
              "Time: ${DateFormat('HH:mm:ss dd/MM/yyyy').format(event.timestamp)}",
            ),
            Text("Severity: ${event.severity}"),
            if (event.metadata != null) ...[
              const SizedBox(height: 8),
              const Text(
                "Metadata:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...event.metadata!.entries.map(
                (e) => Text("${e.key}: ${e.value}"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
