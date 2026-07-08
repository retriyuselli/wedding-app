<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingEventResource;
use App\Models\WeddingEvent;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

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
        $data = $this->validatedForUpdate($request);

        $event = $this->findOwned($request, $weddingEvent);
        $event->update($data);

        return new WeddingEventResource($event);
    }

    public function destroy(Request $request, int $weddingEvent): Response
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
            'jenis_acara' => ['required', 'string', 'in:'.implode(',', array_keys(WeddingEvent::$jenisOptions))],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'tgl_acara' => ['nullable', 'date'],
            'waktu_mulai' => ['nullable', 'date_format:H:i'],
            'jam_selesai' => ['nullable', 'date_format:H:i'],
            'lokasi_acara' => ['nullable', 'string', 'max:255'],
            'catatan' => ['nullable', 'string'],
        ]);
    }

    /**
     * @return array<string, mixed>
     */
    private function validatedForUpdate(Request $request): array
    {
        return $request->validate([
            'jenis_acara' => ['sometimes', 'required', 'string', 'in:'.implode(',', array_keys(WeddingEvent::$jenisOptions))],
            'sort_order' => ['sometimes', 'nullable', 'integer', 'min:0'],
            'tgl_acara' => ['sometimes', 'nullable', 'date'],
            'waktu_mulai' => ['sometimes', 'nullable', 'date_format:H:i'],
            'jam_selesai' => ['sometimes', 'nullable', 'date_format:H:i'],
            'lokasi_acara' => ['sometimes', 'nullable', 'string', 'max:255'],
            'catatan' => ['sometimes', 'nullable', 'string'],
        ]);
    }

    private function findOwned(Request $request, int $id): WeddingEvent
    {
        return WeddingEvent::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
