import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SwipeDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SwipeDemo extends StatefulWidget {
  @override
  _SwipeDemoState createState() => _SwipeDemoState();
}

class _SwipeDemoState extends State<SwipeDemo> {
  late List<SwipeItem> _swipeItems;
  late MatchEngine _matchEngine;

  @override
  void initState() {
    super.initState();

    List<String> titles = ["Glass Work", "charlie pood", "donald"];
    List<String> subtitles = ["The Glass Animal", "twink", "Minimal Streetwear"];
    List<String> images = [
      "assets/art1.png",
      "assets/art2.png",
      "assets/art3.png",
    ];

    _swipeItems = [];

    for (int i = 0; i < titles.length; i++) {
      _swipeItems.add(
        SwipeItem(
          content: {
            "title": titles[i],
            "subtitle": subtitles[i],
            "image": images[i],
          },
          likeAction: () {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("OPLETH"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Container(
          height: 500,
          child: SwipeCards(
            matchEngine: _matchEngine,
            itemBuilder: (BuildContext context, int index) {
              var data = _swipeItems[index].content as Map<String, String>;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.asset(
                          data["image"]!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      data["title"]!,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      data["subtitle"]!,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 10),
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
