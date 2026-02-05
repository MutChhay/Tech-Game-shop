<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    protected $fillable = [
        'user_id', 'name', 'street', 'city', 'state', 
        'postal_code', 'country', 'lat', 'lng', 'is_default'
    ];

    protected $casts = [
        'lat' => 'decimal:8',
        'lng' => 'decimal:8',
        'is_default' => 'boolean',
    ];

    public function user() {
        return $this->belongsTo(User::class);
    }
}