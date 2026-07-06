<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Support\IndonesiaRegions;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegionController extends Controller
{
    public function provinces(): JsonResponse
    {
        return response()->json([
            'data' => IndonesiaRegions::provinces(),
        ]);
    }

    public function cities(Request $request): JsonResponse
    {
        $province = $request->query('province');

        if (! is_string($province) || trim($province) === '') {
            return response()->json([
                'message' => 'Parameter province wajib diisi.',
            ], 422);
        }

        $cities = IndonesiaRegions::cities(trim($province));

        if ($cities === []) {
            return response()->json([
                'message' => 'Provinsi tidak ditemukan.',
            ], 404);
        }

        return response()->json([
            'data' => $cities,
        ]);
    }
}
