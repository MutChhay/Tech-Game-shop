<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    protected $fillable = [
        'name',
        'price',
        'stock',
        'description',
        'image',
        'category_id',
        // 🔥 NEW FIELDS
        'cpu',
        'ram', 
        'storage',
        'gpu',
        'display',
        'battery',
        'warranty',
    ];
    protected $casts = [
        'price' => 'decimal:2',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

}
 