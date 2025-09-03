# Masoko Tips - Agricultural Marketplace Platform

A comprehensive agricultural marketplace platform connecting farmers, traders, and service providers in Tanzania. Features both web and mobile applications with integrated APIs for seamless cross-platform experience.

## 🌟 Platform Overview

- **🌐 Web Application**: Laravel-based responsive web platform with modern UI/UX
- **📱 Mobile Application**: Flutter-based cross-platform mobile app  
- **🔌 API Backend**: RESTful API serving both web and mobile applications
- **🌍 Location**: Tanzania, East Africa
- **🎯 Mission**: Empowering agricultural communities through digital commerce

## ✨ Key Features

### 🌐 Web Application Features
- **Featured Products**: Dynamic product display with real-time data from database
- **Featured Services**: Agricultural and transport services showcase
- **Responsive Design**: Mobile-first, Bootstrap 5-powered interface
- **User Authentication**: Secure login/registration system
- **Product Management**: Browse, search, and filter products by category
- **Service Discovery**: Find agricultural and transport services
- **Contact & Support**: Help center, contact forms, FAQ system
- **Legal Pages**: Privacy policy, terms of service, cookie policy
- **Shopping Cart**: Add to cart, wishlist, and checkout functionality
- **Category Navigation**: Organized product and service categories

### 📱 Mobile Application Features
- **User Authentication**: Secure login and registration
- **User Profile Management**: Edit profile, manage addresses, security settings
- **Product Browsing**: Browse agricultural products and services
- **Shopping Cart**: Add products to cart and checkout
- **Wishlist**: Save favorite items for later
- **Order Management**: Track and manage orders

## 🛠️ Technology Stack

### Backend
- **Framework**: Laravel 10.x
- **Database**: MySQL
- **API**: RESTful API with JSON responses
- **Authentication**: Laravel Sanctum
- **Caching**: Laravel Cache with Redis support

### Web Frontend  
- **Framework**: Laravel Blade Templates
- **CSS Framework**: Bootstrap 5 + Custom CSS
- **JavaScript**: Vanilla JS + Fetch API
- **Responsive**: Mobile-first design
- **Icons**: Font Awesome

### Mobile Application
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider pattern
- **Platforms**: Android & iOS
- **Architecture**: Clean Architecture with MVVM

## 🚀 Getting Started

### Prerequisites

- **For Web App**: PHP 8.1+, Composer, MySQL, Node.js
- **For Mobile App**: Flutter 3.0+, Dart 2.17+, Android Studio / VS Code
- **For API**: Laravel 10.x, MySQL 8.0+

### Web Application Installation

1. Clone the repository:
```bash
git clone https://github.com/wegazi/masoko_tips_api_v2.git
cd masoko_tips_api_v2
```

2. Install PHP dependencies:
```bash
composer install
```

3. Set up environment:
```bash
cp .env.example .env
php artisan key:generate
```

4. Configure database and run migrations:
```bash
php artisan migrate
php artisan db:seed
```

5. Start the development server:
```bash
php artisan serve
```

### Mobile Application Installation

1. Navigate to the mobile app directory:
```bash
cd masoko_tips
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 🔌 API Endpoints

### Featured Products
- `GET /api/products/featured` - Get featured products
- `GET /web/featured-products` - Web frontend featured products

### Featured Services  
- `GET /api/services/featured` - Get featured services
- `GET /web/featured-services` - Web frontend featured services

### Public Routes
- `GET /services` - Public services listing
- `GET /categories/products/{category}` - Product categories
- `GET /products/{id}` - Product details

## 📱 Testing

The mobile app includes mock data for testing purposes. To log in with a test account:

- Email: john.doe@example.com
- Password: password123

Alternatively, you can initialize the mock user by calling:
```dart
ProfileManager.initializeMockProfile(context);
```

## 🏗️ Project Structure

### Web Application
```
masoko_tips_api_v2/
├── app/Http/Controllers/Web/     # Web controllers
├── app/Http/Controllers/Api/     # API controllers  
├── resources/views/              # Blade templates
├── public/css/                   # Stylesheets
├── routes/                       # Web and API routes
└── database/                     # Migrations and seeders
```

### Mobile Application
```
masoko_tips/
├── lib/models/                   # Data models
├── lib/providers/                # State management providers
├── lib/screens/                  # UI screens
├── lib/services/                 # API services
├── lib/utils/                    # Utility functions
└── lib/widgets/                  # Reusable widgets
```

## 🌟 Recent Features

### Featured Products & Services Integration
- Dynamic loading of featured products and services on landing page
- Real-time data from database via existing mobile app APIs
- Interactive product/service cards with hover effects
- Seamless integration with existing shopping cart and wishlist
- Responsive design for all device sizes

### Enhanced User Experience
- Contact and About pages with professional design
- Help Center with comprehensive FAQ system
- Legal pages (Privacy Policy, Terms of Service, Cookie Policy)
- Consistent navigation across all pages
- Mobile-responsive design throughout

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Thanks to the Flutter team for the amazing framework
- Thanks to the Laravel team for the robust PHP framework
- All contributors and supporters of the project
- The agricultural community in Tanzania for inspiration

## 📞 Contact

- **Phone**: +255 718 814 918
- **Location**: Moshi, Tanzania
- **Email**: info@masokotips.com
- **Website**: [https://masokotips.com](https://masokotips.com)

---

**Built with ❤️ for Tanzania's agricultural community**
