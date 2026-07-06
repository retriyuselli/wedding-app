<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingEventResource;
use App\Models\WeddingEvent;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WeddingEventController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $events = $request->user()->weddingEvents()->get();

        return WeddingEventResource::collection($events);
    }

    public function store(Request $request): WeddingEventResource
    {
        $data = $this->validated($request);

        $event = $request->user()->weddingEvents()->create($data);

        return new WeddingEventResource($event);
    }

    public function show(Request $request, int $weddingEvent): WeddingEventResource
    {
        return new WeddingEventResource($this->findOwned($request, $weddingEvent));
    }

    public function update(Request $request, int $weddingEvent): WeddingEventResource
    {
        $data = $this->validated($request);

        $event = $this->findOwned($request, $weddingEvent);
        $event->update($data);

        return new WeddingEventResource($event);
    }

    public function destroy(Request $request, int $weddingEvent): \Illuminate\Http\Response
    {
        $this->findOwned($request, $weddingEvent)->delete();

        return response()->noContent();
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'jenis_acara'  => ['required', 'string', 'in:'.implode(',', array_keys(WeddingEvent::$jenisOptions))],
            'tgl_acara'    => ['nullable', 'date'],
            'lokasi_acara' => ['nullable', 'string', 'max:255'],
            'catatan'      => ['nullable', 'string'],
        ]);
    }

    private function findOwned(Request $request, int $id): WeddingEvent
    {
        return WeddingEvent::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
