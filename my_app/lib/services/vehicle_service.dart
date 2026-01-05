import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class VehicleService {
  // Thay đổi IP này thành IP máy tính của bạn (192.168.15.19)
  static const String baseUrl = 'http://192.168.15.19:3001/api/vehicles';

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Vehicle.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load vehicles');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicle.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add vehicle');
      }
    } catch (e) {
      throw Exception('Error adding vehicle: $e');
    }
  }

  Future<void> updateVehicle(String id, Vehicle vehicle) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicle.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update vehicle');
      }
    } catch (e) {
      throw Exception('Error updating vehicle: $e');
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete vehicle');
      }
    } catch (e) {
      throw Exception('Error deleting vehicle: $e');
    }
  }
}
