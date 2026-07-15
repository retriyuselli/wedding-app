<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\GuestResource;
use App\Models\Guest;
use App\Services\GuestExcelService;
use App\Support\ExcelSupport;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class GuestController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $guests = $request->user()->guests()->orderBy('no')->orderBy('name')->get();

        return GuestResource::collection($guests);
    }

    public function store(Request $request): GuestResource
    {
        $data = $this->validated($request);
        $data['rsvp_status'] ??= 'menunggu';
        $data['no'] ??= ((int) $request->user()->guests()->max('no')) + 1;

        $guest = $request->user()->guests()->create($data);

        return new GuestResource($guest);
    }

    public function show(Request $request, int $guest): GuestResource
    {
        return new GuestResource($this->findOwned($request, $guest));
    }

    public function update(Request $request, int $guest): GuestResource
    {
        $data = $this->validated($request);

        $record = $this->findOwned($request, $guest);
        $record->update($data);

        return new GuestResource($record);
    }

    public function destroy(Request $request, int $guest): Response
    {
        $this->findOwned($request, $guest)->delete();

        return response()->noContent();
    }

    public function destroyAll(Request $request): JsonResponse
    {
        $deleted = $request->user()->guests()->delete();

        return response()->json([
            'message' => 'Semua data tamu berhasil dihapus.',
            'data' => [
                'deleted' => $deleted,
            ],
        ]);
    }

    public function updateRsvp(Request $request, int $guest): GuestResource
    {
        $data = $request->validate([
            'rsvp_status' => ['required', 'string', 'in:'.implode(',', array_keys(Guest::$rsvpOptions))],
        ]);

        $record = $this->findOwned($request, $guest);
        $record->update([
            'rsvp_status' => $data['rsvp_status'],
            'rsvp_updated_by_name' => $request->user()->name,
            'rsvp_updated_at' => now(),
        ]);

        return new GuestResource($record);
    }

    public function downloadTemplate()
    {
        try {
            return app(GuestExcelService::class)->downloadTemplate();
        } catch (\Throwable $exception) {
            throw $exception instanceof \App\Exceptions\ExcelUnavailableException
                ? $exception
                : \App\Exceptions\ExcelUnavailableException::from($exception);
        }
    }

    public function importExcel(Request $request): JsonResponse
    {
        $request->validate([
            'spreadsheet' => ExcelSupport::spreadsheetUploadRules(),
        ]);

        $storedPath = $request->file('spreadsheet')->store('imports/guests', 'local');
        $absolutePath = Storage::disk('local')->path($storedPath);

        try {
            $result = app(GuestExcelService::class)->import($request->user(), $absolutePath);
        } catch (\Throwable $exception) {
            throw $exception instanceof \App\Exceptions\ExcelUnavailableException
                ? $exception
                : \App\Exceptions\ExcelUnavailableException::from($exception);
        } finally {
            Storage::disk('local')->delete($storedPath);
        }

        return response()->json([
            'message' => 'Import daftar tamu selesai.',
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
            'phone' => ['nullable', 'string', 'max:20'],
            'email' => ['nullable', 'email', 'max:255'],
            'table_number' => ['nullable', 'string', 'max:50'],
            'rsvp_status' => ['nullable', 'string', 'in:'.implode(',', array_keys(Guest::$rsvpOptions))],
            'catatan' => ['nullable', 'string'],
        ]);
    }

    private function findOwned(Request $request, int $id): Guest
    {
        return Guest::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
