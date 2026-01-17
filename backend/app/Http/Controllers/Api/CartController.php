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
            ->get();
    }

    // Add to cart
    public function store(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'nullable|integer|min:1',
        ]);

        $cart = Cart::updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'product_id' => $data['product_id'],
            ],
            [
                'quantity' => $data['quantity'] ?? 1,
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
        ->where('user_id', auth()->user()->id)
        ->firstOrFail();

    $item->quantity = $request->quantity;
    $item->save();

    return response()->json([
        'message' => 'Quantity updated',
        'item' => $item
    ]);
}
}