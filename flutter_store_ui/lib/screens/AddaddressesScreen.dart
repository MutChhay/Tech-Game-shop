import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_store_ui/models/address.dart';
import '../services/api.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPoint;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Home');
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalController = TextEditingController();
  final _countryController = TextEditingController();

  // 🔴 CHANGE THIS TO YOUR REAL API
  static const String baseUrl = 'http://10.0.2.2:8000';
  // real device example: http://192.168.1.5:8000

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // ================= MAP TAP =================
  Future<void> _onMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() => _selectedPoint = point);
    _mapController.move(point, 16);

    final url =
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=${point.latitude}'
        '&lon=${point.longitude}'
        '&addressdetails=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterStoreApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = _parseAddress(data);

        setState(() {
          _streetController.text = address.street;
          _cityController.text = address.city;
          _stateController.text = address.state;
          _postalController.text = address.postalCode;
          _countryController.text = address.country;
        });
      }
    } catch (_) {}
  }

  Address _parseAddress(Map<String, dynamic> data) {
    final addr = data['address'] ?? {};

    // 🔥 SAFE PARSING - FIXES YOUR ERROR
    final latStr = data['lat']?.toString() ?? '0.0';
    final lonStr = data['lon']?.toString() ?? '0.0';

    return Address(
      id: 0,
      name: 'Home',
      street:
          addr['road'] ??
          addr['pedestrian'] ??
          addr['neighbourhood'] ??
          'Unknown Street',
      city: addr['city'] ?? addr['town'] ?? addr['village'] ?? 'Unknown City',
      state: addr['state'] ?? '',
      postalCode: addr['postcode'] ?? '',
      country: addr['country'] ?? '',
      isDefault: false,
      latitude: double.tryParse(latStr) ?? 0.0, // ✅ FIXED
      longitude: double.tryParse(lonStr) ?? 0.0, // ✅ FIXED
    );
  }


  // ================= SAVE ADDRESS =================
Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate() || _selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select location and fill all fields')),
      );
      return;
    }

    try {
      final addressData = {
        'name': _nameController.text,
        'street': _streetController.text,
        'city': _cityController.text,
        'state': _stateController.text.isEmpty ? 'N/A' : _stateController.text,
        'postal_code': _postalController.text,
        'country': _countryController.text,
        'lat': _selectedPoint!.latitude, // ✅ Laravel accepts numeric
        'lng': _selectedPoint!.longitude,
      };

      // 🔥 USE YOUR API CLASS - handles token automatically
      await Api.addAddress(addressData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Address saved successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(11.5564, 104.9282),
                initialZoom: 12,
                minZoom: 3,
                maxZoom: 19,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) => _onMapTap(tapPosition, point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_store_ui',
                ),
                if (_selectedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _field(_nameController, 'Name'),
                      _field(_streetController, 'Street'),
                      Row(
                        children: [
                          Expanded(child: _field(_cityController, 'City')),
                          const SizedBox(width: 12),
                          Expanded(child: _field(_postalController, 'Postal')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _field(_stateController, 'State')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(_countryController, 'Country'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveAddress,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Save Address'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$label *',
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v == null || v.isEmpty ? '$label required' : null,
      ),
    );
  }
}
