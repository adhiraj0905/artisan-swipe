// Updated SwipeDemo widget using the new data models

import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class SwipeDemo extends StatefulWidget {
  final Function(ArtisanProduct) onLike;

  SwipeDemo({required this.onLike});

  @override
  _SwipeDemoState createState() => _SwipeDemoState();
}

class _SwipeDemoState extends State<SwipeDemo> {
  late List<SwipeItem> _swipeItems;
  late MatchEngine _matchEngine;
  final ProductService _productService = ProductService();
  
  List<ArtisanProduct> _products = [];
  bool _isLoading = true;
  String? _error;
  List<String> _likedProductIds = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load initial products or recommendations
      List<ArtisanProduct> products;
      if (_likedProductIds.isEmpty) {
        products = await _productService.getAllProducts();
      } else {
        products = await _productService.getRecommendedProducts(_likedProductIds);
      }

      _products = products;
      _createSwipeItems();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _createSwipeItems() {
    _swipeItems = [];

    for (final product in _products) {
      _swipeItems.add(
        SwipeItem(
          content: product,
          likeAction: () {
            widget.onLike(product);
            _likedProductIds.add(product.id);
            print("Liked ${product.title}");
            
            // Load more recommendations if running low
            if (_swipeItems.length <= 2) {
              _loadMoreProducts();
            }
          },
          nopeAction: () {
            print("Passed on ${product.title}");
            
            // Load more products if running low
            if (_swipeItems.length <= 2) {
              _loadMoreProducts();
            }
          },
        ),
      );
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  Future<void> _loadMoreProducts() async {
    try {
      final moreProducts = await _productService.getRecommendedProducts(_likedProductIds);
      final newProducts = moreProducts
          .where((p) => !_products.any((existing) => existing.id == p.id))
          .take(5)
          .toList();

      if (newProducts.isNotEmpty) {
        _products.addAll(newProducts);
        
        for (final product in newProducts) {
          _matchEngine.currentItem?.content;
          _swipeItems.add(
            SwipeItem(
              content: product,
              likeAction: () {
                widget.onLike(product);
                _likedProductIds.add(product.id);
                print("Liked ${product.title}");
              },
              nopeAction: () {
                print("Passed on ${product.title}");
              },
            ),
          );
        }
      }
    } catch (e) {
      print("Error loading more products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F0A50), Color(0xFF7D3C98)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Finding amazing artisan pieces...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              "Oops! Something went wrong",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Please check your connection and try again",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProducts,
              child: Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF7D3C98),
              ),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              "No products available",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Check back later for new artisan pieces",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        height: 600,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SwipeCards(
          matchEngine: _matchEngine,
          itemBuilder: (BuildContext context, int index) {
            final product = _swipeItems[index].content as ArtisanProduct;
            return _buildProductCard(product);
          },
          onStackFinished: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("That's all for now! We're finding more amazing pieces for you."),
                backgroundColor: Color(0xFF7D3C98),
              ),
            );
            // Load more products when stack is finished
            _loadMoreProducts();
          },
          upSwipeAllowed: true,
          fillSpace: true,
        ),
      ),
    );
  }

  Widget _buildProductCard(ArtisanProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              child: Stack(
                children: [
                  // Main product image
                  Container(
                    width: double.infinity,
                    child: product.primaryImageUrl.startsWith('assets/')
                        ? Image.asset(
                            product.primaryImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                              );
                            },
                          )
                        : Image.network(
                            product.primaryImageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                              );
                            },
                          ),
                  ),
                  
                  // Price badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF7D3C98),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.formattedPrice,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  
                  // Verified badge (if artist is verified)
                  if (product.artist.isVerified)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              "Verified",
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product title
                  Text(
                    product.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Artist info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF7D3C98),
                        child: Text(
                          product.artist.name[0].toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.artist.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              product.origin,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rating
                      if (product.rating > 0) ...[
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Description
                  Expanded(
                    child: Text(
                      product.shortDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Categories/Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: product.categories.take(3).map((category) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF7D3C98).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF7D3C98).withOpacity(0.3)),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7D3C98),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}