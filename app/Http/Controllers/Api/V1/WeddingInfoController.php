<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingInfoResource;
use Illuminate\Http\Request;

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
            'bride_name' => ['nullable', 'string', 'max:255'],
            'budaya'     => ['nullable', 'string', 'max:100'],
            'songlist'   => ['nullable', 'array'],
            'songlist.*' => ['string', 'max:255'],
        ]);

        $info = $request->user()->weddingInfo()->updateOrCreate(
            ['user_id' => $request->user()->id],
            $data
        );

        return new WeddingInfoResource($info);
    }
}
