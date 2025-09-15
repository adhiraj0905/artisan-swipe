import 'package:flutter/material.dart';
import 'models/product.dart';
import 'services/product_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------------------- MAIN SCREEN ----------------------
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<ArtisanProduct> _favorites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SwipeDemo(
            onLike: (product) {
              setState(() {
                if (!_favorites.any((fav) => fav.id == product.id)) {
                  _favorites.add(product);
                }
              });
            },
          ),
          const SearchScreen(),
          FavoritesScreen(favorites: _favorites),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF7D3C98),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ---------------------- SWIPE DEMO ----------------------
class SwipeDemo extends StatefulWidget {
  final Function(ArtisanProduct) onLike;

  const SwipeDemo({Key? key, required this.onLike}) : super(key: key);

  @override
  _SwipeDemoState createState() => _SwipeDemoState();
}

class _SwipeDemoState extends State<SwipeDemo> with TickerProviderStateMixin {
  final ProductService _productService = ProductService();
  
  List<ArtisanProduct> _products = [];
  bool _isLoading = true;
  String? _error;
  final List<String> _likedProductIds = [];
  int _currentIndex = 0;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  // Drag variables
  Offset _cardOffset = Offset.zero;
  double _cardAngle = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProducts();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<ArtisanProduct> products;
      if (_likedProductIds.isEmpty) {
        products = await _productService.getAllProducts();
      } else {
        products = await _productService.getRecommendedProducts(_likedProductIds);
      }

      _products = products;

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

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _cardOffset += details.delta;
      _cardAngle = _cardOffset.dx / 1000;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    // Check if card was swiped far enough
    if (_cardOffset.dx.abs() > 100) {
      if (_cardOffset.dx > 0) {
        _swipeRight();
      } else {
        _swipeLeft();
      }
    } else {
      // Animate back to center
      setState(() {
        _cardOffset = Offset.zero;
        _cardAngle = 0;
      });
    }
  }

  void _swipeRight() {
    // Like animation
    _animateCard(Offset(400, 0), () {
      if (_currentIndex < _products.length) {
        final product = _products[_currentIndex];
        widget.onLike(product);
        _likedProductIds.add(product.id);
      }
      _nextCard();
    });
  }

  void _swipeLeft() {
    // Pass animation
    _animateCard(Offset(-400, 0), () {
      _nextCard();
    });
  }

  void _animateCard(Offset target, VoidCallback onComplete) {
    setState(() {
      _cardOffset = target;
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      onComplete();
    });
  }

  void _nextCard() {
    setState(() {
      _currentIndex++;
      _cardOffset = Offset.zero;
      _cardAngle = 0;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
      return const Center(
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
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              "Oops! Something went wrong",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please check your connection and try again",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7D3C98),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty || _currentIndex >= _products.length) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              "No more products",
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

    return SafeArea(
      child: Column(
        children: [
          // Card Stack
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Next cards (background)
                if (_currentIndex + 1 < _products.length)
                  Transform.scale(
                    scale: 0.95,
                    child: _buildStaticCard(_products[_currentIndex + 1]),
                  ),
                if (_currentIndex + 2 < _products.length)
                  Transform.scale(
                    scale: 0.9,
                    child: _buildStaticCard(_products[_currentIndex + 2]),
                  ),
                
                // Current card (foreground)
                if (_currentIndex < _products.length)
                  Transform.translate(
                    offset: _cardOffset,
                    child: Transform.rotate(
                      angle: _cardAngle,
                      child: Container(
                        decoration: _getCardDecoration(),
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: _buildProductCard(_products[_currentIndex]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _swipeLeft,
                  backgroundColor: Colors.red.withOpacity(0.9),
                  heroTag: "pass",
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                FloatingActionButton(
                  onPressed: _swipeRight,
                  backgroundColor: Colors.green.withOpacity(0.9),
                  heroTag: "like",
                  child: const Icon(Icons.favorite, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _getCardDecoration() {
    Color glowColor = Colors.transparent;
    double glowIntensity = 0;

    if (_isDragging && _cardOffset.dx.abs() > 50) {
      if (_cardOffset.dx > 0) {
        // Swiping right - green glow
        glowColor = Colors.green;
        glowIntensity = (_cardOffset.dx / 200).clamp(0.0, 1.0);
      } else {
        // Swiping left - red glow
        glowColor = Colors.red;
        glowIntensity = (_cardOffset.dx.abs() / 200).clamp(0.0, 1.0);
      }
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        const BoxShadow(
          color: Colors.black26,
          blurRadius: 15,
          offset: Offset(0, 8),
        ),
        if (glowIntensity > 0)
          BoxShadow(
            color: glowColor.withOpacity(glowIntensity * 0.6),
            blurRadius: 20,
            spreadRadius: 5,
          ),
      ],
    );
  }

  Widget _buildStaticCard(ArtisanProduct product) {
    return Container(
      width: 320,
      height: 550,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: _buildCardContent(product),
    );
  }

  Widget _buildProductCard(ArtisanProduct product) {
    return Container(
      width: 320,
      height: 550,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          _buildCardContent(product),
          
          // Overlay for swipe feedback
          if (_isDragging && _cardOffset.dx.abs() > 50)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: (_cardOffset.dx > 0 ? Colors.green : Colors.red).withOpacity(0.2),
              ),
              child: Center(
                child: Icon(
                  _cardOffset.dx > 0 ? Icons.favorite : Icons.close,
                  size: 80,
                  color: _cardOffset.dx > 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent(ArtisanProduct product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Stack(
              children: [
                // Main product image placeholder
                Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                ),
                
                // Price badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7D3C98),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product title
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Artist info
                Row(
                  children: [
                    
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            product.artist.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(221, 75, 75, 75),
                              
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
                    
                    
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description of product(need to be changed)
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
                
                const SizedBox(height: 12),
                
                // Categories(idt this needs to be shown)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: product.categories.take(3).map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7D3C98).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF7D3C98).withOpacity(0.3)),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
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
    );
  }
}

// ---------------------- SEARCH SCREEN ----------------------
class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7D3C98),
      ),
      body: const Center(
        child: Text("Search Screen (Coming Soon)"),
      ),
    );
  }
}

// ---------------------- FAVORITES SCREEN ----------------------
class FavoritesScreen extends StatelessWidget {
  final List<ArtisanProduct> favorites;

  const FavoritesScreen({Key? key, required this.favorites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7D3C98),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No favorites yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Swipe right on products you love to save them here",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.image, color: Colors.white),
                    ),
                    title: Text(product.title),
                    subtitle: Text("by ${product.artist.name}"),
                    trailing: Text(product.formattedPrice),
                  ),
                );
              },
            ),
    );
  }
}

// ---------------------- PROFILE SCREEN ----------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7D3C98),
      ),
      body: const Center(
        child: Text("User Profile (Coming Soon)"),
      ),
    );
  }
}