<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\VendorPackageResource;
use App\Http\Resources\V1\VendorResource;
use App\Support\VendorCatalog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class VendorController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = VendorCatalog::queryWithCategory()
            ->where('is_active', true)
            ->withCount('activePackages')
            ->withMin('activePackages', 'price');

        if ($request->filled('category')) {
            VendorCatalog::applyCategorySlugs($query, [$request->string('category')->toString()]);
        }

        if ($request->filled('province')) {
            $query->where('province', $request->string('province'));
        }

        if ($request->filled('city')) {
            $query->where('city', $request->string('city'));
        }

        if ($request->boolean('featured')) {
            if (VendorCatalog::usingPaket()) {
                $query->where(function ($featuredQuery): void {
                    $featuredQuery->whereNotNull('badge')
                        ->where('badge', '!=', '[]')
                        ->orWhere(function ($promoQuery): void {
                            $promoQuery->whereNotNull('promo')->where('promo', '!=', '[]');
                        });
                });
            } else {
                $query->where('is_featured', true);
            }
        }

        if ($request->boolean('verified')) {
            if (VendorCatalog::usingPaket()) {
                $query->where('is_profile_complete', true);
            } else {
                $query->where('is_verified', true);
            }
        }

        if ($request->filled('search')) {
            $search = $request->string('search');
            $query->where(function ($q) use ($search): void {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        if (VendorCatalog::usingPaket()) {
            $vendors = $query
                ->orderByDesc('likes')
                ->orderBy('name')
                ->get();
        } else {
            $vendors = $query
                ->orderBy('sort_order')
                ->orderBy('name')
                ->get();
        }

        return VendorResource::collection($vendors);
    }

    public function show(string $vendor): VendorResource|JsonResponse
    {
        $record = VendorCatalog::query()
            ->with([VendorCatalog::categoryRelation(), 'activePackages'])
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
        $record = VendorCatalog::query()
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
