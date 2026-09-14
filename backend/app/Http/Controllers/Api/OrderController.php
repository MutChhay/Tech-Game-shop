<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use App\Services\FirebaseService;

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
            $products = [];
            foreach ($cartItems as $item) {
                $product = Product::whereKey($item->product_id)
                    ->lockForUpdate()
                    ->first();

                if (!$product || $product->stock < $item->quantity) {
                    DB::rollBack();

                    return response()->json([
                        'message' => "Insufficient stock for {$item->product?->name}. Available: " . ($product?->stock ?? 0),
                    ], 422);
                }

                $products[$item->product_id] = $product;
            }

            $total = $cartItems->sum(function ($item) use ($products) {
                return $products[$item->product_id]->price * $item->quantity;
            });

            $order = Order::create([
                'user_id' => $user->id,
                'total_price' => $total,
                'status' => 'pending',
            ]);

            foreach ($cartItems as $item) {
                $product = $products[$item->product_id];

                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item->product_id,
                    'quantity' => $item->quantity,
                    'price' => $product->price,
                ]);

                $product->decrement('stock', $item->quantity);
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
            'status' => 'required|in:processing,shipped,delivered,cancellation_requested,cancelled',
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

        $previousStatus = $order->status;
        $order->update($data);

        if ($request->status === 'cancelled' && $previousStatus === 'cancellation_requested') {
            $this->notifyUser($order->fresh()->load('user'), 'Cancellation approved', 'Your order cancellation request has been approved.');
        }

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

        if (!$order->canTransitionTo('cancellation_requested')) {
            return response()->json([
                'message' => 'This order cannot be cancelled at its current status',
            ], 422);
        }

        $order->update([
            'status' => 'cancellation_requested',
        ]);

        $this->notifyAdmins('Cancellation requested', "User requested cancellation for order #{$order->id}.");

        return response()->json([
            'message' => 'Cancellation request sent to the admin',
            'order' => $order,
        ]);
    }

    private function notifyAdmins(string $title, string $body): void
    {
        try {
            $firebase = app(FirebaseService::class);

            \App\Models\User::where('role', 'admin')
                ->whereNotNull('fcm_token')
                ->pluck('fcm_token')
                ->each(fn ($token) => $firebase->sendNotification($token, $title, $body));
        } catch (\Throwable $exception) {
            report($exception);
        }
    }

    private function notifyUser(Order $order, string $title, string $body): void
    {
        if (!$order->user?->fcm_token) {
            return;
        }

        try {
            app(FirebaseService::class)->sendNotification($order->user->fcm_token, $title, $body);
        } catch (\Throwable $exception) {
            report($exception);
        }
    }
}
