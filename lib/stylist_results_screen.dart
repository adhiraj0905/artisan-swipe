// lib/stylist_results_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/product.dart'; // Import your product model

// --- STEP 1: CONVERT TO STATEFULWIDGET ---
class StylistResultsScreen extends StatefulWidget {
  final File userImage;
  final Function(ArtisanProduct) onAddToCart;
  final Function(ArtisanProduct) onAddToWishlist;

  const StylistResultsScreen({
    Key? key,
    required this.userImage,
    required this.onAddToCart,
    required this.onAddToWishlist,
  }) : super(key: key);

  @override
  _StylistResultsScreenState createState() => _StylistResultsScreenState();
}

class _StylistResultsScreenState extends State<StylistResultsScreen> {
  // --- FAKE PRODUCTS (using your real ArtisanProduct model) ---
  final List<ArtisanProduct> fakeProducts = [
    ArtisanProduct(id: '5', title: 'Handwoven Pashmina Shawl', description: 'A beautiful shawl.', price: 2500, imageUrls: ['assets/products/pashmina.jpg'], artist: Artist(id: 'art1', name: 'Ravi Kumar', bio: '', profileImageUrl: '', location: '', state: '', specialties: [], joinedDate: DateTime.now()), categories: [], technique: '', dimensions: {}, material: '', createdAt: DateTime.now(), tags: [], origin: 'Kashmir'),
    ArtisanProduct(id: '2', title: 'Blue Pottery Vase', description: 'A vibrant vase.', price: 800, imageUrls: ['assets/products/pottery.jpg'], artist: Artist(id: 'art2', name: 'Meera Sharma', bio: '', profileImageUrl: '', location: '', state: '', specialties: [], joinedDate: DateTime.now()), categories: [], technique: '', dimensions: {}, material: '', createdAt: DateTime.now(), tags: [], origin: 'Jaipur'),
    ArtisanProduct(id: '3', title: 'Carved Wooden Elephant', description: 'An intricate elephant statue.', price: 1500, imageUrls: ['assets/products/elephant.jpg'], artist: Artist(id: 'art3', name: 'Arjun Patel', bio: '', profileImageUrl: '', location: '', state: '', specialties: [], joinedDate: DateTime.now()), categories: [], technique: '', dimensions: {}, material: '', createdAt: DateTime.now(), tags: [], origin: 'Kerala'),
  ];

  final Map<String, String> fakeStylistNotes = {
    '5': "This shawl's warm, earthy tones will add a cozy and elegant touch to your sofa, complementing your room's natural light.",
    '2': "A vibrant splash of Jaipur blue will create a stunning focal point on your side table, breaking the monotony of the neutral walls.",
    '3': "The intricate craftsmanship of this wooden elephant adds a touch of traditional charm and sophistication to your empty corner shelf.",
  };

  // --- STEP 2: CREATE STATE VARIABLES ---
  // We use a Set for quick lookups to see if a product ID is already in the list.
  final Set<String> _addedToCartIds = {};
  final Set<String> _addedToWishlistIds = {};


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Stylist Recommendations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(widget.userImage), // Use widget.userImage to access it here
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Here's what our AI Stylist picked for your room:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              itemCount: fakeProducts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final product = fakeProducts[index];
                final note = fakeStylistNotes[product.id]!;
                return _buildRecommendationCard(product, note);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(ArtisanProduct product, String stylistNote) {
    // --- STEP 3: CHECK THE STATE ---
    final bool isInCart = _addedToCartIds.contains(product.id);
    final bool isInWishlist = _addedToWishlistIds.contains(product.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  product.primaryImageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$stylistNote"',
                      style: GoogleFonts.lora(
                        textStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // --- STEP 3 (continued): UPDATE WISHLIST BUTTON UI ---
              IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_outline,
                  color: isInWishlist ? Colors.redAccent : Colors.white70,
                ),
                tooltip: "Add to Wishlist",
                onPressed: () {
                  setState(() {
                    _addedToWishlistIds.add(product.id);
                  });
                  widget.onAddToWishlist(product);
                },
              ),
              const SizedBox(width: 8),
              // --- STEP 3 (continued): UPDATE CART BUTTON UI ---
              ElevatedButton(
                onPressed: isInCart ? null : () { // Disable button if already in cart
                  setState(() {
                    _addedToCartIds.add(product.id);
                  });
                  widget.onAddToCart(product);
                },
                child: Text(isInCart ? 'Added to Bag' : 'Add to Bag'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.grey[700] : const Color(0xFF7D3C98),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}