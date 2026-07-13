<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\DocumentFolderResource;
use App\Models\DocumentFolder;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class DocumentFolderController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $folders = $request->user()
            ->documentFolders()
            ->withCount('documents')
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return DocumentFolderResource::collection($folders);
    }

    public function store(Request $request): DocumentFolderResource
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);

        $data['sort_order'] ??= ((int) $request->user()->documentFolders()->max('sort_order')) + 1;

        $folder = $request->user()->documentFolders()->create($data);

        return new DocumentFolderResource($folder->loadCount('documents'));
    }

    public function update(Request $request, int $documentFolder): DocumentFolderResource
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);

        $folder = $this->findOwned($request, $documentFolder);
        $folder->update($data);

        return new DocumentFolderResource($folder->loadCount('documents'));
    }

    public function destroy(Request $request, int $documentFolder): Response
    {
        $folder = $this->findOwned($request, $documentFolder);
        $folder->documents()->update(['document_folder_id' => null]);
        $folder->delete();

        return response()->noContent();
    }

    private function findOwned(Request $request, int $id): DocumentFolder
    {
        return DocumentFolder::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);
    }
}
