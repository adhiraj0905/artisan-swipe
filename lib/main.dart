import 'package:flutter/material.dart';
import 'models/product.dart';
import 'services/product_service.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'ai_room_stylist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------------------- DATA MODELS ----------------------

class CartItem {
  final ArtisanProduct product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
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
  final List<CartItem> _cartItems = [];

  bool _showNotification = false;
  String _notificationMessage = '';
  Timer? _notificationTimer;

  // In _MainScreenState
  Color _notificationColor = Colors.green; // Default color

  @override
  void dispose() {
    _notificationTimer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  // In _MainScreenState, modify this method
  void _showCustomNotification(String message, {Color color = Colors.green}) { // Added color parameter
    _notificationTimer?.cancel();

    setState(() {
      _notificationMessage = message;
      _notificationColor = color; // Set the color
      _showNotification = true;
    });

    _notificationTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });
  }

  void _removeFromWishlist(ArtisanProduct product) {
    setState(() {
      _favorites.removeWhere((item) => item.id == product.id);
    });
  }

  void _addToCart(ArtisanProduct product) {
    setState(() {
      // Logic to add the item to the cart (you already have this)
      final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex].quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
      
      // --- ADD THIS LINE ---
      // Remove the same item from the favorites list
      _favorites.removeWhere((item) => item.id == product.id);
      

      // Show a confirmation message
      _showCustomNotification('${product.title} added to bag.');
    });
  }
  // Inside _MainScreenState in lib/main.dart

  void _addToWishlist(ArtisanProduct product) {
    setState(() {
      if (!_favorites.any((fav) => fav.id == product.id)) {
        _favorites.add(product);
        _showCustomNotification('${product.title} added to wishlist.');
      }
    });
  }

  Widget _buildCustomNotification() {
  // Use AnimatedPositioned to slide the widget up from the bottom
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      // Position it above the nav bar when shown, or hidden below the screen
      bottom: _showNotification ? 80.0 : -100.0,
      left: 12,
      right: 12,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: _notificationColor.withOpacity(0.25), // Use the state variable
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _notificationColor.withOpacity(0.4)),
              ),
              child: Text(
                _notificationMessage,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateItemQuantity(CartItem item, int change) {
    setState(() {
      item.quantity += change;
      if (item.quantity <= 0) {
        _cartItems.remove(item);
      }
    });
  }

  void _navigateToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
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
              SearchScreen(
      onNavigateHome: _navigateToHome,
      onAddToCart: _addToCart,
      onAddToWishlist: _addToWishlist,
    ),
              WishlistScreen(
                favorites: _favorites,
                onRemoveFromWishlist: _removeFromWishlist,
                onAddToCart: _addToCart,
                onAddAllToCart: _addAllWishlistToCart,
              ),
              const ProfileScreen(),
              CartScreen(
                cartItems: _cartItems,
                onUpdateQuantity: _updateItemQuantity,
                onMoveToWishlist: _moveToWishlist,
              ),
            ],
          ),
          _buildFrostedNavBar(),
          _buildCustomNotification(), // Add the custom notification widget
        ],
      ),
    );
  }

  Widget _buildFrostedNavBar() {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardOpen) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 0),
                  _buildNavItem(Icons.search, 1),
                  _buildNavItem(Icons.favorite_border, 2, label: "Wishlist"),
                  _buildNavItem(Icons.person_outline, 3),
                  _buildNavItem(Icons.shopping_bag_outlined, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {String? label}) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 26,
      color: _currentIndex == index
          ? Colors.white
          : Colors.white.withOpacity(0.6),
      onPressed: () => setState(() => _currentIndex = index),
      tooltip: label,
    );
  }

  void _moveToWishlist(CartItem cartItem) {
    setState(() {
      // Add to favorites if it's not already there
      if (!_favorites.any((product) => product.id == cartItem.product.id)) {
        _favorites.add(cartItem.product);
      }
      // Remove from cart
      _cartItems.remove(cartItem);

      _showCustomNotification(
        '${cartItem.product.title} moved to wishlist.',
        color: Colors.blueAccent, // A nice blue for this action
      );
    });
  }
  // In _MainScreenState

  void _addAllWishlistToCart() {
    if (_favorites.isEmpty) return; // Do nothing if the wishlist is empty

    setState(() {
      // Go through each product in the wishlist
      for (var product in _favorites) {
        // Use the same logic as _addToCart to add/update quantity
        final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
        if (existingItemIndex != -1) {
          _cartItems[existingItemIndex].quantity++;
        } else {
          _cartItems.add(CartItem(product: product));
        }
      }

      // Clear the entire wishlist after adding them to the cart
      _favorites.clear();
    });

    // Show a confirmation notification
    _showCustomNotification('All wishlist items added to bag.');
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

    if (_cardOffset.dx.abs() > 100) {
      if (_cardOffset.dx > 0) {
        _swipeRight();
      } else {
        _swipeLeft();
      }
    } else {
      setState(() {
        _cardOffset = Offset.zero;
        _cardAngle = 0;
      });
    }
  }

  void _swipeRight() {
    _animateCard(const Offset(400, 0), () {
      if (_currentIndex < _products.length) {
        final product = _products[_currentIndex];
        widget.onLike(product);
        _likedProductIds.add(product.id);
      }
      _nextCard();
    });
  }

  void _swipeLeft() {
    _animateCard(const Offset(-400, 0), () {
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

  // In _SwipeDemoState, replace your entire _buildBody method with this one

Widget _buildBody() {
  // --- All your initial checks for loading, error, and empty products remain the same ---
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

  // --- THIS IS THE CORRECTED LAYOUT ---
  return SafeArea(
    child: Stack( // Use a Stack instead of a Column
      children: [
        // The Title, aligned to the top center of the screen
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0), // Padding from the top edge
            child: Text(
              'OPELITH',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w300,
                letterSpacing: 3,
              ),
            ),
          ),
        ),

        // The Card Stack, now perfectly centered in the available space
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Furthest back card
              if (_currentIndex + 3 < _products.length)
                Transform.translate(
                  offset: const Offset(0, -45),
                  child: _buildStaticCard(_products[_currentIndex + 3]),
                ),

              // Middle card
              if (_currentIndex + 2 < _products.length)
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: _buildStaticCard(_products[_currentIndex + 2]),
                ),

              // Closest background card
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
                        onTap: () { 
                          if (_currentIndex < _products.length) {
                            _showProductDetails(_products[_currentIndex]);
                          }
                        },
                        child: _buildProductCard(_products[_currentIndex]),
                      ),
                    ),
                  ),
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
        glowColor = Colors.green;
        glowIntensity = (_cardOffset.dx / 200).clamp(0.0, 1.0);
      } else {
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
      width: 300,
      height: 410,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _buildCardContent(product),
    );
  }

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
          if (_isDragging && _cardOffset.dx.abs() > 50)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: (_cardOffset.dx > 0 ? Colors.green : Colors.red)
                    .withOpacity(0.2),
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
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _productImagePaths.containsKey(product.id)
                    ? Image.asset(
                        _productImagePaths[product.id]!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image,
                                size: 64, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image,
                            size: 64, color: Colors.grey),
                      ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

  void _showProductDetails(ArtisanProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to be almost full-screen
      backgroundColor: Colors.transparent, // Important for the frosted glass effect
      builder: (context) {
        // We will create this new widget in the next step
        return ProductDetailsSheet(product: product);
      },
    );
  }
}

