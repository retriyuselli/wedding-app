<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingDocumentResource;
use App\Models\CustomerPreparationTaskAttachment;
use App\Models\WeddingDocument;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Symfony\Component\HttpFoundation\StreamedResponse;

class WeddingDocumentController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $documents = $this->mergedDocuments($request)
            ->values();

        return WeddingDocumentResource::collection($documents);
    }

    public function summary(Request $request): JsonResponse
    {
        $documents = $this->mergedDocuments($request);
        $usedBytes = (int) $documents->sum(fn ($document) => (int) ($document->file_size ?? 0));
        $quotaBytes = WeddingDocument::STORAGE_QUOTA_BYTES;

        $counts = [
            'all' => $documents->count(),
        ];

        foreach (array_keys(WeddingDocument::$categoryOptions) as $category) {
            $counts[$category] = $documents->where('category', $category)->count();
        }

        return response()->json([
            'data' => [
                'used_bytes' => $usedBytes,
                'quota_bytes' => $quotaBytes,
                'used_percent' => $quotaBytes > 0
                    ? round(min(100, ($usedBytes / $quotaBytes) * 100), 1)
                    : 0,
                'counts' => $counts,
            ],
        ]);
    }

    public function store(Request $request): WeddingDocumentResource
    {
        $data = $request->validate([
            'file' => ['required', 'file', 'mimes:pdf,jpg,jpeg,png,heic,heif', 'max:10240'],
            'category' => ['nullable', 'string', Rule::in(array_keys(WeddingDocument::$categoryOptions))],
            'document_folder_id' => [
                'nullable',
                'integer',
                Rule::exists('document_folders', 'id')->where(fn ($query) => $query->where('user_id', $request->user()->id)),
            ],
        ]);

        /** @var UploadedFile $file */
        $file = $data['file'];
        $usedBytes = $this->mergedDocuments($request)->sum(fn ($document) => (int) ($document->file_size ?? 0));

        if (($usedBytes + $file->getSize()) > WeddingDocument::STORAGE_QUOTA_BYTES) {
            abort(422, 'Kuota penyimpanan 500MB sudah penuh.');
        }

        $path = $file->store('wedding-documents/'.$request->user()->id, 'public');
        $fileName = $file->getClientOriginalName();

        $document = $request->user()->weddingDocuments()->create([
            'document_folder_id' => $data['document_folder_id'] ?? null,
            'file_name' => $fileName,
            'file_path' => $path,
            'file_size' => $file->getSize(),
            'mime_type' => $file->getClientMimeType(),
            'category' => $data['category'] ?? WeddingDocument::matchCategory($fileName),
        ]);

        return new WeddingDocumentResource($document->load('folder'));
    }

    public function update(Request $request, int $weddingDocument): WeddingDocumentResource
    {
        $data = $request->validate([
            'category' => ['sometimes', 'string', Rule::in(array_keys(WeddingDocument::$categoryOptions))],
            'document_folder_id' => [
                'nullable',
                'integer',
                Rule::exists('document_folders', 'id')->where(fn ($query) => $query->where('user_id', $request->user()->id)),
            ],
            'file_name' => ['sometimes', 'string', 'max:255'],
        ]);

        $document = $this->findOwned($request, $weddingDocument);
        $document->update($data);

        return new WeddingDocumentResource($document->fresh()->load('folder'));
    }

    public function destroy(Request $request, int $weddingDocument): Response
    {
        $document = $this->findOwned($request, $weddingDocument);

        if ($document->file_path !== '') {
            Storage::disk('public')->delete($document->file_path);
        }

        $document->delete();

        return response()->noContent();
    }

    public function download(Request $request, int $weddingDocument): StreamedResponse
    {
        $document = $this->findOwned($request, $weddingDocument);

        abort_unless(
            $document->file_path !== '' && Storage::disk('public')->exists($document->file_path),
            404,
            'File dokumen tidak ditemukan.'
        );

        return Storage::disk('public')->download(
            $document->file_path,
            $document->file_name,
            [
                'Content-Type' => $document->mime_type ?? 'application/octet-stream',
            ]
        );
    }

    private function findOwned(Request $request, int $id): WeddingDocument
    {
        return WeddingDocument::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);
    }

    /**
     * @return Collection<int, WeddingDocument>
     */
    private function mergedDocuments(Request $request): Collection
    {
        $category = $request->string('category')->toString();
        $folderId = $request->integer('folder_id');
        $search = trim($request->string('q')->toString());
        $sort = $request->string('sort', 'latest')->toString();

        $uploaded = $request->user()
            ->weddingDocuments()
            ->with('folder')
            ->when(
                $category !== '' && $category !== 'all',
                fn ($query) => $query->where('category', $category)
            )
            ->when($folderId > 0, fn ($query) => $query->where('document_folder_id', $folderId))
            ->when($search !== '', function ($query) use ($search): void {
                $query->where(function ($inner) use ($search): void {
                    $inner->where('file_name', 'like', "%{$search}%");
                });
            })
            ->get()
            ->each(function (WeddingDocument $document): void {
                $document->setAttribute('source', 'uploaded');
            });

        $attachments = collect();

        if ($folderId <= 0) {
            $attachments = CustomerPreparationTaskAttachment::query()
                ->with('preparationTask:id,title')
                ->where('user_id', $request->user()->id)
                ->get()
                ->map(function (CustomerPreparationTaskAttachment $attachment) use ($category, $search): ?WeddingDocument {
                    $taskTitle = $attachment->preparationTask?->title ?? '';
                    $matchedCategory = WeddingDocument::matchCategory($attachment->file_name, $taskTitle);

                    if ($category !== '' && $category !== 'all' && $matchedCategory !== $category) {
                        return null;
                    }

                    if ($search !== '') {
                        $haystack = strtolower($attachment->file_name.' '.$taskTitle);
                        if (! str_contains($haystack, strtolower($search))) {
                            return null;
                        }
                    }

                    $document = new WeddingDocument([
                        'user_id' => $attachment->user_id,
                        'document_folder_id' => null,
                        'file_name' => $attachment->file_name,
                        'file_path' => $attachment->file_path,
                        'file_size' => $attachment->file_size ?? 0,
                        'mime_type' => $attachment->mime_type,
                        'category' => $matchedCategory,
                    ]);
                    $document->id = -1 * (int) $attachment->id;
                    $document->created_at = $attachment->created_at;
                    $document->updated_at = $attachment->updated_at;
                    $document->setAttribute('source', 'checklist');
                    $document->setAttribute('task_title', $taskTitle);
                    $document->setRelation('folder', null);

                    return $document;
                })
                ->filter()
                ->values();
        }

        $merged = $uploaded->concat($attachments);

        return match ($sort) {
            'oldest' => $merged->sortBy('created_at'),
            'name' => $merged->sortBy(fn (WeddingDocument $document) => strtolower($document->file_name)),
            'name_desc' => $merged->sortByDesc(fn (WeddingDocument $document) => strtolower($document->file_name)),
            default => $merged->sortByDesc('created_at'),
        };
    }
}
