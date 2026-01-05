class Vehicle {
  final String? id;
  final String type;
  final String color;
  final String licensePlate;
  final String? description;

  Vehicle({
    this.id,
    required this.type,
    required this.color,
    required this.licensePlate,
    this.description,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      type: json['type'] ?? '',
      color: json['color'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'color': color,
      'licensePlate': licensePlate,
      'description': description,
    };
  }
}
