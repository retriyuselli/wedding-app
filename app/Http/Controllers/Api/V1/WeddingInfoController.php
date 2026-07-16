<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingInfoResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class WeddingInfoController extends Controller
{
    public function show(Request $request): WeddingInfoResource
    {
        return new WeddingInfoResource($request->user()->weddingInfo);
    }

    public function update(Request $request): WeddingInfoResource
    {
        $data = $request->validate([
            'groom_name' => ['nullable', 'string', 'max:255'],
            'groom_full_name' => ['nullable', 'string', 'max:255'],
            'groom_phone' => ['nullable', 'string', 'max:50'],
            'groom_father_name' => ['nullable', 'string', 'max:255'],
            'groom_mother_name' => ['nullable', 'string', 'max:255'],
            'bride_name' => ['nullable', 'string', 'max:255'],
            'bride_full_name' => ['nullable', 'string', 'max:255'],
            'bride_phone' => ['nullable', 'string', 'max:50'],
            'bride_father_name' => ['nullable', 'string', 'max:255'],
            'bride_mother_name' => ['nullable', 'string', 'max:255'],
            'budaya' => ['nullable', 'string', 'max:100'],
            'songlist' => ['nullable', 'array'],
            'songlist.*' => ['string', 'max:255'],
        ]);

        $info = $request->user()->weddingInfo()->updateOrCreate(
            ['user_id' => $request->user()->id],
            $data
        );

        return new WeddingInfoResource($info);
    }

    public function uploadPhoto(Request $request): WeddingInfoResource
    {
        $request->validate([
            'couple_photo' => ['required', 'image', 'max:1024'],
        ]);

        $info = $request->user()->weddingInfo()->firstOrCreate(
            ['user_id' => $request->user()->id]
        );

        if ($info->couple_photo && ! str_starts_with($info->couple_photo, 'http')) {
            Storage::disk('public')->delete($info->couple_photo);
        }

        $path = $request->file('couple_photo')->store(
            'couple-photos/'.$request->user()->id,
            'public'
        );

        $info->update(['couple_photo' => $path]);

        return new WeddingInfoResource($info->fresh());
    }
}
