<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use Illuminate\Http\Request;

class CartController extends Controller
{
    // Get user cart
    public function index(Request $request)
{
    return Cart::with('product')
        ->where('user_id', $request->user()->id)
        ->get()
        ->map(function ($cart) {
            return [
                'id' => $cart->id,
                'product_id' => $cart->product_id,
                'quantity' => $cart->quantity,

                'product' => [
                    'id' => $cart->product->id,
                    'name' => $cart->product->name,
                    'price' => $cart->product->price,
                    'stock' => $cart->product->stock,

                    'image_url' => $cart->product->image
                        ? asset('storage/' . $cart->product->image)
                        : null,
                ],
            ];
        });
}

    // Add to cart
    public function store(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'nullable|integer|min:1',
        ]);

        $product = \App\Models\Product::findOrFail($data['product_id']);
        $quantity = $data['quantity'] ?? 1;

        if ($quantity > $product->stock) {
            return response()->json([
                'message' => "Only {$product->stock} units are available.",
            ], 422);
        }

        $cart = Cart::updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'product_id' => $data['product_id'],
            ],
            [
                'quantity' => $quantity,
            ]
        );

        return response()->json($cart, 201);
    }

    // Remove from cart
    public function destroy(Request $request, $id)
    {
        $cart = Cart::where('user_id', $request->user()->id)
            ->where('id', $id)
            ->firstOrFail();

        $cart->delete();

        return response()->json(['message' => 'Item removed']);
    }

    // Update cart item quantity
public function update(Request $request, $id)
{
    $request->validate([
        'quantity' => 'required|integer|min:1',
    ]);

    $item = Cart::where('id', $id)
        ->where('user_id', $request->user()->id)
        ->with('product')
        ->firstOrFail();

    if ($request->quantity > $item->product->stock) {
        return response()->json([
            'message' => "Only {$item->product->stock} units are available.",
        ], 422);
    }

    $item->quantity = $request->quantity;
    $item->save();

    return response()->json([
        'message' => 'Quantity updated',
        'item' => $item
    ]);
}
}
