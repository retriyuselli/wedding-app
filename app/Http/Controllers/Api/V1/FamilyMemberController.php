<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\FamilyMemberResource;
use App\Models\FamilyMember;
use App\Services\FamilyMemberExcelService;
use App\Support\ExcelSupport;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class FamilyMemberController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $members = $request->user()->familyMembers()->orderBy('no')->orderBy('name')->get();

        return FamilyMemberResource::collection($members);
    }

    public function store(Request $request): FamilyMemberResource
    {
        $data = $this->validated($request);
        $data['rsvp_status'] ??= 'menunggu';
        $data['no'] ??= ((int) $request->user()->familyMembers()->max('no')) + 1;

        $member = $request->user()->familyMembers()->create($data);

        return new FamilyMemberResource($member);
    }

    public function show(Request $request, int $familyMember): FamilyMemberResource
    {
        return new FamilyMemberResource($this->findOwned($request, $familyMember));
    }

    public function update(Request $request, int $familyMember): FamilyMemberResource
    {
        $data = $this->validated($request);

        $record = $this->findOwned($request, $familyMember);
        $record->update($data);

        return new FamilyMemberResource($record);
    }

    public function destroy(Request $request, int $familyMember): Response
    {
        $this->findOwned($request, $familyMember)->delete();

        return response()->noContent();
    }

    public function destroyAll(Request $request): JsonResponse
    {
        $deleted = $request->user()->familyMembers()->delete();

        return response()->json([
            'message' => 'Semua data anggota keluarga berhasil dihapus.',
            'data' => [
                'deleted' => $deleted,
            ],
        ]);
    }

    public function updateRsvp(Request $request, int $familyMember): FamilyMemberResource
    {
        $data = $request->validate([
            'rsvp_status' => ['required', 'string', 'in:'.implode(',', array_keys(FamilyMember::$rsvpOptions))],
        ]);

        $record = $this->findOwned($request, $familyMember);
        $record->update([
            'rsvp_status' => $data['rsvp_status'],
            'rsvp_updated_by_name' => $request->user()->name,
            'rsvp_updated_at' => now(),
        ]);

        return new FamilyMemberResource($record);
    }

    public function downloadTemplate()
    {
        try {
            return app(FamilyMemberExcelService::class)->downloadTemplate();
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

        $storedPath = $request->file('spreadsheet')->store('imports/family-members', 'local');
        $absolutePath = Storage::disk('local')->path($storedPath);

        try {
            $result = app(FamilyMemberExcelService::class)->import($request->user(), $absolutePath);
        } catch (\Throwable $exception) {
            throw $exception instanceof \App\Exceptions\ExcelUnavailableException
                ? $exception
                : \App\Exceptions\ExcelUnavailableException::from($exception);
        } finally {
            Storage::disk('local')->delete($storedPath);
        }

        return response()->json([
            'message' => 'Import anggota keluarga selesai.',
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
            'role' => ['nullable', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'rsvp_status' => ['nullable', 'string', 'in:'.implode(',', array_keys(FamilyMember::$rsvpOptions))],
        ]);
    }

    private function findOwned(Request $request, int $id): FamilyMember
    {
        return FamilyMember::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
