import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api.dart';
import '../../models/category.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen>
    with SingleTickerProviderStateMixin {
  // 📝 BASIC FIELDS
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // 🔥 LAPTOP SPECS FIELDS
  final cpuCtrl = TextEditingController();
  final ramCtrl = TextEditingController();
  final storageCtrl = TextEditingController();
  final gpuCtrl = TextEditingController();
  final displayCtrl = TextEditingController();
  final batteryCtrl = TextEditingController();
  final warrantyCtrl = TextEditingController();

  // Categories
  List<Category> categories = [];
  List<Category> selectedCategories = [];
  bool loadingCategories = true;

  File? image;
  bool loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    // 🔥 DISPOSE ALL CONTROLLERS
    nameCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    descCtrl.dispose();
    cpuCtrl.dispose();
    ramCtrl.dispose();
    storageCtrl.dispose();
    gpuCtrl.dispose();
    displayCtrl.dispose();
    batteryCtrl.dispose();
    warrantyCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await Api.getCategories();
      setState(() {
        categories = list;
        loadingCategories = false;
      });
    } catch (e) {
      setState(() => loadingCategories = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Load categories failed: $e")));
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future<void> submit() async {
    // Validation
    if (nameCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty ||
        stockCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one category")),
      );
      return;
    }

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select product image")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await Api.addProduct(
        name: nameCtrl.text.trim(),
        price: double.parse(priceCtrl.text),
        stock: int.parse(stockCtrl.text),
        description: descCtrl.text.trim().isNotEmpty
            ? descCtrl.text.trim()
            : null,
        image: image!,
        categoryId: selectedCategories.first.id,
        // 🔥 LAPTOP SPECS
        cpu: cpuCtrl.text.trim().isNotEmpty ? cpuCtrl.text.trim() : null,
        ram: ramCtrl.text.trim().isNotEmpty ? ramCtrl.text.trim() : null,
        storage: storageCtrl.text.trim().isNotEmpty
            ? storageCtrl.text.trim()
            : null,
        gpu: gpuCtrl.text.trim().isNotEmpty ? gpuCtrl.text.trim() : null,
        display: displayCtrl.text.trim().isNotEmpty
            ? displayCtrl.text.trim()
            : null,
        battery: batteryCtrl.text.trim().isNotEmpty
            ? batteryCtrl.text.trim()
            : null,
        warranty: warrantyCtrl.text.trim().isNotEmpty
            ? warrantyCtrl.text.trim()
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Product added successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear form
      nameCtrl.clear();
      priceCtrl.clear();
      stockCtrl.clear();
      descCtrl.clear();
      cpuCtrl.clear();
      ramCtrl.clear();
      storageCtrl.clear();
      gpuCtrl.clear();
      displayCtrl.clear();
      batteryCtrl.clear();
      warrantyCtrl.clear();
      setState(() {
        image = null;
        selectedCategories.clear();
      });
      Navigator.pop(context,true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Add New Product",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎯 HEADER
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade50, Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 48,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Add Product",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fill in all details to create new product",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 📝 BASIC FORM FIELDS
              _buildFormField(
                controller: nameCtrl,
                label: "Product Name *",
                icon: Icons.inventory_2,
                hint: "Enter product name",
              ),
              const SizedBox(height: 20),

              _buildFormField(
                controller: priceCtrl,
                label: "Price *",
                icon: Icons.attach_money,
                hint: "0.00",
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),

              _buildFormField(
                controller: stockCtrl,
                label: "Stock Quantity *",
                icon: Icons.inventory,
                hint: "0",
                keyboard: const TextInputType.numberWithOptions(decimal: false),
              ),
              const SizedBox(height: 20),

              _buildFormField(
                controller: descCtrl,
                label: "Description",
                icon: Icons.description,
                hint: "Enter product description",
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // 🏷 CATEGORY
              _buildCategoryField(),
              const SizedBox(height: 24),

              // 🖼 IMAGE UPLOAD
              _buildImageUpload(),
              const SizedBox(height: 32),

              // 🔥 LAPTOP SPECS SECTION
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.indigo.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade300,
                                Colors.blue.shade500,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.laptop_mac,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          " Laptop Specifications",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 🔥 CPU & RAM
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: cpuCtrl,
                            label: "CPU",
                            icon: Icons.speed, // ✅ FIXED
                            hint: "Intel Core i5 / Ryzen 5",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            controller: ramCtrl,
                            label: "RAM",
                            icon: Icons.memory,
                            hint: "16 GB",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔥 Storage & GPU
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: storageCtrl,
                            label: "Storage",
                            icon: Icons.storage,
                            hint: "512 GB SSD",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            controller: gpuCtrl,
                            label: "GPU",
                            icon: Icons.videogame_asset,
                            hint: "NVIDIA GTX / Integrated",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔥 Display & Battery
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: displayCtrl,
                            label: "Display",
                            icon: Icons.monitor,
                            hint: "15.6\" FHD",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            controller: batteryCtrl,
                            label: "Battery",
                            icon: Icons.battery_full,
                            hint: "6–8 hours",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔥 Warranty
                    _buildFormField(
                      controller: warrantyCtrl,
                      label: "Warranty",
                      icon: Icons.security,
                      hint: "1 Year",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 🚀 SUBMIT BUTTON
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.indigo.withOpacity(0.3),
                  ),
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Adding Product...",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : const Text(
                          "Add Product",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📐 REUSABLE FORM FIELD
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.indigo, size: 24),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 0,
          ),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  // 🏷 CATEGORY FIELD
  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories *",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: loadingCategories
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // 🔥 MAIN DROPDOWN
                    DropdownButtonFormField<Category>(
                      value: selectedCategories.isEmpty
                          ? null
                          : selectedCategories.first,
                      hint: const Text("Select primary category"),
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Primary Category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (Category? newValue) {
                        if (newValue != null) {
                          setState(() {
                            if (!selectedCategories.contains(newValue)) {
                              selectedCategories.add(newValue);
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 🔥 MULTI-SELECT CHIPS (Beautiful!)
                    if (selectedCategories.isNotEmpty) ...[
                      const Text(
                        "Selected:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedCategories.map((category) {
                          return FilterChip(
                            label: Text(category.name),
                            selected: true,
                            onSelected: (_) {
                              setState(() {
                                selectedCategories.remove(category);
                              });
                            },
                            selectedColor: Colors.indigo.shade100,
                            checkmarkColor: Colors.indigo,
                            backgroundColor: Colors.indigo.shade50,
                            elevation: 2,
                            shadowColor: Colors.indigo.withOpacity(0.3),
                          );
                        }).toList(),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "No categories selected",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }


  // 🖼 IMAGE UPLOAD
  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, color: Colors.orange, size: 28),
            ),
            const SizedBox(width: 16),
            const Text(
              "Product Image *",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: image != null
                    ? Colors.green.shade300
                    : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate,
                          size: 56,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Tap to select product image",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "JPG, PNG up to 5MB",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
