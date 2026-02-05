import 'package:flutter/material.dart';
import 'package:flutter_store_ui/screens/wishlist_item.dart';
import '../services/api.dart';
import 'product_details.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with TickerProviderStateMixin {
  late Future<List<WishlistItem>> _wishlistFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadWishlist();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadWishlist() {
    _wishlistFuture = Api.getWishlist();
  }

  Future<void> _toggleWishlist(int productId) async {
    await Api.toggleWishlist(productId);
    setState(() {
      _loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text(
          "Wishlist",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1E3F), Color(0xFF2A1E5D)],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<WishlistItem>>(
        future: _wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading your wishlist...",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final items = snapshot.data!;
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return _buildWishlistItem(item, i);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_outlined,
              size: 80,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Your wishlist is empty",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Tap the heart icon on products to save them here",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(WishlistItem item, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: item.product),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: item.product.image != null
                          ? DecorationImage(
                              image: NetworkImage(item.product.image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: item.product.image == null
                          ? const LinearGradient(
                              colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                            )
                          : null,
                    ),
                    child: item.product.image == null
                        ? const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (item.product.description?.isNotEmpty == true)
                          Text(
                            item.product.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (item.product.price != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            "\$${item.product.price!.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Remove Button
                  GestureDetector(
                    onTap: () => _toggleWishlist(item.product.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
