<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $table = 'products';
    protected $primaryKey = 'ProductID';

    // Disable automatic timestamps as table does not have created_at/updated_at
    public $timestamps = false;

    protected $fillable = [
        'ProductName',
        'Description',
        'CategoryID',
        'Barcode',
        'Expiredate',
        'Qty',
        'UnitPriceIn',
        'UnitPriceOut',
        'ProductImage',
        'isDeleted',
    ];

    protected $casts = [
        'Qty' => 'integer',
        'UnitPriceIn' => 'float',
        'UnitPriceOut' => 'float',
        'isDeleted' => 'integer',
    ];

    /**
     * Relationship: Product belongs to a Category
     */
    public function category()
    {
        return $this->belongsTo(Category::class, 'CategoryID', 'category_id');
    }
}
