<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index()
    {
        return Product::with('category')
            ->latest()
            ->get()
            ->map(function ($product) {
                return [
                    'id' => $product->id,
                    'name' => $product->name,
                    'price' => $product->price,
                    'stock' => $product->stock,
                    'description' => $product->description,
                    'image' => $product->image,
                    'category_id' => $product->category_id,
                    'category_name' => $product->category?->name,
                    'image_url' => $product->image
                        ? asset('storage/' . $product->image)
                        : null,
                    // 🔥 FIXED: Real data instead of validation rules
                    'cpu' => $product->cpu,
                    'ram' => $product->ram,
                    'storage' => $product->storage,
                    'gpu' => $product->gpu,
                    'display' => $product->display,
                    'battery' => $product->battery,
                    'warranty' => $product->warranty,
                ];
            });
    }

    public function store(Request $request)
    {
    $categoryId = $request->category_id;

    $rules = [
        'name' => 'required|string|max:255',
        'price' => 'required|numeric|min:0',
        'stock' => 'required|integer|min:0',
        'description' => 'nullable|string',
        'category_id' => 'required|exists:categories,id',
        'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
    ];

    // Categories that REQUIRE specs
    $specCategories = [1, 2]; // Laptop, PC

    if (in_array($categoryId, $specCategories)) {
        $rules = array_merge($rules, [
            'cpu' => 'required|string|max:100',
            'ram' => 'required|string|max:100',
            'storage' => 'required|string|max:100',
            'display' => 'required|string|max:100',
            'gpu' => 'nullable|string|max:100',
            'battery' => 'nullable|string|max:100',
            'warranty' => 'nullable|string|max:100',
        ]);
    } else {
        $rules = array_merge($rules, [
            'cpu' => 'nullable',
            'ram' => 'nullable',
            'storage' => 'nullable',
            'gpu' => 'nullable',
            'display' => 'nullable',
            'battery' => 'nullable',
            'warranty' => 'nullable',
        ]);
    }

    $data = $request->validate($rules);

    if ($request->hasFile('image')) {
        $data['image'] = $request->file('image')->store('products', 'public');
    }

    $product = Product::create($data);

    return response()->json([
        'success' => true,
        'message' => 'Product created successfully',
        'data' => $product->load('category'),
    ], 201);
}


        public function update(Request $request, $id)
        {
            $product = Product::findOrFail($id);
            $categoryId = $request->category_id ?? $product->category_id;

            $rules = [
                'name' => 'sometimes|required|string|max:255',
                'price' => 'sometimes|required|numeric|min:0',
                'stock' => 'sometimes|required|integer|min:0',
                'description' => 'nullable|string',
                'category_id' => 'sometimes|required|exists:categories,id',
                'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            ];

            // $specCategories = [1, 2]; // Laptop, PC

    //         if (in_array($categoryId, $specCategories)) {
    //             $rules = array_merge($rules, [
    //         'cpu' => 'required|string|max:100',
    //         'ram' => 'required|string|max:100',
    //         'storage' => 'required|string|max:100',
    //         'display' => 'required|string|max:100',
    //         'gpu' => 'nullable|string|max:100',
    //         'battery' => 'nullable|string|max:100',
    //         'warranty' => 'nullable|string|max:100',
    //     ]);
    // } else {
    //     $rules = array_merge($rules, [
    //         'cpu' => 'nullable',
    //         'ram' => 'nullable',
    //         'storage' => 'nullable',
    //         'gpu' => 'nullable',
    //         'display' => 'nullable',
    //         'battery' => 'nullable',
    //         'warranty' => 'nullable',
    //     ]);
    // }

    $data = $request->validate($rules);

    if ($request->hasFile('image')) {
        if ($product->image) {
            Storage::disk('public')->delete($product->image);
        }
        $data['image'] = $request->file('image')->store('products', 'public');
    }

    $product->update($data);

    return response()->json([
        'success' => true,
        'message' => 'Product updated successfully',
        'data' => $product->load('category'),
    ]);
}


    public function destroy($id)
    {
        $product = Product::findOrFail($id);

        if ($product->image) {
            Storage::disk('public')->delete($product->image);
        }

        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product deleted successfully'
        ]);
    }

    public function restore($id)
    {
        $product = Product::withTrashed()->findOrFail($id);
        $product->restore();

        return response()->json([
            'success' => true,
            'message' => 'Product restored successfully'
        ]);
    }
}