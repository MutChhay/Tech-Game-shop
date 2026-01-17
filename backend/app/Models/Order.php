<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'user_id',
        'total_price',
        'status',
        'processed_at',
        'shipped_at',
        'delivered_at',
        'cancelled_at',
    ];

    protected $casts = [
        'processed_at' => 'datetime',
        'shipped_at' => 'datetime',
        'delivered_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    // ✅ STATUS FLOW RULES
    public function canTransitionTo(string $newStatus, bool $isAdmin = false): bool
    {
        $flow = [
            'pending' => ['processing', 'cancelled'],
            'processing' => $isAdmin ? ['shipped', 'cancelled'] : ['shipped'],
            'shipped' => ['delivered'],
        ];

        return isset($flow[$this->status]) &&
               in_array($newStatus, $flow[$this->status]);
    }

    // ================= RELATIONS =================

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}