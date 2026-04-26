# Artisan Swipe

Artisan Swipe is a Flutter-based mobile application designed to help users discover and purchase unique artisanal products from around the world. The app features an intuitive, Tinder-like swipe interface for browsing items, along with a powerful AI-driven Room Stylist to provide personalized recommendations.

## Features

  * **Swipe to Discover:** A fun and engaging way to browse through a curated collection of artisan products. Swipe right to like an item and add it to your wishlist, or swipe left to pass.
  * **AI Room Stylist:** Get personalized recommendations by simply uploading a photo of your room. Our AI will suggest products that complement your space.
  * **Search and Categories:** Easily find specific items with a powerful search functionality and browse through various product categories.
  * **Wishlist:** Save your favorite items in a wishlist for later viewing and purchase.
  * **Shopping Cart:** A fully functional shopping cart to manage your selected items and proceed to checkout.
  * **User Profile:** A dedicated screen for users to manage their profile and view their order history.

## Technologies Used

  * **Flutter:** The UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
  * **Firebase:** A comprehensive mobile and web application development platform.
      * **Cloud Firestore:** A NoSQL document database for storing product and user data.
  * **Dart:** The programming language used for Flutter development.
  * **Provider:** A state management solution for Flutter applications.
  * **Google Fonts:** A library of free and open-source fonts.
  * **swipe\_cards:** A Flutter package for creating a swipeable card interface.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

  * Flutter SDK: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
  * A code editor like VS Code or Android Studio.

### Installation

1.  Clone the repo
    ```sh
    git clone https://github.com/adhiraj0905/artisan-swipe.git
    ```
2.  Install packages
    ```sh
    flutter pub get
    ```
3.  Run the app
    ```sh
    flutter run
    ```

## Project Structure

The project follows a standard Flutter project structure, with the core application logic located in the `lib` directory.

```
lib/
├── ai_room_stylist_screen.dart  # AI Room Stylist feature
├── firebase_options.dart      # Firebase configuration
├── main.dart                  # Main application entry point
├── models/
│   └── product.dart           # Data models for products and artists
├── services/
│   └── product_service.dart   # Service for interacting with Firestore
├── stylist_results_screen.dart# UI for displaying AI recommendations
└── widgets/
    └── swipe_demo.dart        # The main swipe card widget
```



