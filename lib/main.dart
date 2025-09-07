import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Map<String, String>> _favorites = []; // Liked items
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      SwipeDemo(
        onLike: (item) {
          setState(() {
            if (!_favorites.contains(item)) _favorites.add(item);
          });
        },
      ),
      SearchScreen(),
      FavoritesScreen(favorites: _favorites),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SwipeDemo(
            onLike: (item) {
              setState(() {
                if (!_favorites.contains(item)) _favorites.add(item);
              });
            },
          ),
          SearchScreen(),
          FavoritesScreen(favorites: _favorites),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: [
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
  final Function(Map<String, String>) onLike;

  SwipeDemo({required this.onLike});

  @override
  _SwipeDemoState createState() => _SwipeDemoState();
}

class _SwipeDemoState extends State<SwipeDemo> {
  late List<SwipeItem> _swipeItems;
  late MatchEngine _matchEngine;

  @override
  void initState() {
    super.initState();

    List<String> titles = ["Glass Work", "Charlie Pood", "Donald"];
    List<String> subtitles = ["The Glass Animal", "Twink", "Minimal Streetwear"];
    List<String> images = [
      "assets/art1.png",
      "assets/art2.png",
      "assets/art3.png",
    ];

    _swipeItems = [];

    for (int i = 0; i < titles.length; i++) {
      Map<String, String> item = {
        "title": titles[i],
        "subtitle": subtitles[i],
        "image": images[i],
      };

      _swipeItems.add(
        SwipeItem(
          content: item,
          likeAction: () {
            widget.onLike(item); // Add to favorites
            print("Liked ${titles[i]}");
          },
          nopeAction: () {
            print("Disliked ${titles[i]}");
          },
        ),
      );
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
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
      child: Center(
        child: Container(
          height: 550,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SwipeCards(
            matchEngine: _matchEngine,
            itemBuilder: (BuildContext context, int index) {
              var data = _swipeItems[index].content as Map<String, String>;
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
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        child: Image.asset(
                          data["image"]!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      data["title"]!,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      data["subtitle"]!,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              );
            },
            onStackFinished: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No more cards!")),
              );
            },
            upSwipeAllowed: true,
            fillSpace: true,
          ),
        ),
      ),
    );
  }
}

// ---------------------- SEARCH SCREEN ----------------------
class SearchScreen extends StatelessWidget {
  final List<String> categories = [
    "Pottery", "Textiles", "Jewelry", "Paintings", "Woodwork"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search products...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((cat) => Chip(label: Text(cat))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- FAVORITES SCREEN ----------------------
class FavoritesScreen extends StatelessWidget {
  final List<Map<String, String>> favorites;

  FavoritesScreen({required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Colors.deepPurple,
      ),
      body: favorites.isEmpty
          ? Center(child: Text("Your liked products will appear here."))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                var item = favorites[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.asset(item["image"]!, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(item["title"]!),
                    subtitle: Text(item["subtitle"]!),
                  ),
                );
              },
            ),
    );
  }
}

// ---------------------- PROFILE SCREEN ----------------------
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text("User Profile (coming soon)"),
      ),
    );
  }
}
