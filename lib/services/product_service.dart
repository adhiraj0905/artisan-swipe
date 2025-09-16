// lib/services/product_service.dart

import '../models/product.dart';
import 'dart:math';

class ProductService {
  // Mock data - in a real app, this would come from your API
  static final List<ArtisanProduct> _mockProducts = [
    ArtisanProduct(
      id: '1',
      title: 'Handwoven Banarasi Silk Saree',
      description: 'Exquisite traditional Banarasi silk saree with intricate gold zari work. This masterpiece showcases the timeless art of Varanasi weavers, featuring traditional motifs and rich silk fabric that drapes beautifully.',
      price: 18500,
      imageUrls: ['https://example.com/saree1.jpg'],
      artist: Artist(
        id: 'artist1',
        name: 'Rajesh Kumar Gupta',
        bio: 'Master weaver from Varanasi with 25 years of experience in traditional silk weaving. His family has been preserving the ancient art of Banarasi weaving for four generations.',
        profileImageUrl: 'https://example.com/rajesh.jpg',
        location: 'Varanasi',
        state: 'Uttar Pradesh',
        specialties: ['Silk Weaving', 'Zari Work', 'Traditional Patterns'],
        yearsOfExperience: 25,
        rating: 4.8,
        totalProducts: 45,
        totalSales: 230,
        joinedDate: DateTime(2020, 1, 15),
        isVerified: true,
        socialLinks: {'instagram': '@rajeshsilks', 'facebook': 'rajeshbanarasi'},
        phoneNumber: '+91 9876543210',
        email: 'rajesh@banarasisilks.com',
      ),
      categories: ['Textiles', 'Sarees', 'Silk', 'Wedding'],
      technique: 'Hand Weaving with Zari',
      dimensions: {'length': '6.5m', 'width': '1.2m', 'blouse': '1m'},
      material: 'Pure Silk, Gold Zari',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      viewCount: 1250,
      rating: 4.9,
      reviewCount: 23,
      tags: ['traditional', 'wedding', 'silk', 'handwoven', 'banarasi', 'zari'],
      origin: 'Varanasi, Uttar Pradesh',
    ),

    ArtisanProduct(
      id: '2',
      title: 'Blue Pottery Decorative Vase',
      description: 'Stunning blue pottery vase featuring traditional Jaipur patterns. Hand-painted with natural cobalt blue dye and fired in traditional kilns. Perfect as a centerpiece or gift.',
      price: 3200,
      imageUrls: ['https://example.com/pottery1.jpg'],
      artist: Artist(
        id: 'artist2',
        name: 'Meera Devi Sharma',
        bio: 'Renowned blue pottery artist from Jaipur, preserving the 400-year-old Mughal tradition. Award-winning craftswoman known for her intricate floral patterns.',
        profileImageUrl: 'https://example.com/meera.jpg',
        location: 'Jaipur',
        state: 'Rajasthan',
        specialties: ['Blue Pottery', 'Traditional Painting', 'Ceramic Art'],
        yearsOfExperience: 15,
        rating: 4.7,
        totalProducts: 67,
        totalSales: 340,
        joinedDate: DateTime(2019, 6, 10),
        isVerified: true,
        socialLinks: {'instagram': '@meerabluepottery'},
        phoneNumber: '+91 9876543211',
        email: 'meera@bluepotteryjaipur.com',
      ),
      categories: ['Pottery', 'Home Decor', 'Ceramics', 'Art'],
      technique: 'Blue Pottery',
      dimensions: {'height': '25cm', 'diameter': '15cm', 'weight': '800g'},
      material: 'Clay, Natural Cobalt Dye, Glaze',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      viewCount: 890,
      rating: 4.6,
      reviewCount: 18,
      tags: ['pottery', 'blue', 'jaipur', 'traditional', 'handpainted', 'home-decor'],
      origin: 'Jaipur, Rajasthan',
    ),

    ArtisanProduct(
      id: '3',
      title: 'Carved Sandalwood Elephant',
      description: 'Intricately carved sandalwood elephant sculpture showcasing traditional South Indian woodworking. Every detail is hand-carved with precision, representing strength and prosperity.',
      price: 7800,
      imageUrls: ['https://example.com/elephant1.jpg'],
      artist: Artist(
        id: 'artist3',
        name: 'K. Venkatesan',
        bio: 'Master wood carver from Mysore, specializing in traditional temple art and animal sculptures. His work is displayed in temples across South India.',
        profileImageUrl: 'https://example.com/venkat.jpg',
        location: 'Mysore',
        state: 'Karnataka',
        specialties: ['Wood Carving', 'Temple Art', 'Animal Sculptures'],
        yearsOfExperience: 28,
        rating: 4.9,
        totalProducts: 34,
        totalSales: 156,
        joinedDate: DateTime(2018, 3, 20),
        isVerified: true,
        socialLinks: {'website': 'mysorewoods.com'},
        phoneNumber: '+91 9876543212',
        email: 'venkat@mysorewoods.com',
      ),
      categories: ['Woodwork', 'Sculpture', 'Religious', 'Art'],
      technique: 'Hand Carving',
      dimensions: {'height': '20cm', 'length': '25cm', 'width': '12cm'},
      material: 'Sandalwood',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      viewCount: 1450,
      rating: 4.8,
      reviewCount: 31,
      tags: ['woodcarving', 'elephant', 'sandalwood', 'traditional', 'sculpture'],
      origin: 'Mysore, Karnataka',
    ),

    ArtisanProduct(
      id: '4',
      title: 'Kundan Meenakari Jewelry Set',
      description: 'Royal Kundan jewelry set with exquisite Meenakari work. Includes necklace, earrings, and maang tikka. Perfect for weddings and special occasions.',
      price: 25000,
      imageUrls: ['https://example.com/jewelry1.jpg'],
      artist: Artist(
        id: 'artist4',
        name: 'Ramesh Soni',
        bio: 'Third-generation jeweler from Jaipur, specializing in Kundan and Meenakari work. His family workshop has been serving royal families for decades.',
        profileImageUrl: 'https://example.com/ramesh.jpg',
        location: 'Jaipur',
        state: 'Rajasthan',
        specialties: ['Kundan Jewelry', 'Meenakari', 'Traditional Goldsmithing'],
        yearsOfExperience: 20,
        rating: 4.9,
        totalProducts: 28,
        totalSales: 95,
        joinedDate: DateTime(2021, 8, 5),
        isVerified: true,
        socialLinks: {'instagram': '@sonikundan'},
        phoneNumber: '+91 9876543213',
        email: 'ramesh@sonikunderajewels.com',
      ),
      categories: ['Jewelry', 'Wedding', 'Traditional', 'Kundan'],
      technique: 'Kundan Setting with Meenakari',
      dimensions: {'necklace': '40cm', 'earrings': '8cm', 'tikka': '12cm'},
      material: 'Gold-plated Silver, Kundan, Meenakari Enamel',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      viewCount: 2100,
      rating: 4.9,
      reviewCount: 15,
      tags: ['kundan', 'meenakari', 'jewelry', 'wedding', 'royal', 'traditional'],
      origin: 'Jaipur, Rajasthan',
    ),

    ArtisanProduct(
      id: '5',
      title: 'Kashmiri Pashmina Shawl',
      description: 'Authentic handwoven Kashmiri Pashmina shawl with traditional paisley patterns. Made from the finest goat wool, incredibly soft and warm.',
      price: 12000,
      imageUrls: ['https://example.com/pashmina1.jpg'],
      artist: Artist(
        id: 'artist5',
        name: 'Abdul Majeed',
        bio: 'Master weaver from Kashmir, continuing the centuries-old tradition of Pashmina weaving. His shawls are known for their exceptional softness and intricate patterns.',
        profileImageUrl: 'https://example.com/majeed.jpg',
        location: 'Srinagar',
        state: 'Jammu & Kashmir',
        specialties: ['Pashmina Weaving', 'Traditional Patterns', 'Kashmiri Handicrafts'],
        yearsOfExperience: 22,
        rating: 4.8,
        totalProducts: 52,
        totalSales: 280,
        joinedDate: DateTime(2019, 10, 12),
        isVerified: true,
        socialLinks: {'whatsapp': '+91 9876543214'},
        phoneNumber: '+91 9876543214',
        email: 'majeed@kashmiripashmina.com',
      ),
      categories: ['Textiles', 'Shawls', 'Pashmina', 'Winter Wear'],
      technique: 'Hand Weaving',
      dimensions: {'length': '200cm', 'width': '70cm', 'weight': '200g'},
      material: 'Pure Pashmina Goat Wool',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      viewCount: 1680,
      rating: 4.7,
      reviewCount: 42,
      tags: ['pashmina', 'kashmir', 'handwoven', 'luxury', 'winter', 'shawl'],
      origin: 'Srinagar, Kashmir',
    ),

    ArtisanProduct(
      id: '6',
      title: 'Madhubani Painting on Canvas',
      description: 'Traditional Madhubani painting depicting nature and mythological themes. Hand-painted using natural colors on canvas, representing the folk art of Bihar.',
      price: 4500,
      imageUrls: ['https://example.com/madhubani1.jpg'],
      artist: Artist(
        id: 'artist6',
        name: 'Sunita Kumari',
        bio: 'Traditional Madhubani artist from Bihar, keeping alive the ancient art form passed down by her grandmother. Her paintings are exhibited in galleries across India.',
        profileImageUrl: 'https://example.com/sunita.jpg',
        location: 'Madhubani',
        state: 'Bihar',
        specialties: ['Madhubani Painting', 'Folk Art', 'Natural Colors'],
        yearsOfExperience: 18,
        rating: 4.6,
        totalProducts: 89,
        totalSales: 445,
        joinedDate: DateTime(2020, 4, 22),
        isVerified: true,
        socialLinks: {'facebook': 'sunitamadhubani'},
        phoneNumber: '+91 9876543215',
        email: 'sunita@madhubaniart.com',
      ),
      categories: ['Paintings', 'Folk Art', 'Canvas Art', 'Traditional'],
      technique: 'Hand Painting with Natural Colors',
      dimensions: {'height': '40cm', 'width': '30cm', 'depth': '2cm'},
      material: 'Canvas, Natural Pigments, Bamboo Brushes',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      viewCount: 750,
      rating: 4.5,
      reviewCount: 28,
      tags: ['madhubani', 'folk-art', 'painting', 'traditional', 'bihar', 'canvas'],
      origin: 'Madhubani, Bihar',
    ),

    ArtisanProduct(
      id: '7',
      title: 'Brass Decorative Diya Set',
      description: 'Handcrafted brass diyas with intricate engravings. Set of 6 traditional oil lamps perfect for festivals and home decoration.',
      price: 1800,
      imageUrls: ['https://example.com/diya1.jpg'],
      artist: Artist(
        id: 'artist7',
        name: 'Prakash Thakkar',
        bio: 'Skilled brass craftsman from Gujarat, specializing in traditional metalwork. His family has been creating brass items for temples and homes for three generations.',
        profileImageUrl: 'https://example.com/prakash.jpg',
        location: 'Ahmedabad',
        state: 'Gujarat',
        specialties: ['Brass Work', 'Metal Engraving', 'Traditional Crafts'],
        yearsOfExperience: 16,
        rating: 4.4,
        totalProducts: 134,
        totalSales: 567,
        joinedDate: DateTime(2021, 1, 8),
        isVerified: true,
        socialLinks: {'instagram': '@brassworksguj'},
        phoneNumber: '+91 9876543216',
        email: 'prakash@gujaratbrass.com',
      ),
      categories: ['Metalwork', 'Home Decor', 'Religious', 'Festival'],
      technique: 'Hand Engraving on Brass',
      dimensions: {'diameter': '8cm', 'height': '3cm', 'set': '6 pieces'},
      material: 'Pure Brass',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      viewCount: 920,
      rating: 4.3,
      reviewCount: 35,
      tags: ['brass', 'diya', 'festival', 'traditional', 'home-decor', 'handcrafted'],
      origin: 'Ahmedabad, Gujarat',
    ),

    ArtisanProduct(
      id: '8',
      title: 'Warli Art Tribal Painting',
      description: 'Authentic Warli tribal art painting depicting village life and harvest celebrations. Created using traditional white pigment on dark background.',
      price: 3800,
      imageUrls: ['https://example.com/warli1.jpg'],
      artist: Artist(
        id: 'artist8',
        name: 'Vandana Masram',
        bio: 'Warli tribal artist from Maharashtra, preserving the ancient art form of her ancestors. Her paintings tell stories of tribal life and traditions.',
        profileImageUrl: 'https://example.com/vandana.jpg',
        location: 'Dahanu',
        state: 'Maharashtra',
        specialties: ['Warli Art', 'Tribal Painting', 'Traditional Stories'],
        yearsOfExperience: 12,
        rating: 4.7,
        totalProducts: 76,
        totalSales: 289,
        joinedDate: DateTime(2022, 3, 15),
        isVerified: true,
        socialLinks: {'facebook': 'warliartbyvandana'},
        phoneNumber: '+91 9876543217',
        email: 'vandana@warliart.com',
      ),
      categories: ['Paintings', 'Tribal Art', 'Folk Art', 'Wall Art'],
      technique: 'Traditional Warli Painting',
      dimensions: {'height': '35cm', 'width': '25cm', 'depth': '1.5cm'},
      material: 'Natural White Pigment, Dark Paper, Bamboo Stick',
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
      viewCount: 650,
      rating: 4.6,
      reviewCount: 22,
      tags: ['warli', 'tribal', 'folk-art', 'traditional', 'maharashtra', 'village-life'],
      origin: 'Dahanu, Maharashtra',
    ),

    ArtisanProduct(
      id: '9',
      title: 'Leather Mojari Shoes',
      description: 'Traditional handcrafted leather mojaris with colorful thread work. Comfortable ethnic footwear perfect for festivals and traditional occasions.',
      price: 2200,
      imageUrls: ['https://example.com/mojari1.jpg'],
      artist: Artist(
        id: 'artist9',
        name: 'Suresh Choudhary',
        bio: 'Master cobbler from Rajasthan, specializing in traditional mojari and jutis. His craftsmanship combines comfort with authentic Rajasthani designs.',
        profileImageUrl: 'https://example.com/suresh.jpg',
        location: 'Jodhpur',
        state: 'Rajasthan',
        specialties: ['Leather Craft', 'Traditional Footwear', 'Embroidery'],
        yearsOfExperience: 19,
        rating: 4.5,
        totalProducts: 98,
        totalSales: 412,
        joinedDate: DateTime(2020, 9, 30),
        isVerified: true,
        socialLinks: {'whatsapp': '+91 9876543218'},
        phoneNumber: '+91 9876543218',
        email: 'suresh@rajasthanifootwear.com',
      ),
      categories: ['Leather', 'Footwear', 'Traditional', 'Fashion'],
      technique: 'Hand Stitching with Thread Embroidery',
      dimensions: {'sizes': '6-11', 'length': '28cm', 'width': '10cm'},
      material: 'Genuine Leather, Cotton Thread, Rubber Sole',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      viewCount: 1120,
      rating: 4.4,
      reviewCount: 48,
      tags: ['mojari', 'leather', 'traditional', 'footwear', 'rajasthan', 'handcrafted'],
      origin: 'Jodhpur, Rajasthan',
    ),

    ArtisanProduct(
      id: '10',
      title: 'Bamboo Basket with Lid',
      description: 'Eco-friendly bamboo basket with intricate weaving patterns. Perfect for storage and home organization while adding a natural touch to your decor.',
      price: 850,
      imageUrls: ['https://example.com/bamboo1.jpg'],
      artist: Artist(
        id: 'artist10',
        name: 'Ravi Nath',
        bio: 'Bamboo craftsman from Assam, creating sustainable and beautiful bamboo products. His work promotes eco-friendly living while preserving traditional weaving techniques.',
        profileImageUrl: 'https://example.com/ravi.jpg',
        location: 'Guwahati',
        state: 'Assam',
        specialties: ['Bamboo Craft', 'Weaving', 'Eco Products'],
        yearsOfExperience: 14,
        rating: 4.3,
        totalProducts: 156,
        totalSales: 623,
        joinedDate: DateTime(2021, 5, 18),
        isVerified: false,
        socialLinks: {'instagram': '@bamboocraft_assam'},
        phoneNumber: '+91 9876543219',
        email: 'ravi@bamboocraft.com',
      ),
      categories: ['Basketry', 'Home Decor', 'Storage', 'Eco-Friendly'],
      technique: 'Traditional Bamboo Weaving',
      dimensions: {'diameter': '30cm', 'height': '25cm', 'lid': 'included'},
      material: 'Natural Bamboo, Cotton Thread',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      viewCount: 430,
      rating: 4.2,
      reviewCount: 19,
      tags: ['bamboo', 'basket', 'eco-friendly', 'storage', 'handwoven', 'natural'],
      origin: 'Guwahati, Assam',
    ),
  ];

