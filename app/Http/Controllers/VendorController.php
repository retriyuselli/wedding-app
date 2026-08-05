<?php

namespace App\Http\Controllers;

use App\Support\VendorCatalog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class VendorController extends Controller
{
    public function index(Request $request): View
    {
        $user = Auth::user();
        $weddingInfo = $user->weddingInfo;
        $events = $user->weddingEvents()->get();

        $category = $request->string('category')->toString() ?: 'all';
        $search = $request->string('q')->trim()->toString();
        $location = $request->string('location')->toString() ?: '';
        $sort = $request->string('sort')->toString() ?: 'terbaru';
        $view = $request->string('view')->toString() ?: 'grid';
        $perPage = (int) $request->integer('per_page', 12);
        $perPage = in_array($perPage, [12, 24, 48], true) ? $perPage : 12;

        $favoriteIds = $this->favoriteIds($request);
        $categoryTabs = VendorCatalog::categoryTabs();

        $query = VendorCatalog::queryWithCategory()
            ->where('is_active', true)
            ->withCount('activePackages')
            ->withMin('activePackages', 'price');

        $activeTab = collect($categoryTabs)->firstWhere('key', $category) ?? $categoryTabs[0];

        if ($activeTab['key'] !== 'all' && $activeTab['slugs'] !== []) {
            VendorCatalog::applyCategorySlugs($query, $activeTab['slugs']);
        }

        if ($search !== '') {
            $query->where(function ($vendorQuery) use ($search): void {
                $vendorQuery->where('name', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        if ($location !== '') {
            $query->where(function ($vendorQuery) use ($location): void {
                $vendorQuery->where('city', $location)->orWhere('province', $location);
            });
        }

        match ($sort) {
            'nama' => $query->orderBy('name'),
            'rating' => VendorCatalog::usingPaket()
                ? $query->orderByDesc('rating')->orderByDesc('likes')
                : $query->orderByDesc('is_featured')->orderBy('sort_order'),
            default => $query->orderByDesc('created_at'),
        };

        $vendors = $query->paginate($perPage)->withQueryString();

        $allVendors = VendorCatalog::queryWithCategory()->where('is_active', true)->get();
        $summary = $this->buildSummary($allVendors, $favoriteIds);
        $ratingDistribution = $this->buildRatingDistribution($allVendors);
        $averageRating = $allVendors->isNotEmpty()
            ? round($allVendors->avg(fn (Model $vendor): float => $vendor->displayRating()), 1)
            : 0.0;

        $favoriteVendors = $allVendors
            ->whereIn('id', $favoriteIds)
            ->take(4)
            ->values();

        $locations = VendorCatalog::query()
            ->where('is_active', true)
            ->select('city')
            ->whereNotNull('city')
            ->distinct()
            ->orderBy('city')
            ->pluck('city')
            ->filter()
            ->values();

        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->sortByDesc('tgl_acara')->first();

        $unreadNotifications = $user->customerNotifications()
            ->where('is_unread', true)
            ->count();

        return view('vendor.index', [
            'vendors' => $vendors,
            'categoryTabs' => $categoryTabs,
            'activeCategory' => $category,
            'search' => $search,
            'activeLocation' => $location,
            'activeSort' => $sort,
            'activeView' => $view,
            'perPage' => $perPage,
            'locations' => $locations,
            'summary' => $summary,
            'ratingDistribution' => $ratingDistribution,
            'averageRating' => $averageRating,
            'favoriteVendors' => $favoriteVendors,
            'favoriteIds' => $favoriteIds,
            'coupleLabel' => $this->coupleLabel($weddingInfo, $user->name),
            'weddingDateLabel' => $mainEvent?->tgl_acara?->translatedFormat('d M Y'),
            'unreadNotifications' => $unreadNotifications,
        ]);
    }

    public function toggleFavorite(Request $request, int $vendor): RedirectResponse
    {
        $vendorId = VendorCatalog::query()->where('is_active', true)->whereKey($vendor)->value('id');

        if ($vendorId === null) {
            abort(404);
        }

        $favorites = $this->favoriteIds($request);

        if (in_array($vendorId, $favorites, true)) {
            $favorites = array_values(array_filter($favorites, fn (int $id): bool => $id !== $vendorId));
        } else {
            $favorites[] = $vendorId;
        }

        $request->session()->put('favorite_vendors', $favorites);

        return back();
    }

    /**
     * @return list<int>
     */
    private function favoriteIds(Request $request): array
    {
        return array_values(array_map('intval', $request->session()->get('favorite_vendors', [])));
    }

    /**
     * @param  Collection<int, Model>  $vendors
     * @param  list<int>  $favoriteIds
     * @return array{total: int, active: int, favorites: int, akan_dihubungi: int}
     */
    private function buildSummary(Collection $vendors, array $favoriteIds): array
    {
        return [
            'total' => $vendors->count(),
            'active' => $vendors->where('is_active', true)->count(),
            'favorites' => count($favoriteIds),
            'akan_dihubungi' => $vendors
                ->whereNotIn('id', $favoriteIds)
                ->where(fn (Model $vendor): bool => (bool) $vendor->phone)
                ->take(5)
                ->count(),
        ];
    }

    /**
     * @param  Collection<int, Model>  $vendors
     * @return Collection<int, array{stars: int, percent: int}>
     */
    private function buildRatingDistribution(Collection $vendors): Collection
    {
        if ($vendors->isEmpty()) {
            return collect([
                ['stars' => 5, 'percent' => 0],
                ['stars' => 4, 'percent' => 0],
                ['stars' => 3, 'percent' => 0],
                ['stars' => 2, 'percent' => 0],
                ['stars' => 1, 'percent' => 0],
            ]);
        }

        $counts = [5 => 0, 4 => 0, 3 => 0, 2 => 0, 1 => 0];

        foreach ($vendors as $vendor) {
            $stars = (int) round($vendor->displayRating());
            $stars = max(1, min(5, $stars));
            $counts[$stars]++;
        }

        $total = max($vendors->count(), 1);

        return collect($counts)
            ->sortKeysDesc()
            ->map(fn (int $count, int $stars): array => [
                'stars' => $stars,
                'percent' => (int) round(($count / $total) * 100),
            ])
            ->values();
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
