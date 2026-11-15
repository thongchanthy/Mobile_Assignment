# Mobile Application Project (REST API + Flutter Mobile App)

គម្រោង Assignment ពេញលេញ៖
1. **Backend**: RESTful API (`backend_api/`)
2. **Frontend**: Flutter Material 3 POS & Product Management with Device Preview (`mobile_app/`)

---

## 📁 រចនាសម្ព័ន្ធគម្រោង (Project Structure)

```
Mobile/
├── backend_api/             # Backend REST API Server
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
├── mobile_app/              # Mobile Client Application
│   ├── lib/
│   │   ├── config/api_config.dart
│   │   ├── models/
│   │   │   ├── category.dart
│   │   │   └── product.dart
│   │   ├── screens/
│   │   │   ├── product_list_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   └── product_form_screen.dart
│   │   ├── services/api_service.dart
│   │   └── main.dart
│   └── pubspec.yaml
│
├── 1_Start_Backend.bat      # One-click start backend
└── 2_Start_Frontend.bat     # One-click start mobile app
```

---

## 🚀 របៀបដំណើរការរហ័ស (Quick Start)

### ជម្រើសងាយស្រួលបំផុត (Double Click):
1. ចុចពីរដងលើ **`1_Start_Backend.bat`** ដើម្បីដំណើរការ Backend Server
2. ចុចពីរដងលើ **`2_Start_Frontend.bat`** ដើម្បីដំណើរការ Mobile App លើ Chrome

---

### ឬដំណើរការតាម Command Line:

#### ១. ខាង Backend (`backend_api`):
```bash
cd backend_api
composer install
copy .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
```

#### ២. ខាង Frontend (`mobile_app`):
```bash
cd mobile_app
flutter pub get
flutter run -d chrome
```

---

## 📡 API Endpoints

### Categories:
- `GET /api/categories` - បង្ហាញបញ្ជីប្រភេទទាំងអស់
- `POST /api/categories` - បន្ថែមប្រភេទថ្មី
- `GET /api/categories/{id}` - បង្ហាញប្រភេទតាម ID
- `PUT /api/categories/{id}` - កែប្រែប្រភេទ
- `DELETE /api/categories/{id}` - លុបប្រភេទ

### Products:
- `GET /api/products` - បង្ហាញបញ្ជីទំនិញ (គាំទ្រ `?search=` និង `?category_id=`)
- `POST /api/products` - បន្ថែមទំនិញថ្មី (គាំទ្រ Image upload ពី Device)
- `GET /api/products/{id}` - បង្ហាញទំនិញតាម ID
- `PUT /api/products/{id}` - កែប្រែទំនិញ
- `DELETE /api/products/{id}` - លុបទំនិញ (Soft delete `isDeleted = 1`)
