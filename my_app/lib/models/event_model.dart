import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String deviceId;
  final String type;
  final String severity;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  EventModel({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.metadata,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      deviceId: data['deviceId'] ?? '',
      type: data['type'] ?? 'UNKNOWN',
      severity: data['severity'] ?? 'info',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}
