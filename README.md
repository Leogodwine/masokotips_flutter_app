# Masoko Tips

A Flutter mobile application for buying and selling agricultural products and services.

## Features

- **User Authentication**: Secure login and registration
- **User Profile Management**: Edit profile, manage addresses, security settings
- **Product Browsing**: Browse agricultural products and services
- **Shopping Cart**: Add products to cart and checkout
- **Wishlist**: Save favorite items for later
- **Order Management**: Track and manage orders

## Screenshots

Coming soon...

## Getting Started

### Prerequisites

- Flutter (2.0.0 or later)
- Dart (2.12.0 or later)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/masoko_tips.git
cd masoko_tips
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Testing

The app includes mock data for testing purposes. To log in with a test account:

- Email: john.doe@example.com
- Password: password123

Alternatively, you can initialize the mock user by calling:
```dart
ProfileManager.initializeMockProfile(context);
```

## Project Structure

- **lib/models/**: Data models
- **lib/providers/**: State management providers
- **lib/screens/**: UI screens
- **lib/services/**: API services
- **lib/utils/**: Utility functions
- **lib/widgets/**: Reusable widgets

## User Profile Management System

The User Profile Management system includes:

1. **Profile Screen**: View user information
2. **Edit Profile**: Update personal information, avatar
3. **Address Management**: Add, edit, and delete delivery addresses
4. **Security Settings**: Change password and security preferences

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to the Flutter team for the amazing framework
- All contributors and supporters of the project
