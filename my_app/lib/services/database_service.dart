import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_model.dart';
import '../models/event_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Device Methods ---

  // Stream of a specific device's data
  Stream<DeviceModel> getDeviceStream(String deviceId) {
    return _db.collection('devices').doc(deviceId).snapshots().map((doc) {
      if (!doc.exists) {
        // Return a default/empty model if document doesn't exist yet
        return DeviceModel(
          id: deviceId,
          isOnline: false,
          isRepellerActive: false,
          lastSeen: DateTime.now(),
        );
      }
      return DeviceModel.fromFirestore(doc);
    });
  }

  // Toggle the repeller status
  Future<void> toggleRepeller(String deviceId, bool isActive) async {
    await _db.collection('devices').doc(deviceId).set({
      'isRepellerActive': isActive,
    }, SetOptions(merge: true));
  }

  // --- Event Methods ---

  // Stream of recent events for a device
  Stream<List<EventModel>> getRecentEvents(String deviceId) {
    return _db
        .collection('events')
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get daily detection count for the last 7 days (for History)
  Future<Map<String, int>> getWeeklyStats(String deviceId) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final querySnapshot = await _db
        .collection('events')
        .where('deviceId', isEqualTo: deviceId)
        .where('type', isEqualTo: 'RODENT_DETECTED')
        .where('timestamp', isGreaterThan: sevenDaysAgo)
        .get();

    Map<String, int> stats = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final dateKey = "${timestamp.day}/${timestamp.month}";

      stats[dateKey] = (stats[dateKey] ?? 0) + 1;
    }

    return stats;
  }
}
