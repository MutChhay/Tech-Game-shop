<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Cart;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    // ============================
    // 🛒 USER: PLACE ORDER
    // ============================
    public function store(Request $request)
    {
        $user = $request->user();

        $cartItems = Cart::with('product')
            ->where('user_id', $user->id)
            ->get();

        if ($cartItems->isEmpty()) {
            return response()->json(['message' => 'Cart is empty'], 400);
        }

        DB::beginTransaction();

        try {
            $total = $cartItems->sum(function ($item) {
                return $item->product->price * $item->quantity;
            });

            $order = Order::create([
                'user_id' => $user->id,
                'total_price' => $total,
                'status' => 'pending',
            ]);

            foreach ($cartItems as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item->product_id,
                    'quantity' => $item->quantity,
                    'price' => $item->product->price,
                ]);
            }

            Cart::where('user_id', $user->id)->delete();

            DB::commit();

            return response()->json(
                Order::with('items.product')->find($order->id),
                201
            );
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'message' => 'Order failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // ============================
    // 📜 USER: MY ORDERS
    // ============================
    public function index(Request $request)
    {
        return Order::with('items.product')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();
    }

    // ============================
    // 🔍 USER: VIEW ORDER
    // ============================
    public function show(Request $request, $id)
    {
        return Order::with('items.product')
            ->where('user_id', $request->user()->id)
            ->where('id', $id)
            ->firstOrFail();
    }

    // ============================
    // 🛠 ADMIN: VIEW ALL ORDERS
    // ============================
        public function adminIndex()
    {
        return Order::with([
            'user:id,name,email',
            'items.product:id,name,image,price'
        ])
        ->latest()
        ->get();
    }


    // ============================
    // 🔄 ADMIN: UPDATE STATUS
    // ============================
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:processing,shipped,delivered,cancelled',
        ]);

        $order = Order::findOrFail($id);
        $user = Auth::user();

        if (!$order->canTransitionTo($request->status, $user->role === 'admin')) {
            return response()->json(['message' => 'Invalid status transition'], 422);
        }

        $data = ['status' => $request->status];

        if ($request->status === 'processing') {
            $data['processed_at'] = now();
        } elseif ($request->status === 'shipped') {
            $data['shipped_at'] = now();
        } elseif ($request->status === 'delivered') {
            $data['delivered_at'] = now();
        } elseif ($request->status === 'cancelled') {
            $data['cancelled_at'] = now();
        }

        $order->update($data);

        return response()->json([
            'message' => 'Status updated',
            'order' => $order,
        ]);
    }

    // ============================
    // ❌ USER: CANCEL ORDER
    // ============================
    public function cancel($id)
    {
        $order = Order::findOrFail($id);
        $user = Auth::user();

        if ($order->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if (!$order->canTransitionTo('cancelled')) {
            return response()->json([
                'message' => 'Order cannot be cancelled',
            ], 422);
        }

        $order->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
        ]);

        return response()->json([
            'message' => 'Order cancelled',
            'order' => $order,
        ]);
    }
}