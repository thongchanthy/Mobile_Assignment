# Mobile Application Project (Laravel REST API + Flutter CRUD)

This repository contains the complete mobile application assignment solution:
1. **Backend**: Laravel 11 RESTful API (`laravel_api/`)
2. **Frontend**: Flutter Material 3 Cross-platform CRUD Application with Device Preview & Device Image Picker (`flutter_product_crud/`)

---

## 📁 Project Structure

```
Mobile/
├── laravel_api/             # Laravel Backend REST API
│   ├── app/Http/Controllers/Api/
│   │   ├── CategoryController.php
│   │   └── ProductController.php
│   ├── app/Models/
│   │   ├── Category.php
│   │   └── Product.php
│   ├── database/migrations/
│   │   ├── 2026_11_15_000001_create_categories_table.php
│   │   └── 2026_11_15_000002_create_products_table.php
│   └── routes/api.php
│
└── flutter_product_crud/    # Flutter Mobile Client
    ├── lib/
    │   ├── config/api_config.dart
    │   ├── models/
    │   │   ├── category.dart
    │   │   └── product.dart
    │   ├── screens/
    │   │   ├── product_list_screen.dart
    │   │   ├── product_detail_screen.dart
    │   │   └── product_form_screen.dart
    │   ├── services/api_service.dart
    │   └── main.dart
    └── pubspec.yaml
```

---

## 🚀 Getting Started

### 1. Run Laravel Backend (`laravel_api`)
```bash
cd laravel_api
composer install
php artisan migrate --seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
```
- API Base URL: `http://127.0.0.1:8000/api`

### 2. Run Flutter Client (`flutter_product_crud`)
```bash
cd flutter_product_crud
flutter pub get
flutter run -d chrome
# or on Android emulator:
# flutter run
```

---

## 📡 API Endpoints

### Categories:
- `GET /api/categories` - List all categories
- `POST /api/categories` - Create new category
- `GET /api/categories/{id}` - Get category by ID
- `PUT /api/categories/{id}` - Update category
- `DELETE /api/categories/{id}` - Delete category

### Products:
- `GET /api/products` - List all products (supports `?search=` and `?category_id=`)
- `POST /api/products` - Create new product (supports device image upload)
- `GET /api/products/{id}` - Get product by ID
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product (soft delete `isDeleted = 1`)