  // Simulate API delay for realistic experience
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(400)));
  }

  // Get all products (for initial load)
  Future<List<ArtisanProduct>> getAllProducts() async {
    await _simulateNetworkDelay();
    
    // Shuffle the list to show different products each time
    var shuffled = List<ArtisanProduct>.from(_mockProducts);
    shuffled.shuffle();
    return shuffled;
  }

  // Get recommended products based on liked items
  Future<List<ArtisanProduct>> getRecommendedProducts(List<String> likedProductIds) async {
    await _simulateNetworkDelay();
    
    if (likedProductIds.isEmpty) {
      return getAllProducts();
    }

    // Simple recommendation algorithm
    // Find categories and tags from liked products
    Set<String> preferredCategories = {};
    Set<String> preferredTags = {};
    
    for (String likedId in likedProductIds) {
      var likedProduct = _mockProducts.firstWhere((p) => p.id == likedId);
      preferredCategories.addAll(likedProduct.categories);
      preferredTags.addAll(likedProduct.tags);
    }

    // Score products based on category and tag matches
    var scoredProducts = _mockProducts
        .where((product) => !likedProductIds.contains(product.id))
        .map((product) {
          int score = 0;
          
          // Category matches
          for (String category in product.categories) {
            if (preferredCategories.contains(category)) score += 3;
          }
          
          // Tag matches
          for (String tag in product.tags) {
            if (preferredTags.contains(tag)) score += 1;
          }
          
          // Same state bonus
          var likedStates = _mockProducts
              .where((p) => likedProductIds.contains(p.id))
              .map((p) => p.artist.state)
              .toSet();
          if (likedStates.contains(product.artist.state)) score += 2;
          
          return MapEntry(product, score);
        })
        .toList();

    // Sort by score (descending) and return
    scoredProducts.sort((a, b) => b.value.compareTo(a.value));
    return scoredProducts.map((entry) => entry.key).toList();
  }

  // Search products by query
  Future<List<ArtisanProduct>> searchProducts(String query) async {
    await _simulateNetworkDelay();
    
    if (query.isEmpty) return [];
    
    String lowerQuery = query.toLowerCase();
    
    return _mockProducts.where((product) {
      return product.title.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery) ||
             product.categories.any((cat) => cat.toLowerCase().contains(lowerQuery)) ||
             product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
             product.artist.name.toLowerCase().contains(lowerQuery) ||
             product.origin.toLowerCase().contains(lowerQuery) ||
             product.material.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get products by category
  Future<List<ArtisanProduct>> getProductsByCategory(String category) async {
    await _simulateNetworkDelay();
    
    return _mockProducts.where((product) {
      return product.categories.any((cat) => 
        cat.toLowerCase() == category.toLowerCase());
    }).toList();
  }

  // Get products by artist
  Future<List<ArtisanProduct>> getProductsByArtist(String artistId) async {
    await _simulateNetworkDelay();
    
    return _mockProducts.where((product) => 
      product.artist.id == artistId).toList();
  }

  // Get single product by ID
  Future<ArtisanProduct?> getProductById(String productId) async {
    await _simulateNetworkDelay();
    
    try {
      return _mockProducts.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Get trending products (high rating + high views)
  Future<List<ArtisanProduct>> getTrendingProducts() async {
    await _simulateNetworkDelay();
    
    var trending = List<ArtisanProduct>.from(_mockProducts);
    trending.sort((a, b) {
      double scoreA = (a.rating * 0.7) + (a.viewCount / 1000 * 0.3);
      double scoreB = (b.rating * 0.7) + (b.viewCount / 1000 * 0.3);
      return scoreB.compareTo(scoreA);
    });
    
    return trending.take(5).toList();
  }
}