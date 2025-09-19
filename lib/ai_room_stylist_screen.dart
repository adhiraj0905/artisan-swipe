// lib/ai_room_stylist_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/product.dart'; // We'll need this
import 'stylist_results_screen.dart';

class AiRoomStylistScreen extends StatefulWidget {
  final Function(ArtisanProduct) onAddToCart;
  final Function(ArtisanProduct) onAddToWishlist;

  const AiRoomStylistScreen({
    Key? key,
    required this.onAddToCart,
    required this.onAddToWishlist,
  }) : super(key: key);

  @override
  _AiRoomStylistScreenState createState() => _AiRoomStylistScreenState();
}

class _AiRoomStylistScreenState extends State<AiRoomStylistScreen> {
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _analyzeImage() {
    if (_image == null) return;

    setState(() { _isLoading = true; });

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return; // Check if the widget is still in the tree
      setState(() { _isLoading = false; });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StylistResultsScreen(
            userImage: _image!,
            onAddToCart: widget.onAddToCart,
            onAddToWishlist: widget.onAddToWishlist,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Room Stylist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_image == null)
                  const Text(
                    'Select a photo of your room to get started.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        _image!,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                if (_image == null)
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick From Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D3C98),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _analyzeImage,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Analyze Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Our AI Stylist is analyzing your space...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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