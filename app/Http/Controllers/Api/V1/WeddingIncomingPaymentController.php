<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingIncomingPaymentResource;
use App\Models\WeddingIncomingPayment;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WeddingIncomingPaymentController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = WeddingIncomingPayment::where('user_id', $request->user()->id);

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return WeddingIncomingPaymentResource::collection($query->orderByDesc('transfer_date')->get());
    }

    public function store(Request $request): WeddingIncomingPaymentResource
    {
        $data = $this->validated($request);
        $data['status'] = 'menunggu';

        $payment = $request->user()->incomingPayments()->create($data);

        return new WeddingIncomingPaymentResource($payment);
    }

    public function show(Request $request, int $weddingIncomingPayment): WeddingIncomingPaymentResource
    {
        return new WeddingIncomingPaymentResource($this->findOwned($request, $weddingIncomingPayment));
    }

    public function update(Request $request, int $weddingIncomingPayment): WeddingIncomingPaymentResource
    {
        $data = $this->validated($request);

        $payment = $this->findOwned($request, $weddingIncomingPayment);
        $payment->update($data);

        return new WeddingIncomingPaymentResource($payment);
    }

    public function destroy(Request $request, int $weddingIncomingPayment): \Illuminate\Http\Response
    {
        $this->findOwned($request, $weddingIncomingPayment)->delete();

        return response()->noContent();
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'bank_name'         => ['nullable', 'string', 'max:255'],
            'amount'            => ['required', 'numeric', 'min:0'],
            'transfer_date'     => ['required', 'date'],
            'sender_name'       => ['required', 'string', 'max:255'],
            'description'       => ['nullable', 'string', 'max:255'],
            'reference_number'  => ['nullable', 'string', 'max:255'],
            'notes'             => ['nullable', 'string'],
        ]);
    }

    private function findOwned(Request $request, int $id): WeddingIncomingPayment
    {
        return WeddingIncomingPayment::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