// ---------------------- SEARCH SCREEN ----------------------
class SearchScreen extends StatefulWidget {
  final VoidCallback onNavigateHome;
  final Function(ArtisanProduct) onAddToCart;
  final Function(ArtisanProduct) onAddToWishlist;
  const SearchScreen({
    Key? key,
    required this.onNavigateHome,
    required this.onAddToCart,
    required this.onAddToWishlist,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;

  final List<String> _categories = [
    'Painting', 'Drawing', 'Sculpture', 'Printmaking', 
    'Photograph', 'Digital Art', 'Glass Work'
  ];
  final List<String> _searchHistory = ['Glass', 'Human'];
  final List<String> _popularSearches = ['Glass', 'Pot', 'Rug'];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isSearching = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // In lib/main.dart, replace the whole build method in _SearchScreenState

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (_isSearching) {
          setState(() {
            _focusNode.unfocus();
          });
        } else {
          widget.onNavigateHome();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // The FloatingActionButton has been REMOVED from here.
        body: GestureDetector(
          onTap: () => _focusNode.unfocus(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  
                  // --- NEW BUTTON ADDED HERE ---
                  // Only show this button when the user is NOT actively typing in the search bar
                  if (!_isSearching)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome, color: Colors.white),
                        label: const Text(
                          'AI Room Stylist',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AiRoomStylistScreen(
                                onAddToCart: widget.onAddToCart,
                                onAddToWishlist: widget.onAddToWishlist,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7D3C98).withOpacity(0.5),
                          minimumSize: const Size(double.infinity, 50), // Make it full-width
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: const Color(0xFF7D3C98)),
                        ),
                      ),
                    ),

                  Expanded(
                    child: _isSearching
                        ? _buildActiveSearchView()
                        : _buildCategoriesView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  _searchController.clear();
                  _focusNode.unfocus();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.grey),
        const SizedBox(height: 20),
        const Text(
          'CATEGORIES',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_categories[index],
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 16),
                onTap: () {
                  print('Tapped on ${_categories[index]}');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSearchView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SEARCH HISTORY',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchHistory.clear();
                });
              },
              child: const Text('CLEAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        ..._searchHistory
            .map((term) =>
                Text(term, style: const TextStyle(color: Colors.white, fontSize: 16)))
            .toList(),
        const SizedBox(height: 30),
        const Text('POPULAR SEARCHES',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 10),
        ..._popularSearches
            .map((term) =>
                Text(term, style: const TextStyle(color: Colors.white, fontSize: 16)))
            .toList(),
      ],
    );
  }
}

