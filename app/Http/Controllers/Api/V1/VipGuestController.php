<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\VipGuestResource;
use App\Models\VipGuest;
use App\Services\VipGuestExcelService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class VipGuestController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $guests = $request->user()->vipGuests()->orderBy('no')->orderBy('name')->get();

        return VipGuestResource::collection($guests);
    }

    public function store(Request $request): VipGuestResource
    {
        $data = $this->validated($request);
        $data['rsvp_status'] ??= 'menunggu';
        $data['kategori'] ??= 'vip';
        $data['no'] ??= ((int) $request->user()->vipGuests()->max('no')) + 1;

        $guest = $request->user()->vipGuests()->create($data);

        return new VipGuestResource($guest);
    }

    public function show(Request $request, int $vipGuest): VipGuestResource
    {
        return new VipGuestResource($this->findOwned($request, $vipGuest));
    }

    public function update(Request $request, int $vipGuest): VipGuestResource
    {
        $data = $this->validated($request);

        $record = $this->findOwned($request, $vipGuest);
        $record->update($data);

        return new VipGuestResource($record);
    }

    public function destroy(Request $request, int $vipGuest): Response
    {
        $this->findOwned($request, $vipGuest)->delete();

        return response()->noContent();
    }

    public function destroyAll(Request $request): JsonResponse
    {
        $deleted = $request->user()->vipGuests()->delete();

        return response()->json([
            'message' => 'Semua data tamu VIP berhasil dihapus.',
            'data' => [
                'deleted' => $deleted,
            ],
        ]);
    }

    public function updateRsvp(Request $request, int $vipGuest): VipGuestResource
    {
        $data = $request->validate([
            'rsvp_status' => ['required', 'string', 'in:'.implode(',', array_keys(VipGuest::$rsvpOptions))],
        ]);

        $record = $this->findOwned($request, $vipGuest);
        $record->update([
            'rsvp_status' => $data['rsvp_status'],
            'rsvp_updated_by_name' => $request->user()->name,
            'rsvp_updated_at' => now(),
        ]);

        return new VipGuestResource($record);
    }

    public function downloadTemplate(): BinaryFileResponse
    {
        return app(VipGuestExcelService::class)->downloadTemplate();
    }

    public function importExcel(Request $request): JsonResponse
    {
        $request->validate([
            'spreadsheet' => [
                'required',
                'file',
                'mimes:xlsx',
                'max:5120',
            ],
        ]);

        $storedPath = $request->file('spreadsheet')->store('imports/vip-guests', 'local');
        $absolutePath = Storage::disk('local')->path($storedPath);

        try {
            $result = app(VipGuestExcelService::class)->import($request->user(), $absolutePath);
        } finally {
            Storage::disk('local')->delete($storedPath);
        }

        return response()->json([
            'message' => 'Import tamu VIP selesai.',
            'data' => $result,
        ]);
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'no' => ['nullable', 'integer', 'min:0'],
            'name' => ['required', 'string', 'max:255'],
            'jabatan' => ['nullable', 'string', 'max:255'],
            'instansi' => ['nullable', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'kategori' => ['nullable', 'string', 'in:'.implode(',', array_keys(VipGuest::$kategoriOptions))],
            'rsvp_status' => ['nullable', 'string', 'in:'.implode(',', array_keys(VipGuest::$rsvpOptions))],
            'catatan' => ['nullable', 'string'],
        ]);
    }

    private function findOwned(Request $request, int $id): VipGuest
    {
        return VipGuest::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
