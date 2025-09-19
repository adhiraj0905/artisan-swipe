// models/product.dart

class ArtisanProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String primaryImageUrl;
  final Artist artist;
  final List<String> categories;
  final String technique;
  final Map<String, String> dimensions; // height, width, depth
  final String material;
  final bool isAvailable;
  final DateTime createdAt;
  final int viewCount;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final String origin; // City/State where it's made

  ArtisanProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'INR',
    required this.imageUrls,
    required this.artist,
    required this.categories,
    required this.technique,
    required this.dimensions,
    required this.material,
    this.isAvailable = true,
    required this.createdAt,
    this.viewCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.tags,
    required this.origin,
  }) : primaryImageUrl = imageUrls.isNotEmpty ? imageUrls.first : '';

  // Helper methods
  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  
  String get shortDescription => 
    description.length > 100 ? '${description.substring(0, 100)}...' : description;
  
  bool get isHighlyRated => rating >= 4.5;
  
  bool get isPopular => viewCount > 1000;

  // Convert from JSON (for API integration later)
  factory ArtisanProduct.fromJson(Map<String, dynamic> json) {
  return ArtisanProduct(
    id: json['id'] ?? '',
    title: json['title'] ?? 'Untitled Product',
    description: json['description'] ?? 'No description available.',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    currency: json['currency'] ?? 'INR',
    imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
    artist: Artist.fromJson(json['artist'] ?? {}),
    categories: json['categories'] != null ? List<String>.from(json['categories']) : [],
    technique: json['technique'] ?? 'N/A',
    dimensions: json['dimensions'] != null ? Map<String, String>.from(json['dimensions']) : {},
    material: json['material'] ?? 'N/A',
    isAvailable: json['isAvailable'] ?? true,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    viewCount: json['viewCount'] ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: json['reviewCount'] ?? 0,
    tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    origin: json['origin'] ?? 'Unknown',
  );
}

  // Convert to JSON (for API integration later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'artist': artist.toJson(),
      'categories': categories,
      'technique': technique,
      'dimensions': dimensions,
      'material': material,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'viewCount': viewCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'origin': origin,
    };
  }
}

class Artist {
  final String id;
  final String name;
  final String bio;
  final String profileImageUrl;
  final String location; // City, State
  final String state;
  final List<String> specialties;
  final int yearsOfExperience;
  final double rating;
  final int totalProducts;
  final int totalSales;
  final DateTime joinedDate;
  final bool isVerified;
  final Map<String, String> socialLinks;
  final String phoneNumber;
  final String email;

  Artist({
    required this.id,
    required this.name,
    required this.bio,
    required this.profileImageUrl,
    required this.location,
    required this.state,
    required this.specialties,
    this.yearsOfExperience = 0,
    this.rating = 0.0,
    this.totalProducts = 0,
    this.totalSales = 0,
    required this.joinedDate,
    this.isVerified = false,
    this.socialLinks = const {},
    this.phoneNumber = '',
    this.email = '',
  });

  String get shortBio => 
    bio.length > 150 ? '${bio.substring(0, 150)}...' : bio;

  String get experienceText => 
    yearsOfExperience == 1 ? '1 year experience' : '$yearsOfExperience years experience';

  bool get isEstablished => yearsOfExperience >= 10;

  factory Artist.fromJson(Map<String, dynamic> json) {
  return Artist(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Unknown Artist',
    bio: json['bio'] ?? '',
    profileImageUrl: json['profileImageUrl'] ?? '',
    location: json['location'] ?? 'Unknown',
    state: json['state'] ?? '',
    specialties: json['specialties'] != null ? List<String>.from(json['specialties']) : [],
    yearsOfExperience: json['yearsOfExperience'] ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    totalProducts: json['totalProducts'] ?? 0,
    totalSales: json['totalSales'] ?? 0,
    joinedDate: json['joinedDate'] != null ? DateTime.parse(json['joinedDate']) : DateTime.now(),
    isVerified: json['isVerified'] ?? false,
    socialLinks: json['socialLinks'] != null ? Map<String, String>.from(json['socialLinks']) : {},
    phoneNumber: json['phoneNumber'] ?? '',
    email: json['email'] ?? '',
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'state': state,
      'specialties': specialties,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'totalProducts': totalProducts,
      'totalSales': totalSales,
      'joinedDate': joinedDate.toIso8601String(),
      'isVerified': isVerified,
      'socialLinks': socialLinks,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}

// Enum for common categories
enum ProductCategory {
  pottery,
  textiles,
  jewelry,
  paintings,
  woodwork,
  metalwork,
  leather,
  handloom,
  embroidery,
  sculpture,
  ceramics,
  basketry,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.pottery:
        return 'Pottery';
      case ProductCategory.textiles:
        return 'Textiles';
      case ProductCategory.jewelry:
        return 'Jewelry';
      case ProductCategory.paintings:
        return 'Paintings';
      case ProductCategory.woodwork:
        return 'Woodwork';
      case ProductCategory.metalwork:
        return 'Metalwork';
      case ProductCategory.leather:
        return 'Leather Craft';
      case ProductCategory.handloom:
        return 'Handloom';
      case ProductCategory.embroidery:
        return 'Embroidery';
      case ProductCategory.sculpture:
        return 'Sculpture';
      case ProductCategory.ceramics:
        return 'Ceramics';
      case ProductCategory.basketry:
        return 'Basketry';
    }
  }

  String get icon {
    switch (this) {
      case ProductCategory.pottery:
        return '🏺';
      case ProductCategory.textiles:
        return '🧵';
      case ProductCategory.jewelry:
        return '💍';
      case ProductCategory.paintings:
        return '🎨';
      case ProductCategory.woodwork:
        return '🪵';
      case ProductCategory.metalwork:
        return '⚒️';
      case ProductCategory.leather:
        return '🧳';
      case ProductCategory.handloom:
        return '🪡';
      case ProductCategory.embroidery:
        return '🪡';
      case ProductCategory.sculpture:
        return '🗿';
      case ProductCategory.ceramics:
        return '🏺';
      case ProductCategory.basketry:
        return '🧺';
    }
  }
}