<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\VendorPackageResource;
use App\Http\Resources\V1\VendorResource;
use App\Models\Vendor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class VendorController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Vendor::query()
            ->with('category')
            ->where('is_active', true)
            ->withCount('activePackages')
            ->withMin('activePackages', 'price');

        if ($request->filled('category')) {
            $query->whereHas('category', fn ($q) => $q->where('slug', $request->string('category')));
        }

        if ($request->filled('province')) {
            $query->where('province', $request->string('province'));
        }

        if ($request->filled('city')) {
            $query->where('city', $request->string('city'));
        }

        if ($request->boolean('featured')) {
            $query->where('is_featured', true);
        }

        if ($request->boolean('verified')) {
            $query->where('is_verified', true);
        }

        if ($request->filled('search')) {
            $search = $request->string('search');
            $query->where(function ($q) use ($search): void {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $vendors = $query
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return VendorResource::collection($vendors);
    }

    public function show(string $vendor): VendorResource|JsonResponse
    {
        $record = Vendor::query()
            ->with(['category', 'activePackages'])
            ->where('is_active', true)
            ->where('slug', $vendor)
            ->first();

        if ($record === null) {
            return response()->json(['message' => 'Vendor tidak ditemukan.'], 404);
        }

        return new VendorResource($record);
    }

    public function packages(string $vendor): AnonymousResourceCollection|JsonResponse
    {
        $record = Vendor::query()
            ->where('is_active', true)
            ->where('slug', $vendor)
            ->first();

        if ($record === null) {
            return response()->json(['message' => 'Vendor tidak ditemukan.'], 404);
        }

        $packages = $record->activePackages()->orderBy('sort_order')->get();

        return VendorPackageResource::collection($packages);
    }
}
