<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class CategoryAndProductSeeder extends Seeder
{
    public function run(): void
    {
        $electronics = Category::create([
            'category_name' => 'Electronics',
            'description'   => 'Smartphones, laptops, and gadgets',
            'image'         => 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=500',
        ]);

        $beverages = Category::create([
            'category_name' => 'Beverages',
            'description'   => 'Drinks, coffee, tea, and juice',
            'image'         => 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500',
        ]);

        $snacks = Category::create([
            'category_name' => 'Snacks & Food',
            'description'   => 'Biscuits, chips, and snacks',
            'image'         => 'https://images.unsplash.com/photo-1621996346565-e3d5d6281691?w=500',
        ]);

        Product::create([
            'ProductName'  => 'iPhone 15 Pro Max',
            'Description'  => '256GB Natural Titanium, Super Retina XDR display',
            'CategoryID'   => $electronics->category_id,
            'Barcode'      => '8806091234567',
            'Expiredate'   => '2028-12-31',
            'Qty'          => 15,
            'UnitPriceIn'  => 950.00,
            'UnitPriceOut' => 1199.00,
            'ProductImage' => 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500',
            'isDeleted'    => 0,
        ]);

        Product::create([
            'ProductName'  => 'MacBook Air M2',
            'Description'  => '13.6-inch Liquid Retina Display, 8GB RAM, 256GB SSD',
            'CategoryID'   => $electronics->category_id,
            'Barcode'      => '8806099876543',
            'Expiredate'   => '2029-01-01',
            'Qty'          => 8,
            'UnitPriceIn'  => 850.00,
            'UnitPriceOut' => 1050.00,
            'ProductImage' => 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500',
            'isDeleted'    => 0,
        ]);

        Product::create([
            'ProductName'  => 'Iced Caramel Macchiato',
            'Description'  => 'Rich espresso with vanilla syrup and caramel drizzle',
            'CategoryID'   => $beverages->category_id,
            'Barcode'      => '1234567890123',
            'Expiredate'   => '2026-11-20',
            'Qty'          => 50,
            'UnitPriceIn'  => 1.20,
            'UnitPriceOut' => 3.25,
            'ProductImage' => 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500',
            'isDeleted'    => 0,
        ]);
    }
}