// ---------------------- WISHLIST SCREEN ----------------------
class WishlistScreen extends StatelessWidget {
  final List<ArtisanProduct> favorites;
  final Function(ArtisanProduct) onRemoveFromWishlist;
  final Function(ArtisanProduct) onAddToCart;
  final VoidCallback onAddAllToCart; // Add this

  WishlistScreen({
    Key? key,
    required this.favorites,
    required this.onRemoveFromWishlist,
    required this.onAddToCart,
    required this.onAddAllToCart, // Add this
  }) : super(key: key);

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

  // In WishlistScreen, replace the entire build method with this one

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Padding( // <-- 1. WRAP the Column with Padding
        padding: const EdgeInsets.only(bottom: 80.0), // <-- 2. ADD bottom padding here
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Wishlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? _buildEmptyView()
                  : ListView.builder(
                      // 3. REMOVE the old bottom padding from here
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), 
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final product = favorites[index];
                        return _buildWishlistItem(product);
                      },
                    ),
            ),
            if (favorites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onAddAllToCart,
                    child: const Text('Add all to bag',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildWishlistItem(ArtisanProduct product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFC3B1E1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              _productImagePaths[product.id] ??
                  'assets/products/placeholder.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[800],
                child: const Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(product.artist.name,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 4),
                Text(product.formattedPrice,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => onAddToCart(product),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add to bag'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: () => onRemoveFromWishlist(product),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Your Wishlist is Empty",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            "Swipe right on products to save them.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------- PROFILE SCREEN ----------------------
// In main.dart, replace the existing ProfileScreen class

// REPLACE your old ProfileScreen class with this simplified version

// REPLACE your old ProfileScreen class with this one

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. The Background Image
          SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Image.asset(
              'assets/background/yoursTruly.jpg', // Make sure this is your exact filename
              fit: BoxFit.cover,
            ),
          ),

          // 2. The Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Top Spacer ---
                  // This flexible space pushes the content down from the top
                  const Spacer(flex: 2),

                  // --- User Name ---
                  Text(
                    'HI ADHIRAJ!',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),

                  // --- Middle Spacer ---
                  // This creates a proportional gap between the name and the menu
                  const Spacer(flex: 1),
                  
                  // --- Menu Items ---
                  // This column holds your list of options
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuItem('PROFILE'),
                      _buildMenuItem('ORDERS'),
                      _buildMenuItem('ADDRESSES'),
                      _buildMenuItem('REFUNDS'),
                      _buildMenuItem('GIFT CARDS'),
                      _buildMenuItem('RATE AND REVIEW'),
                      _buildMenuItem('SCREEN MODE'),
                      _buildMenuItem('SETTINGS'),
                      _buildMenuItem('ONLINE ORDER HELP'),
                    ],
                  ),

                  // --- Bottom Spacer ---
                  // This pushes the menu up from the bottom, ensuring it's not too low
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
// ---------------------- CART SCREEN ----------------------
// REPLACE your old CartScreen StatefulWidget and its State with this

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(CartItem, int) onUpdateQuantity;
  final Function(CartItem) onMoveToWishlist; // Add this

  const CartScreen({
    Key? key,
    required this.cartItems,
    required this.onUpdateQuantity,
    required this.onMoveToWishlist, // Add this
  }) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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

  double get _subtotal {
    if (widget.cartItems.isEmpty) return 0;
    return widget.cartItems.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Padding( // <-- 1. WRAP the Column with a Padding widget
        padding: const EdgeInsets.only(bottom: 80.0), // <-- 2. ADD this line of padding
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Shopping bag',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: widget.cartItems.isEmpty
                  ? _buildEmptyCart()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        return _buildCartItemCard(item);
                      },
                    ),
            ),
            // We keep the summary view as it's essential for a cart
            if (widget.cartItems.isNotEmpty) _buildSummary(),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFC3B1E1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              _productImagePaths[item.product.id] ?? 'assets/placeholder.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(item.product.artist.name,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 4),
                Text(item.product.formattedPrice,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 8),
                // Replaced "Move to Wishlist" button with quantity controls
                Row(
                  children: [
                    const Text("Quantity:", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                      onPressed: () => widget.onUpdateQuantity(item, -1),
                    ),
                    Text(item.quantity.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                      onPressed: () => widget.onUpdateQuantity(item, 1),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Action Icons
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: "Remove from bag",
                onPressed: () => widget.onUpdateQuantity(item, -item.quantity), // Set quantity to 0 to remove
              ),
              IconButton(
                icon: const Icon(Icons.favorite_outline, color: Colors.white),
                tooltip: "Move to Wishlist",
                onPressed: () => widget.onMoveToWishlist(item),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    // This can remain the same
    return const Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Your bag is empty",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
    );
  }

  Widget _buildSummary() {
    // This can remain the same
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(
                'Rs. ${_subtotal.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () { /* TODO: Checkout flow */ },
              child: const Text('Proceed to Checkout',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this new widget class to your file

class ProductDetailsSheet extends StatelessWidget {
  final ArtisanProduct product;

  const ProductDetailsSheet({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This widget makes the sheet draggable and scrollable
    return DraggableScrollableSheet(
      initialChildSize: 0.9, // Start at 90% of screen height
      minChildSize: 0.5,     // Can be dragged down to 50%
      maxChildSize: 0.9,     // Can be dragged up to 90%
      builder: (_, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC3B1E1).withOpacity(0.3), // Light purple glass color
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: _buildContent(context, scrollController),
            ),
          ),
        );
      },
    );
  }

  // In ProductDetailsSheet, replace the _buildContent method with this one

Widget _buildContent(BuildContext context, ScrollController scrollController) {
  return ListView(
    controller: scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    children: [
      // Header with Pull-down indicator and Back button
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Container( // The little pull-down bar
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 48), // Balances the IconButton for centering
          ],
        ),
      ),

      // Product Details
      Text(product.title, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(product.artist.name, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      const SizedBox(height: 24),
      Text(
        'Introducing the ${product.title}',
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Text(
        product.description,
        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
      ),
      const SizedBox(height: 24),
      const Text(
        'Dimensions',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      // Here you would map over your product's actual dimensions
      _buildDimensionRow('Diameter: 18-22 cm (about the size of a basketball)'),
      _buildDimensionRow('Thickness of each strand: 2.5-3 cm'),
      _buildDimensionRow('Weight: 1.5-2.5 kg'),
      const SizedBox(height: 24),
        
      // --- TAGS SECTION COMMENTED OUT ---
      // const Text(
      //   'Tags',
      //   style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      // ),
      // const SizedBox(height: 8),
      // Wrap( 
      //   spacing: 8.0,
      //   runSpacing: 8.0,
      //   children: product.tags.map((tag) => Chip(
      //     label: Text(tag),
      //     backgroundColor: Colors.white.withOpacity(0.2),
      //     labelStyle: const TextStyle(color: Colors.white),
      //   )).toList(),
      // ),
      // --- END OF TAGS SECTION ---

      const SizedBox(height: 40), // Extra padding at the bottom
    ],
  );
}

  // Helper widget for the bulleted list
  Widget _buildDimensionRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(color: Colors.white70, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 16))),
        ],
      ),
    );
  }
}

