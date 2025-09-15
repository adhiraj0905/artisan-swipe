// services/product_service.dart

import 'dart:async';
import 'dart:math';
import '../models/product.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  // Simulate network delay
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
  }

  // Sample artists data
  static final List<Artist> _sampleArtists = [
    Artist(
      id: 'artist_1',
      name: 'Ravi Kumar',
      bio: 'Master potter from Khurja, specializing in traditional blue pottery and contemporary ceramic art. Third generation artisan carrying forward family traditions.',
      profileImageUrl: 'assets/artists/ravi_kumar.jpg',
      location: 'Khurja, Uttar Pradesh',
      state: 'Uttar Pradesh',
      specialties: ['Blue Pottery', 'Ceramics', 'Traditional Pottery'],
      yearsOfExperience: 25,
      rating: 4.8,
      totalProducts: 45,
      totalSales: 1200,
      joinedDate: DateTime(2022, 3, 15),
      isVerified: true,
    ),
    Artist(
      id: 'artist_2',
      name: 'Meera Sharma',
      bio: 'Textile artist from Jaipur creating exquisite block-printed fabrics and traditional Rajasthani embroidery work with modern contemporary designs.',
      profileImageUrl: 'assets/artists/meera_sharma.jpg',
      location: 'Jaipur, Rajasthan',
      state: 'Rajasthan',
      specialties: ['Block Printing', 'Embroidery', 'Textile Design'],
      yearsOfExperience: 18,
      rating: 4.9,
      totalProducts: 67,
      totalSales: 2100,
      joinedDate: DateTime(2021, 8, 20),
      isVerified: true,
    ),
    Artist(
      id: 'artist_3',
      name: 'Arjun Patel',
      bio: 'Wood craftsman from Gujarat specializing in intricate carved furniture and decorative wooden artifacts using traditional Gujarati techniques.',
      profileImageUrl: 'assets/artists/arjun_patel.jpg',
      location: 'Ahmedabad, Gujarat',
      state: 'Gujarat',
      specialties: ['Wood Carving', 'Furniture', 'Decorative Arts'],
      yearsOfExperience: 22,
      rating: 4.7,
      totalProducts: 32,
      totalSales: 800,
      joinedDate: DateTime(2022, 1, 10),
      isVerified: true,
    ),
    Artist(
      id: 'artist_4',
      name: 'Lakshmi Devi',
      bio: 'Master weaver from Kerala creating traditional Kasavu sarees and contemporary handloom textiles with golden threads.',
      profileImageUrl: 'assets/artists/lakshmi_devi.jpg',
      location: 'Kochi, Kerala',
      state: 'Kerala',
      specialties: ['Handloom', 'Kasavu Sarees', 'Traditional Weaving'],
      yearsOfExperience: 30,
      rating: 4.9,
      totalProducts: 28,
      totalSales: 950,
      joinedDate: DateTime(2021, 12, 5),
      isVerified: true,
    ),
    Artist(
      id: 'artist_5',
      name: 'Suresh Chandra',
      bio: 'Metal craft specialist from Moradabad, known for intricate brass work and contemporary metal sculptures combining traditional techniques.',
      profileImageUrl: 'assets/artists/suresh_chandra.jpg',
      location: 'Moradabad, Uttar Pradesh',
      state: 'Uttar Pradesh',
      specialties: ['Brass Work', 'Metal Craft', 'Sculptures'],
      yearsOfExperience: 20,
      rating: 4.6,
      totalProducts: 38,
      totalSales: 650,
      joinedDate: DateTime(2022, 5, 18),
      isVerified: false,
    ),
  ];

  // Sample products data
  static final List<ArtisanProduct> _sampleProducts = [
    ArtisanProduct(
      id: 'product_1',
      title: 'Blue Pottery Vase Set',
      description: 'Handcrafted set of three ceramic vases in traditional Khurja blue pottery style. Each vase features intricate floral patterns and is perfect for modern home decor.',
      price: 2500,
      imageUrls: ['assets/products/blue_pottery_1.jpg', 'assets/products/blue_pottery_2.jpg'],
      artist: _sampleArtists[0],
      categories: ['Pottery', 'Home Decor', 'Ceramics'],
      technique: 'Hand-thrown and painted',
      dimensions: {'height': '25cm', 'width': '15cm', 'depth': '15cm'},
      material: 'Ceramic clay, natural pigments',
      createdAt: DateTime(2024, 8, 15),
      viewCount: 1250,
      rating: 4.8,
      reviewCount: 23,
      tags: ['blue pottery', 'vase', 'home decor', 'traditional'],
      origin: 'Khurja, Uttar Pradesh',
    ),
    ArtisanProduct(
      id: 'product_2',
      title: 'Block Printed Cotton Dupatta',
      description: 'Elegant hand block-printed dupatta in vibrant Rajasthani style. Made with premium cotton and natural dyes, featuring traditional paisley and floral motifs.',
      price: 1800,
      imageUrls: ['assets/products/dupatta_1.jpg', 'assets/products/dupatta_2.jpg'],
      artist: _sampleArtists[1],
      categories: ['Textiles', 'Fashion', 'Handloom'],
      technique: 'Hand block printing',
      dimensions: {'length': '220cm', 'width': '100cm'},
      material: 'Premium cotton, natural dyes',
      createdAt: DateTime(2024, 9, 1),
      viewCount: 890,
      rating: 4.9,
      reviewCount: 31,
      tags: ['block print', 'dupatta', 'cotton', 'rajasthani'],
      origin: 'Jaipur, Rajasthan',
    ),
    ArtisanProduct(
      id: 'product_3',
      title: 'Carved Wooden Jewelry Box',
      description: 'Intricately carved wooden jewelry box with traditional Gujarati motifs. Features multiple compartments and mirror inside. Perfect for storing precious accessories.',
      price: 3200,
      imageUrls: ['assets/products/wooden_box_1.jpg', 'assets/products/wooden_box_2.jpg'],
      artist: _sampleArtists[2],
      categories: ['Woodwork', 'Jewelry Box', 'Home Accessories'],
      technique: 'Hand carving',
      dimensions: {'height': '12cm', 'width': '25cm', 'depth': '18cm'},
      material: 'Teak wood, brass fittings',
      createdAt: DateTime(2024, 8, 28),
      viewCount: 567,
      rating: 4.7,
      reviewCount: 18,
      tags: ['wooden', 'carved', 'jewelry box', 'gujarati'],
      origin: 'Ahmedabad, Gujarat',
    ),
    ArtisanProduct(
      id: 'product_4',
      title: 'Traditional Kasavu Saree',
      description: 'Pure handloom Kasavu saree with golden border, woven in traditional Kerala style. Made with finest cotton threads and real gold zari work.',
      price: 8500,
      imageUrls: ['assets/products/kasavu_1.jpg', 'assets/products/kasavu_2.jpg'],
      artist: _sampleArtists[3],
      categories: ['Handloom', 'Saree', 'Traditional Wear'],
      technique: 'Handloom weaving',
      dimensions: {'length': '550cm', 'width': '120cm'},
      material: 'Cotton, gold zari',
      createdAt: DateTime(2024, 8, 10),
      viewCount: 2100,
      rating: 4.9,
      reviewCount: 45,
      tags: ['kasavu', 'saree', 'handloom', 'kerala', 'gold'],
      origin: 'Kochi, Kerala',
    ),
    ArtisanProduct(
      id: 'product_5',
      title: 'Brass Decorative Elephant',
      description: 'Hand-engraved brass elephant sculpture with intricate traditional patterns. Brings good luck and prosperity according to Vastu shastra.',
      price: 1500,
      imageUrls: ['assets/products/brass_elephant_1.jpg', 'assets/products/brass_elephant_2.jpg'],
      artist: _sampleArtists[4],
      categories: ['Metal Craft', 'Sculpture', 'Home Decor'],
      technique: 'Hand engraving on brass',
      dimensions: {'height': '18cm', 'width': '22cm', 'depth': '10cm'},
      material: 'Pure brass',
      createdAt: DateTime(2024, 9, 5),
      viewCount: 750,
      rating: 4.6,
      reviewCount: 12,
      tags: ['brass', 'elephant', 'sculpture', 'home decor'],
      origin: 'Moradabad, Uttar Pradesh',
    ),
    ArtisanProduct(
      id: 'product_6',
      title: 'Ceramic Tea Set - Blue & White',
      description: 'Complete ceramic tea set with traditional blue and white patterns. Set includes teapot, 4 cups, saucers, and serving tray.',
      price: 3800,
      imageUrls: ['assets/products/tea_set_1.jpg', 'assets/products/tea_set_2.jpg'],
      artist: _sampleArtists[0],
      categories: ['Pottery', 'Ceramics', 'Kitchenware'],
      technique: 'Ceramic molding and glazing',
      dimensions: {'set': 'Complete tea service for 4'},
      material: 'Ceramic, food-safe glaze',
      createdAt: DateTime(2024, 8, 20),
      viewCount: 1100,
      rating: 4.8,
      reviewCount: 27,
      tags: ['ceramic', 'tea set', 'blue white', 'kitchenware'],
      origin: 'Khurja, Uttar Pradesh',
    ),
    ArtisanProduct(
      id: 'product_7',
      title: 'Embroidered Wall Hanging',
      description: 'Beautiful Rajasthani mirror work wall hanging with colorful embroidery. Features traditional motifs and adds vibrant touch to any room.',
      price: 2200,
      imageUrls: ['assets/products/wall_hanging_1.jpg', 'assets/products/wall_hanging_2.jpg'],
      artist: _sampleArtists[1],
      categories: ['Embroidery', 'Wall Art', 'Home Decor'],
      technique: 'Mirror work and embroidery',
      dimensions: {'height': '60cm', 'width': '40cm'},
      material: 'Cotton fabric, mirrors, silk threads',
      createdAt: DateTime(2024, 8, 25),
      viewCount: 680,
      rating: 4.7,
      reviewCount: 21,
      tags: ['embroidery', 'mirror work', 'wall hanging', 'rajasthani'],
      origin: 'Jaipur, Rajasthan',
    ),
  ];

  // Get all products
  Future<List<ArtisanProduct>> getAllProducts() async {
    await _simulateNetworkDelay();
    // Shuffle to simulate dynamic content
    final shuffled = List<ArtisanProduct>.from(_sampleProducts);
    shuffled.shuffle();
    return shuffled;
  }

  // Get products by category
  Future<List<ArtisanProduct>> getProductsByCategory(String category) async {
    await _simulateNetworkDelay();
    return _sampleProducts
        .where((product) => product.categories.contains(category))
        .toList();
  }

  // Search products
  Future<List<ArtisanProduct>> searchProducts(String query) async {
    await _simulateNetworkDelay();
    final lowercaseQuery = query.toLowerCase();
    
    return _sampleProducts.where((product) {
      return product.title.toLowerCase().contains(lowercaseQuery) ||
             product.description.toLowerCase().contains(lowercaseQuery) ||
             product.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
             product.artist.name.toLowerCase().contains(lowercaseQuery) ||
             product.categories.any((cat) => cat.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Get recommended products (basic implementation)
  Future<List<ArtisanProduct>> getRecommendedProducts(List<String> likedProductIds) async {
    await _simulateNetworkDelay();
    
    if (likedProductIds.isEmpty) {
      // Return popular/highly rated products
      final popular = _sampleProducts.where((p) => p.isPopular || p.isHighlyRated).toList();
      popular.shuffle();
      return popular.take(10).toList();
    }

    // Find liked products and their categories
    final likedProducts = _sampleProducts
        .where((p) => likedProductIds.contains(p.id))
        .toList();
    
    final likedCategories = <String>{};
    final likedArtists = <String>{};
    
    for (final product in likedProducts) {
      likedCategories.addAll(product.categories);
      likedArtists.add(product.artist.id);
    }

    // Find similar products
    final recommendations = _sampleProducts.where((product) {
      if (likedProductIds.contains(product.id)) return false;
      
      // Score based on category match
      final categoryMatch = product.categories.any((cat) => likedCategories.contains(cat));
      // Score based on same artist
      final artistMatch = likedArtists.contains(product.artist.id);
      
      return categoryMatch || artistMatch;
    }).toList();

    // Sort by rating and popularity
    recommendations.sort((a, b) {
      final scoreA = (a.rating * 0.7) + (a.isPopular ? 0.3 : 0);
      final scoreB = (b.rating * 0.7) + (b.isPopular ? 0.3 : 0);
      return scoreB.compareTo(scoreA);
    });

    return recommendations.take(10).toList();
  }

  // Get product by ID
  Future<ArtisanProduct?> getProductById(String id) async {
    await _simulateNetworkDelay();
    try {
      return _sampleProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all categories
  List<String> getAllCategories() {
    final categories = <String>{};
    for (final product in _sampleProducts) {
      categories.addAll(product.categories);
    }
    return categories.toList()..sort();
  }

  // Simulate API error for testing
  Future<List<ArtisanProduct>> getProductsWithError() async {
    await _simulateNetworkDelay();
    throw Exception('Network error: Unable to fetch products');
  }
}