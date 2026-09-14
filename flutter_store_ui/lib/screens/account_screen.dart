import 'package:flutter/material.dart';
import '../../services/api.dart';
import 'login.dart';
import 'admin/admin_products_screen.dart';
import '../../state/theme_state.dart';
import 'admin/admin_orders_screen.dart';
import '../../models/address.dart';
import 'addresses_screen.dart';
import 'AddaddressesScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMe();
  }

  Future<void> loadMe() async {
    try {
      final me = await Api.me();
      if (mounted) {
        setState(() {
          user = me;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ✅ SHARED SECTION CARD - Used by both AccountScreen & AddressesSection
  Widget sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.indigo, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "Not logged in",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: loadMe, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    final isAdmin = user!['role'] == 'admin';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Account",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: loadMe),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _heroProfileCard(),
            const SizedBox(height: 32),
            // if (isAdmin) ...[_adminStatsRow(), const SizedBox(height: 32)],
            sectionCard(
              title: "Account Information",
              icon: Icons.person_outline,
              children: [
                _infoTile(Icons.person, "Name", user!['name']),
                _infoTile(Icons.email, "Email", user!['email']),
                _infoTile(Icons.badge, "Role", _formatRole(user!['role'])),
                if (user!['phone'] != null)
                  _infoTile(Icons.phone, "Phone", user!['phone']),
              ],
            ),
            const SizedBox(height: 24),
            sectionCard(
              title: "Preferences",
              icon: Icons.settings_outlined,
              children: [_darkModeTile()],
            ),
            const SizedBox(height: 24),

            // ✅ ADDRESSES SECTION - Shows saved addresses below title
            const AddressesSection(),

            if (isAdmin) ...[_adminPanelCard(), const SizedBox(height: 32)],
            _logoutButton(),
          ],
        ),
      ),
    );
  }

  // ==================== HERO PROFILE ====================
  Widget _heroProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade50, Colors.white]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade300, Colors.purple.shade300],
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 31,
                backgroundColor: Colors.indigo.shade600,
                child: Text(
                  user!['name'].toString().isNotEmpty
                      ? user!['name'].toString()[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              user!['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user!['role'] == 'admin') ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "ADMIN",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  user!['email'],
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatJoinDate(user!['created_at']),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: loadMe,
          ),
        ],
      ),
    );
  }

  // ==================== PREFERENCES ====================
  Widget _darkModeTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: themeState.isDark
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              themeState.isDark ? Icons.dark_mode : Icons.light_mode,
              size: 16,
              color: themeState.isDark ? Colors.orange : Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dark Mode",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  themeState.isDark ? "Moonlit interface" : "Sunny interface",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: themeState.isDark,
              onChanged: (_) => themeState.toggle(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ADMIN ====================
  // Widget _adminStatsRow() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _statCard(
  //           "Products",
  //           "1,247",
  //           Icons.inventory_2,
  //           Colors.indigo,
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: _statCard("Orders", "89", Icons.shopping_cart, Colors.green),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: _statCard(
  //           "Revenue",
  //           "\$24.7K",
  //           Icons.attach_money,
  //           Colors.orange,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 15, 12, 12).withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ADMIN PANEL ====================
  Widget _adminPanelCard() {
    return sectionCard(
      title: "Admin Control Panel",
      icon: Icons.admin_panel_settings_outlined,
      children: [
        _navTile(
          icon: Icons.inventory_2,
          title: "Products",
          subtitle: "Manage products & inventory",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminProductsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _navTile(
          icon: Icons.receipt_long,
          title: "Orders",
          subtitle: "View & manage orders",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
          ),
        ),
      ],
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LOGOUT ====================
  Widget _logoutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      "Sign Out?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: const Text("You will need to log in again."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Stay"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Sign Out"),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await Api.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HELPERS ====================
  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'user':
        return 'Customer';
      default:
        return role
            .toString()
            .split(' ')
            .map((e) => e[0].toUpperCase() + e.substring(1))
            .join(' ');
    }
  }

  String _formatJoinDate(String? date) {
    if (date == null) return 'Unknown';
    try {
      final parsed = DateTime.parse(date);
      return 'Member since ${parsed.day}/${parsed.month}/${parsed.year}';
    } catch (_) {
      return 'Member since ${date.split(' ')[0]}';
    }
  }
}

// ==================== ✅ FIXED ADDRESSES SECTION ====================
class AddressesSection extends StatefulWidget {
  const AddressesSection({super.key});

  @override
  State<AddressesSection> createState() => _AddressesSectionState();
}

class _AddressesSectionState extends State<AddressesSection> {
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.indigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Saved Addresses",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                FutureBuilder<List<Address>>(
                  future: _addressesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final addresses = snapshot.data ?? [];

                    if (addresses.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No saved addresses yet.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: addresses
                          .map(
                            (address) => AddressCard(
                              key: ValueKey(address.id),
                              address: address,
                              onDeleted: () => setState(() => _loadAddresses()),
                              onSetDefault: () =>
                                  setState(() => _loadAddresses()),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                // Manage addresses buttons
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressesScreen(),
                      ),
                    );
                    if (result == true) {
                      setState(() => _loadAddresses());
                    }
                  },
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text("Manage Addresses"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),

                // add new address button location
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddAddressScreen(),
                      ),
                    );
                    if (result == true) {
                      setState(() => _loadAddresses());
                    }
                  },
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text("Add New Address"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback? onDeleted;
  final VoidCallback? onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    this.onDeleted,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.location_on, color: Colors.blue),
        ),
        title: Text(
          address.name ?? "Home",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${address.street}, ${address.city}"),
            Text("${address.state} ${address.postalCode}"),
            Text(address.country),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Open in Google Maps',
              icon: const Icon(Icons.map, color: Colors.green),
              onPressed: () async {
                final query =
                    address.latitude != 0.0 && address.longitude != 0.0
                    ? '${address.latitude},${address.longitude}'
                    : '${address.street}, ${address.city}, ${address.state}, ${address.country}';
                final uri = Uri.https('www.google.com', '/maps/search/', {
                  'api': '1',
                  'query': query,
                });
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.star,
                color: address.isDefault ? Colors.amber : Colors.grey,
                size: 20,
              ),
              onPressed: onSetDefault,
              tooltip: "Set as default",
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDeleted,
              tooltip: "Delete address",
            ),
          ],
        ),
      ),
    );
  }
}
