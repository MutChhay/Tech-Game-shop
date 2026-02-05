// NEW FILE: lib/screens/addresses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_store_ui/models/address.dart';
import 'package:flutter_store_ui/services/api.dart';
import 'addressesScreen.dart'; // Your map screen

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late Future<List<Address>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    _addressesFuture = Api.getUserAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Address>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No saved addresses yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAddressScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadAddresses(); // 🔄 REFRESH
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Address added!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Address"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.location_on, color: Colors.blue),
                  ),
                  title: Text(address.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${address.street}, ${address.city}"),
                      Text("${address.state} ${address.postalCode}"),
                      Text(address.country),
                      Text(
                        "Lat: ${address.latitude}, Lng: ${address.longitude}",
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.star,
                          color: address.isDefault ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () async {
                          await Api.setDefaultAddress(address.id.toString());
                          setState(() => _loadAddresses());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await Api.deleteAddress(address.id.toString());
                          setState(() => _loadAddresses());
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
