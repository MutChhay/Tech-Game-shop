<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    protected $appends = ['image_url'];

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

    public function images()
    {
        return $this->hasMany(ProductImage::class)->orderBy('sort_order');
    }

    public function getImageUrlAttribute(): ?string
    {
        $path = $this->images->first()?->image_path ?: $this->image;

        return $path ? asset('storage/' . $path) : null;
    }

}
