<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Address;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
class AddressController extends Controller
{
    // List all user addresses
    public function index() {
        return Auth::user()->addresses;
    }

    // Add address
    public function store(Request $request) {
        $validated = $request->validate([
            'name' => 'required|string|max:50',
            'street' => 'required|string|max:255',
            'city' => 'required|string|max:100',
            'state' => 'required|string|max:100',
            'postal_code' => 'required|string|max:20',
            'country' => 'required|string|max:100',
            'lat' => 'nullable|numeric',
            'lng' => 'nullable|numeric',
        ]);

        $address = Auth::user()->addresses()->create($validated);
        return response()->json($address, 201);
    }

    // Update address
    public function update(Request $request, Address $address) {
        if ($address->user_id !== Auth::id()) abort(403);

        $validated = $request->validate([
            'name' => 'string|max:50',
            'street' => 'string|max:255',
            'city' => 'string|max:100',
            'state' => 'string|max:100',
            'postal_code' => 'string|max:20',
            'country' => 'string|max:100',
            'lat' => 'nullable|numeric',
            'lng' => 'nullable|numeric',
        ]);

        $address->update($validated);
        return $address;
    }

    // Delete address
    public function destroy(Address $address) {
        if ($address->user_id !== Auth::id()) abort(403);
        $address->delete();
        return response()->json(['message' => 'Deleted']);
    }

    // Set default address
    public function setDefault(Address $address) {
        if ($address->user_id !== Auth::id()) abort(403);
        Auth::user()->addresses()->update(['is_default' => false]);
        $address->update(['is_default' => true]);
        return $address;
    }
}