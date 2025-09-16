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
  // ignore: unused_field
  late Animation<Offset> _slideAnimation;
  // ignore: unused_field
  late Animation<double> _scaleAnimation;
  // ignore: unused_field
  late Animation<double> _rotationAnimation;
  
  // Drag variables
  Offset _cardOffset = Offset.zero;
  double _cardAngle = 0;
  bool _isDragging = false;

  // Map product IDs to local asset paths (FROM CODE 1)
  final Map<String, String> _productImagePaths = {
    '1': 'assets/products/saree.jpg',
    '2': 'assets/products/pottery.jpg',
    '3': 'assets/products/elephant.jpg',
    '4': 'assets/products/jewelry.jpg',
    '5': 'assets/products/pashmina.jpg',
    '6': 'assets/products/madhubani.jpg',
    '7': 'assets/products/diya.jpg',
    '8': 'assets/products/warli.jpg',
    '9': 'assets/products/mojari.jpg',
    '10': 'assets/products/bamboo.jpg',
  };

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
        widget.onLike(product); // This still works
        _likedProductIds.add(product.id); // This still works
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Stack (VISUAL CHANGE FROM CODE 2)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Furthest back card (3rd behind)
                if (_currentIndex + 3 < _products.length)
                  Transform.translate(
                    offset: const Offset(0, -45),
                    child: _buildStaticCard(_products[_currentIndex + 3]),
                  ),

                // Middle card (2nd behind)
                if (_currentIndex + 2 < _products.length)
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: _buildStaticCard(_products[_currentIndex + 2]),
                  ),

                // Closest background card (1st behind)
                if (_currentIndex + 1 < _products.length)
                  Transform.translate(
                    offset: const Offset(0, -15),
                    child: _buildStaticCard(_products[_currentIndex + 1]),
                  ),

                // Front card (interactive)
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
          
          // Action Buttons (VISUAL CHANGE - REMOVED)
          // The FloatingActionButtons from Code 1 have been removed
          // as requested.
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

  // (VISUAL CHANGE FROM CODE 2 - Dimensions and Shadow)
  Widget _buildStaticCard(ArtisanProduct product) {
    return Container(
      width: 300,
      height: 410,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: _buildCardContent(product),
    );
  }

  // (VISUAL CHANGE FROM CODE 2 - Dimensions)
  Widget _buildProductCard(ArtisanProduct product) {
    return Container(
      width: 300,
      height: 410,
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

  // (VISUAL CHANGE FROM CODE 2 - Layout, Padding)
  // (MODIFIED to use Code 1's Image Logic)
  Widget _buildCardContent(ArtisanProduct product) {
    return Column(
      children: [
        // Equal padding for top, left, and right sides of the image
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: AspectRatio(
            aspectRatio: 1.0, // Square image
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200], // Placeholder background
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // IMAGE LOGIC FROM CODE 1
                child: _productImagePaths.containsKey(product.id)
                  ? Image.asset(
                      _productImagePaths[product.id]!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 64, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 64, color: Colors.grey),
                    ),
              ),
            ),
          ),
        ),
        
        // Text section with center alignment
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Product name (larger text)
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Artist name (smaller text)
                Text(
                  product.artist.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  FavoritesScreen({Key? key, required this.favorites}) : super(key: key);

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
                    // We use the same image map logic here for consistency
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: _productImagePaths.containsKey(product.id)
                        ? Image.asset(
                            _productImagePaths[product.id]!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.image, color: Colors.white),
                              );
                            },
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.image, color: Colors.white),
                          ),
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

  // Helper map for the favorites screen
  final Map<String, String> _productImagePaths = {
    '1': 'assets/products/saree.jpg',
      '2': 'assets/products/pottery.jpg',
      '3': 'assets/products/elephant.jpg',
      '4': 'assets/products/jewelry.jpg',
    '5': 'assets/products/pashmina.jpg',
    '6': 'assets/products/madhubani.jpg',
    '7': 'assets/products/diya.jpg',
    '8': 'assets/products/warli.jpg',
    '9': 'assets/products/mojari.jpg',
    '10': 'assets/products/bamboo.jpg',
  };
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