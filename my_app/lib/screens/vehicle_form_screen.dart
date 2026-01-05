import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle; // Nếu null là thêm mới, có giá trị là sửa

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _descController = TextEditingController();
  final _vehicleService = VehicleService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _typeController.text = widget.vehicle!.type;
      _colorController.text = widget.vehicle!.color;
      _plateController.text = widget.vehicle!.licensePlate;
      _descController.text = widget.vehicle!.description ?? '';
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final vehicle = Vehicle(
      type: _typeController.text,
      color: _colorController.text,
      licensePlate: _plateController.text,
      description: _descController.text,
    );

    try {
      if (widget.vehicle == null) {
        await _vehicleService.addVehicle(vehicle);
      } else {
        await _vehicleService.updateVehicle(widget.vehicle!.id!, vehicle);
      }

      if (mounted) {
        Navigator.pop(context, true); // Trả về true để reload list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicle == null ? 'Thêm Phương Tiện' : 'Sửa Phương Tiện',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Loại xe (VD: Xe máy, Ô tô)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập loại xe' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Màu sắc'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập màu sắc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(labelText: 'Biển số'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập biển số' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả thêm (Tùy chọn)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveVehicle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.vehicle == null ? 'Thêm Mới' : 'Cập Nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
