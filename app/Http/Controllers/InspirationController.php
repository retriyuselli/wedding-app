<?php

namespace App\Http\Controllers;

use App\Models\Inspiration;
use App\Support\DummyImage;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class InspirationController extends Controller
{
    /**
     * @var list<array{key: string, label: string, categories: list<string>}>
     */
    private array $categoryTabs = [
        ['key' => 'all', 'label' => 'Semua', 'categories' => []],
        ['key' => 'dekorasi', 'label' => 'Dekorasi', 'categories' => ['dekorasi']],
        ['key' => 'warna', 'label' => 'Warna', 'categories' => ['dekorasi', 'makeup']],
        ['key' => 'venue', 'label' => 'Venue', 'categories' => ['venue']],
        ['key' => 'busana', 'label' => 'Busana', 'categories' => ['gaun']],
        ['key' => 'bouquet', 'label' => 'Bouquet', 'categories' => ['dekorasi']],
        ['key' => 'kue', 'label' => 'Kue', 'categories' => ['katering']],
        ['key' => 'undangan', 'label' => 'Undangan', 'categories' => ['dekorasi', 'katering']],
        ['key' => 'lainnya', 'label' => 'Lainnya', 'categories' => ['makeup']],
    ];

    /**
     * @var list<array{key: string, label: string, bg: string, text: string}>
     */
    private array $moods = [
        ['key' => 'romantis', 'label' => 'Romantis', 'bg' => 'bg-rose-50', 'text' => 'text-rose-600'],
        ['key' => 'elegan', 'label' => 'Elegan', 'bg' => 'bg-amber-50', 'text' => 'text-amber-600'],
        ['key' => 'modern', 'label' => 'Modern', 'bg' => 'bg-sky-50', 'text' => 'text-sky-600'],
        ['key' => 'natural', 'label' => 'Natural', 'bg' => 'bg-sage-50', 'text' => 'text-sage-600'],
        ['key' => 'mewah', 'label' => 'Mewah', 'bg' => 'bg-yellow-50', 'text' => 'text-yellow-700'],
        ['key' => 'simple', 'label' => 'Simple', 'bg' => 'bg-violet-50', 'text' => 'text-violet-600'],
    ];

    /**
     * @var list<array{key: string, label: string, color: string}>
     */
    private array $themeColors = [
        ['key' => 'sage', 'label' => 'Sage', 'color' => '#385745'],
        ['key' => 'gold', 'label' => 'Gold', 'color' => '#c29747'],
        ['key' => 'beige', 'label' => 'Beige', 'color' => '#d4b06a'],
        ['key' => 'blue', 'label' => 'Blue', 'color' => '#60a5fa'],
        ['key' => 'lavender', 'label' => 'Lavender', 'color' => '#c4b5fd'],
        ['key' => 'white', 'label' => 'White', 'color' => '#f9fafb'],
    ];

    public function index(Request $request): View
    {
        $user = Auth::user();
        $weddingInfo = $user->weddingInfo;
        $events = $user->weddingEvents()->get();

        $category = $request->string('category')->toString() ?: 'all';
        $theme = $request->string('theme')->toString() ?: '';
        $color = $request->string('color')->toString() ?: '';
        $search = $request->string('q')->trim()->toString();
        $sort = $request->string('sort')->toString() ?: 'terbaru';
        $view = $request->string('view')->toString() ?: 'grid';
        $perPage = (int) $request->integer('per_page', 12);
        $perPage = in_array($perPage, [8, 12, 24], true) ? $perPage : 12;

        $savedIds = $user->savedInspirations()->pluck('inspirations.id')->all();

        $query = Inspiration::query()
            ->where('is_active', true)
            ->withExists([
                'savedByUsers as is_saved' => fn ($savedQuery) => $savedQuery->where('users.id', $user->id),
            ]);

        $activeTab = collect($this->categoryTabs)->firstWhere('key', $category) ?? $this->categoryTabs[0];

        if ($activeTab['key'] !== 'all' && $activeTab['categories'] !== []) {
            $query->whereIn('category', $activeTab['categories']);
        }

        if ($search !== '') {
            $query->where(function ($inspirationQuery) use ($search): void {
                $inspirationQuery->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        if ($theme !== '') {
            $query->where(function ($inspirationQuery) use ($theme): void {
                $inspirationQuery->where('title', 'like', "%{$theme}%")
                    ->orWhere('description', 'like', "%{$theme}%");
            });
        }

        match ($sort) {
            'populer' => $query->orderByDesc('likes_count'),
            'nama' => $query->orderBy('title'),
            default => $query->orderByDesc('created_at'),
        };

        $inspirations = $query
            ->orderBy('sort_order')
            ->paginate($perPage)
            ->withQueryString();

        $allInspirations = Inspiration::query()->where('is_active', true)->get();

        $popularTrendsQuery = Inspiration::query()->where('is_active', true);

        if ($activeTab['key'] !== 'all' && $activeTab['categories'] !== []) {
            $popularTrendsQuery->whereIn('category', $activeTab['categories']);
        }

        $popularTrends = $popularTrendsQuery
            ->orderByDesc('likes_count')
            ->limit(4)
            ->get();

        $savedInspirations = $user->savedInspirations()
            ->where('is_active', true)
            ->orderByPivot('created_at', 'desc')
            ->get();

        $collections = $this->buildCollections($savedInspirations);

        $moodCounts = $this->buildMoodCounts($allInspirations);

        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->sortByDesc('tgl_acara')->first();

        $unreadNotifications = $user->customerNotifications()
            ->where('is_unread', true)
            ->count();

        $themeOptions = [
            '' => 'Semua Tema',
            'classic' => 'Classic',
            'garden' => 'Garden',
            'rustic' => 'Rustic',
            'modern' => 'Modern',
            'pastel' => 'Pastel',
        ];

        return view('inspiration.index', [
            'inspirations' => $inspirations,
            'categoryTabs' => $this->categoryTabs,
            'activeCategory' => $category,
            'themeOptions' => $themeOptions,
            'activeTheme' => $theme,
            'themeColors' => $this->themeColors,
            'activeColor' => $color,
            'search' => $search,
            'activeSort' => $sort,
            'activeView' => $view,
            'perPage' => $perPage,
            'popularTrends' => $popularTrends,
            'moods' => $this->moods,
            'moodCounts' => $moodCounts,
            'collections' => $collections,
            'savedIds' => $savedIds,
            'coupleLabel' => $this->coupleLabel($weddingInfo, $user->name),
            'weddingDateLabel' => $mainEvent?->tgl_acara?->translatedFormat('d M Y'),
            'unreadNotifications' => $unreadNotifications,
        ]);
    }

    public function toggleSave(Request $request, Inspiration $inspiration): RedirectResponse
    {
        abort_unless($inspiration->is_active, 404);

        $user = $request->user();

        if ($user->savedInspirations()->whereKey($inspiration->id)->exists()) {
            $user->savedInspirations()->detach($inspiration->id);
        } else {
            $user->savedInspirations()->attach($inspiration->id);
        }

        return back();
    }

    /**
     * @param  Collection<int, Inspiration>  $savedInspirations
     * @return Collection<int, array{label: string, count: int, cover: string}>
     */
    private function buildCollections(Collection $savedInspirations): Collection
    {
        if ($savedInspirations->isEmpty()) {
            return collect([
                ['label' => 'Ide Dekorasi Akad', 'count' => 0, 'cover' => DummyImage::url('inspiration', 0)],
                ['label' => 'Inspirasi Resepsi', 'count' => 0, 'cover' => DummyImage::url('inspiration', 1)],
            ]);
        }

        return $savedInspirations
            ->groupBy('category')
            ->map(function (Collection $items, string $category): array {
                $first = $items->first();

                return [
                    'label' => $first?->categoryLabel() ?? ucfirst($category),
                    'count' => $items->count(),
                    'cover' => $first?->coverImageUrl() ?? DummyImage::url('inspiration', 0),
                ];
            })
            ->values()
            ->take(4);
    }

    /**
     * @param  Collection<int, Inspiration>  $inspirations
     * @return array<string, int>
     */
    private function buildMoodCounts(Collection $inspirations): array
    {
        $total = max($inspirations->count(), 1);
        $base = (int) floor($total / count($this->moods));

        $counts = [];

        foreach ($this->moods as $index => $mood) {
            $counts[$mood['key']] = $base + ($index % 3);
        }

        return $counts;
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
