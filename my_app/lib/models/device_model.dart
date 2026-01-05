import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final bool isOnline;
  final bool isRepellerActive;
  final DateTime lastSeen;
  final String? name;

  DeviceModel({
    required this.id,
    required this.isOnline,
    required this.isRepellerActive,
    required this.lastSeen,
    this.name,
  });

  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceModel(
      id: doc.id,
      isOnline: data['isOnline'] ?? false,
      isRepellerActive: data['isRepellerActive'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: data['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isOnline': isOnline,
      'isRepellerActive': isRepellerActive,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'name': name,
    };
  }
}
