<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\CustomerPreparationSectionResource;
use App\Models\CustomerPreparationSection;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CustomerPreparationSectionController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $sections = $request->user()->preparationSections()->with('tasks')->get();

        return CustomerPreparationSectionResource::collection($sections);
    }

    public function store(Request $request): CustomerPreparationSectionResource
    {
        $data = $this->validated($request);
        $data['sort_order'] ??= $request->user()->preparationSections()->count();

        $section = $request->user()->preparationSections()->create($data);

        return new CustomerPreparationSectionResource($section);
    }

    public function show(Request $request, int $customerPreparationSection): CustomerPreparationSectionResource
    {
        return new CustomerPreparationSectionResource(
            $this->findOwned($request, $customerPreparationSection)->load('tasks')
        );
    }

    public function update(Request $request, int $customerPreparationSection): CustomerPreparationSectionResource
    {
        $data = $this->validated($request);

        $section = $this->findOwned($request, $customerPreparationSection);
        $section->update($data);

        return new CustomerPreparationSectionResource($section);
    }

    public function destroy(Request $request, int $customerPreparationSection): \Illuminate\Http\Response
    {
        $this->findOwned($request, $customerPreparationSection)->delete();

        return response()->noContent();
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'title'      => ['required', 'string', 'max:255'],
            'icon'       => ['nullable', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);
    }

    private function findOwned(Request $request, int $id): CustomerPreparationSection
    {
        return CustomerPreparationSection::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
