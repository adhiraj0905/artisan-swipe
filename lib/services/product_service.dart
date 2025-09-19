// lib/services/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  // A reference to your Firestore collection
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Fetches all products for the initial swipe screen
  Future<List<ArtisanProduct>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await _productsCollection.get();
      List<ArtisanProduct> products = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ArtisanProduct.fromJson(data);
      }).toList();
      products.shuffle();
      return products;
    } catch (e) {
      print("Error fetching all products: $e");
      return [];
    }
  }

  // Fetches products belonging to a specific category
  Future<List<ArtisanProduct>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _productsCollection
          .where('categories', arrayContains: category)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ArtisanProduct.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error fetching products by category: $e");
      return [];
    }
  }
  
  // Fetches a single product by its ID
  Future<ArtisanProduct?> getProductById(String productId) async {
    try {
      QuerySnapshot snapshot =
          await _productsCollection.where('id', isEqualTo: productId).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
        return ArtisanProduct.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error fetching product by ID: $e");
      return null;
    }
  }

  // Fetches trending products by ordering them by view count
  Future<List<ArtisanProduct>> getTrendingProducts() async {
     try {
       QuerySnapshot snapshot = await _productsCollection
          .orderBy('viewCount', descending: true)
          .limit(5)
          .get();
      return snapshot.docs.map((doc) => ArtisanProduct.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
       print("Error in getTrendingProducts: $e");
       return [];
    }
  }

  // NOTE: The methods below are more complex and have been simplified.
  // A full implementation requires more advanced queries or third-party services.

  // Performs a basic, case-insensitive search on the device
  Future<List<ArtisanProduct>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    try {
        String lowerQuery = query.toLowerCase();
        // This is an inefficient client-side search. For a real app, use a dedicated search service like Algolia.
        List<ArtisanProduct> allProducts = await getAllProducts();
        return allProducts.where((product) {
          return product.title.toLowerCase().contains(lowerQuery) ||
                product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
                product.artist.name.toLowerCase().contains(lowerQuery);
        }).toList();
    } catch (e) {
        print("Error in searchProducts: $e");
        return [];
    }
  }

  // Returns products that have not been liked yet
  Future<List<ArtisanProduct>> getRecommendedProducts(List<String> likedProductIds) async {
    if (likedProductIds.isEmpty) {
      return await getAllProducts();
    }
    try {
       // This simple version just gets products whose IDs are not in the liked list.
       QuerySnapshot snapshot = await _productsCollection
          .where('id', whereNotIn: likedProductIds)
          .get();
      return snapshot.docs.map((doc) => ArtisanProduct.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
       print("Error in getRecommendedProducts: $e");
       return [];
    }
  }

  // This method would require adding the artist's ID to the product document to query efficiently.
  Future<List<ArtisanProduct>> getProductsByArtist(String artistId) async {
    print("getProductsByArtist needs 'artist.id' to be a queryable field.");
    return [];
  }
}