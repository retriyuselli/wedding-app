<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\InspirationResource;
use App\Models\Inspiration;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class InspirationController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Inspiration::query()
            ->where('is_active', true)
            ->withExists([
                'savedByUsers as is_saved' => fn ($query) => $query->where('users.id', $request->user()->id),
                'likedByUsers as is_liked' => fn ($query) => $query->where('users.id', $request->user()->id),
            ])
            ->orderBy('sort_order')
            ->orderByDesc('likes_count');

        if ($request->filled('category') && $request->string('category')->toString() !== 'all') {
            $query->where('category', $request->string('category')->toString());
        }

        if ($request->filled('minimum_likes')) {
            $query->where('likes_count', '>=', $request->integer('minimum_likes'));
        }

        if ($request->boolean('saved_only')) {
            $query->whereHas('savedByUsers', fn ($query) => $query->where('users.id', $request->user()->id));
        }

        if ($request->filled('search')) {
            $search = $request->string('search')->toString();
            $query->where('title', 'like', '%'.$search.'%');
        }

        return InspirationResource::collection($query->get());
    }

    public function save(Request $request, Inspiration $inspiration): InspirationResource
    {
        abort_unless($inspiration->is_active, 404);

        $request->user()->savedInspirations()->syncWithoutDetaching([$inspiration->id]);

        return $this->inspirationResourceForUser($inspiration, $request->user()->id);
    }

    public function unsave(Request $request, Inspiration $inspiration): Response
    {
        $request->user()->savedInspirations()->detach($inspiration->id);

        return response()->noContent();
    }

    public function like(Request $request, Inspiration $inspiration): InspirationResource
    {
        abort_unless($inspiration->is_active, 404);

        $attached = $request->user()->likedInspirations()->syncWithoutDetaching([$inspiration->id]);

        if (! empty($attached['attached'])) {
            $inspiration->increment('likes_count');
            $inspiration->refresh();
        }

        return $this->inspirationResourceForUser($inspiration, $request->user()->id);
    }

    public function unlike(Request $request, Inspiration $inspiration): InspirationResource
    {
        $detached = $request->user()->likedInspirations()->detach($inspiration->id);

        if ($detached > 0) {
            $inspiration->decrement('likes_count');
            $inspiration->refresh();
        }

        return $this->inspirationResourceForUser($inspiration, $request->user()->id);
    }

    private function inspirationResourceForUser(Inspiration $inspiration, int $userId): InspirationResource
    {
        $inspiration->loadExists([
            'savedByUsers as is_saved' => fn ($query) => $query->where('users.id', $userId),
            'likedByUsers as is_liked' => fn ($query) => $query->where('users.id', $userId),
        ]);

        return new InspirationResource($inspiration);
    }
}
