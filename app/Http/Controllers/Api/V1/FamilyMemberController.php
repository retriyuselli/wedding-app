<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\FamilyMemberResource;
use App\Models\FamilyMember;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

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

    public function destroy(Request $request, int $familyMember): \Illuminate\Http\Response
    {
        $this->findOwned($request, $familyMember)->delete();

        return response()->noContent();
    }

    public function updateRsvp(Request $request, int $familyMember): FamilyMemberResource
    {
        $data = $request->validate([
            'rsvp_status' => ['required', 'string', 'in:'.implode(',', array_keys(FamilyMember::$rsvpOptions))],
        ]);

        $record = $this->findOwned($request, $familyMember);
        $record->update([
            'rsvp_status'          => $data['rsvp_status'],
            'rsvp_updated_by_name' => $request->user()->name,
            'rsvp_updated_at'      => now(),
        ]);

        return new FamilyMemberResource($record);
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'no'          => ['nullable', 'integer', 'min:0'],
            'name'        => ['required', 'string', 'max:255'],
            'role'        => ['nullable', 'string', 'max:255'],
            'phone'       => ['nullable', 'string', 'max:20'],
            'rsvp_status' => ['nullable', 'string', 'in:'.implode(',', array_keys(FamilyMember::$rsvpOptions))],
        ]);
    }

    private function findOwned(Request $request, int $id): FamilyMember
    {
        return FamilyMember::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
