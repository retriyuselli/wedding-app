<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingEventResource;
use App\Models\WeddingEvent;
use App\Services\DefaultWeddingChecklistProvisioner;
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

        // Avoid observer side-effects during create so we fully control provisioning.
        $event = WeddingEvent::withoutEvents(function () use ($request, $data) {
            return $request->user()->weddingEvents()->create($data);
        });

        // Lightweight checklist only (no enricher). Fast enough for iOS timeout and
        // does not depend on a queue worker being online.
        app(DefaultWeddingChecklistProvisioner::class)->provisionForEvent($event);

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
        $data = $request->validate([
            'jenis_acara' => ['required', 'string', 'in:'.implode(',', array_keys(WeddingEvent::$jenisOptions))],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'tgl_acara' => ['nullable', 'date'],
            'waktu_mulai' => ['nullable', 'regex:/^\d{2}:\d{2}(:\d{2})?$/'],
            'jam_selesai' => ['nullable', 'regex:/^\d{2}:\d{2}(:\d{2})?$/'],
            'lokasi_acara' => ['nullable', 'string', 'max:255'],
            'estimasi_tamu' => ['nullable', 'integer', 'min:0', 'max:100000'],
            'catatan' => ['nullable', 'string'],
        ]);

        return $this->normalizeTimeFields($data);
    }

    /**
     * @return array<string, mixed>
     */
    private function validatedForUpdate(Request $request): array
    {
        $data = $request->validate([
            'jenis_acara' => ['sometimes', 'required', 'string', 'in:'.implode(',', array_keys(WeddingEvent::$jenisOptions))],
            'sort_order' => ['sometimes', 'nullable', 'integer', 'min:0'],
            'tgl_acara' => ['sometimes', 'nullable', 'date'],
            'waktu_mulai' => ['sometimes', 'nullable', 'regex:/^\d{2}:\d{2}(:\d{2})?$/'],
            'jam_selesai' => ['sometimes', 'nullable', 'regex:/^\d{2}:\d{2}(:\d{2})?$/'],
            'lokasi_acara' => ['sometimes', 'nullable', 'string', 'max:255'],
            'estimasi_tamu' => ['sometimes', 'nullable', 'integer', 'min:0', 'max:100000'],
            'catatan' => ['sometimes', 'nullable', 'string'],
        ]);

        return $this->normalizeTimeFields($data);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function normalizeTimeFields(array $data): array
    {
        foreach (['waktu_mulai', 'jam_selesai'] as $field) {
            if (! empty($data[$field]) && is_string($data[$field])) {
                $data[$field] = substr($data[$field], 0, 5);
            }
        }

        return $data;
    }

    private function findOwned(Request $request, int $id): WeddingEvent
    {
        return WeddingEvent::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
