<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingQuoteResource;
use App\Models\WeddingQuote;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WeddingQuoteController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        $quotes = WeddingQuote::query()
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return WeddingQuoteResource::collection($quotes);
    }
}
