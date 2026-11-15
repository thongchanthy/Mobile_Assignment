# Mobile Application Project (Laravel REST API + Flutter CRUD)

គម្រោង Assignment ពេញលេញ៖
1. **Backend**: Laravel 11 RESTful API (`laravel_api/`)
2. **Frontend**: Flutter Material 3 CRUD Application with Device Preview & Image Upload (`flutter_product_crud/`)

---

## 📁 រចនាសម្ព័ន្ធគម្រោង (Project Structure)

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

## 🚀 របៀបដំឡើង និងដំណើរការសម្រាប់អ្នក Clone ថ្មី (Setup Instructions)

### ជំហានទី ១៖ Clone កូដពី GitHub
```bash
git clone https://github.com/kreombroskoy-bbu/Mobile.git
cd Mobile
```

---

### ជំហានទី ២៖ ដំឡើង និងដំណើរការ Laravel Backend (`laravel_api`)

បើក Terminal ចូលទៅក្នុង folder `laravel_api`៖
```bash
cd laravel_api
```

1. **ដំឡើង Packages (Composer):**
   ```bash
   composer install
   ```

2. **បង្កើត file `.env` និង App Key:**
   - លើ Windows (CMD/PowerShell):
     ```bash
     copy .env.example .env
     php artisan key:generate
     ```
   - លើ Mac/Linux:
     ```bash
     cp .env.example .env
     php artisan key:generate
     ```

3. **រៀបចំ Database និង Seed ទិន្នន័យគំរូ:**
   - **ជម្រើសទី ១ (ងាយស្រួលបំផុត - SQLite):**
     មិនបាច់បើក XAMPP ឬបង្កើត database អ្វីឡើយ គ្រាន់តែវាយ៖
     ```bash
     php artisan migrate --seed
     ```
     *(បើវាសួរថាបង្កើត database.sqlite ឬអត់ សូមចុច Enter ឬវាយ `yes`)*

   - **ជម្រើសទី ២ (ប្រើ MySQL / XAMPP):**
     បើក XAMPP Start Apache & MySQL រួចចូល `http://localhost/phpmyadmin` បង្កើត database ឈ្មោះ `laravel` (ឬ `mobile_db`)។
     បន្ទាប់មកបើក file `.env` កែសម្រួល៖
     ```env
     DB_CONNECTION=mysql
     DB_HOST=127.0.0.1
     DB_PORT=3306
     DB_DATABASE=laravel
     DB_USERNAME=root
     DB_PASSWORD=
     ```
     រួចរត់ migration៖
     ```bash
     php artisan migrate --seed
     ```

4. **បង្កើត Storage Link សម្រាប់រូបភាព:**
   ```bash
   php artisan storage:link
   ```

5. **Start Laravel Server:**
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```
   *Laravel API នឹងដំណើរការនៅ៖ `http://127.0.0.1:8000/api`*

---

### ជំហានទី ៣៖ ដំឡើង និងដំណើរការ Flutter Frontend (`flutter_product_crud`)

បើក Terminal ថ្មីមួយទៀត រួចចូលទៅក្នុង folder `flutter_product_crud`៖
```bash
cd flutter_product_crud
```

1. **ទាញយក Flutter Packages:**
   ```bash
   flutter pub get
   ```

2. **ដំណើរការ App (Run Application):**
   - **រត់លើ Web (Chrome - ស្រួលមើល និងមាន Device Preview):**
     ```bash
     flutter run -d chrome
     ```
   - **រត់លើ Android Emulator:**
     ```bash
     flutter run
     ```
   - **រត់លើ Windows Desktop:**
     ```bash
     flutter run -d windows
     ```

---

## ⚙️ ការកំណត់ Base URL ក្នុង Flutter (API Configuration)

- ពេលរត់លើ **Chrome (Web) ឬ Windows**: App នឹងភ្ជាប់ទៅ `http://127.0.0.1:8000/api` ដោយស្វ័យប្រវត្តិ។
- ពេលរត់លើ **Android Emulator**: App នឹងភ្ជាប់ទៅ `http://10.0.2.2:8000/api` ដោយស្វ័យប្រវត្តិ។
- ប្រសិនបើចង់ប្តូរ IP ដោយខ្លួនឯង៖ អាចចុចលើ **Icon Settings (⚙️)** នៅជ្រុងខាងស្តាំខាងលើនៃ App រួចបញ្ចូល Base URL ដែលចង់បានភ្លាមៗ!

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
