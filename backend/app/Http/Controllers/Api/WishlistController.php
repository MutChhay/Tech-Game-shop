<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wishlist;
use Illuminate\Http\Request;

class WishlistController extends Controller
{
    // Get wishlist
    public function index(Request $request)
    {
        return Wishlist::with('product')
            ->where('user_id', $request->user()->id)
            ->get();
    }

    // Toggle wishlist (add/remove)
    public function toggle(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required|exists:products,id',
        ]);

        $wishlist = Wishlist::where('user_id', $request->user()->id)
            ->where('product_id', $data['product_id'])
            ->first();

        if ($wishlist) {
            $wishlist->delete();
            return response()->json(['liked' => false]);
        }

        Wishlist::create([
            'user_id' => $request->user()->id,
            'product_id' => $data['product_id'],
        ]);

        return response()->json(['liked' => true]);
    }
}