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
        return Product::with(['category', 'images'])
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
                    'image_url' => $this->primaryImageUrl($product),
                    'images' => $this->imageUrls($product),
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


    // show product details
    public function show($id)
{
    $product = Product::with(['category', 'images'])->find($id);

    if (!$product) {
        return response()->json([
            'message' => 'Product not found'
        ], 404);
    }

    return response()->json([
        'id' => $product->id,
        'name' => $product->name,
        'price' => $product->price,
        'stock' => $product->stock,
        'description' => $product->description,
        'image_url' => $this->primaryImageUrl($product),
        'images' => $this->imageUrls($product),
        'category_name' => $product->category?->name,
        'cpu' => $product->cpu,
        'ram' => $product->ram,
        'storage' => $product->storage,
        'gpu' => $product->gpu,
        'display' => $product->display,
        'battery' => $product->battery,
        'warranty' => $product->warranty,
    ]);
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
        'images' => 'nullable|array|max:7',
        'images.*' => 'image|mimes:jpg,jpeg,png|max:2048',
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

    $product = Product::create($data);

    $this->storeProductImages($request, $product);
    $product->load('images');

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
                'images' => 'nullable|array|max:7',
                'images.*' => 'image|mimes:jpg,jpeg,png|max:2048',
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

    if ($request->hasFile('images')) {
        $files = $request->file('images', []);
        $files = is_array($files) ? $files : [$files];

        if (count($files) > 7) {
            return response()->json(['message' => 'A product can have a maximum of 7 images.'], 422);
        }

        foreach ($product->images as $image) {
            Storage::disk('public')->delete($image->image_path);
        }
        $product->images()->delete();
        if ($product->image) {
            Storage::disk('public')->delete($product->image);
        }
        $product->update(['image' => null]);

        foreach ($files as $file) {
            $path = $file->store('products', 'public');
            $product->images()->create([
                'image_path' => $path,
                'sort_order' => $product->images()->count(),
            ]);

            if (!$product->image) {
                $product->update(['image' => $path]);
            }
        }
    }

    return response()->json([
        'success' => true,
        'message' => 'Product updated successfully',
        'data' => $product->load(['category', 'images']),
    ]);
}


    public function destroy($id)
    {
        $product = Product::findOrFail($id);

        if ($product->image) {
            Storage::disk('public')->delete($product->image);
        }

        foreach ($product->images as $image) {
            Storage::disk('public')->delete($image->image_path);
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

    private function storeProductImages(Request $request, Product $product): void
    {
        $files = $request->file('images', []);

        if ($request->hasFile('image')) {
            array_unshift($files, $request->file('image'));
        }

        $nextOrder = (int) $product->images()->max('sort_order') + 1;

        foreach ($files as $file) {
            $path = $file->store('products', 'public');
            $product->images()->create([
                'image_path' => $path,
                'sort_order' => $nextOrder++,
            ]);

            if (!$product->image) {
                $product->update(['image' => $path]);
            }
        }
    }

    private function syncLegacyImage(Product $product): void
    {
        if ($product->image && !$product->images()->exists()) {
            $product->images()->create([
                'image_path' => $product->image,
                'sort_order' => 0,
            ]);
        }
    }

    private function primaryImageUrl(Product $product): ?string
    {
        $image = $product->images->first()?->image_path ?: $product->image;
        return $image ? asset('storage/' . $image) : null;
    }

    private function imageUrls(Product $product): array
    {
        $images = $product->images->pluck('image_path')->map(fn ($path) => asset('storage/' . $path))->values()->all();

        if (!$images && $product->image) {
            $images[] = asset('storage/' . $product->image);
        }

        return $images;
    }
}
