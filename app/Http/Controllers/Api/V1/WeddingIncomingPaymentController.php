<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\WeddingIncomingPaymentResource;
use App\Models\WeddingIncomingPayment;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

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
        $data['status'] ??= config('wedding.default_incoming_payment_status', 'menunggu');
        $data = $this->applyConfirmedTimestamp($data);

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
        $data = $this->applyConfirmedTimestamp($data, $payment);
        $payment->update($data);

        return new WeddingIncomingPaymentResource($payment);
    }

    public function destroy(Request $request, int $weddingIncomingPayment): Response
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
            'bank_name' => ['nullable', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0'],
            'transfer_date' => ['required', 'date'],
            'sender_name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:255'],
            'reference_number' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
            'status' => ['nullable', 'string', 'in:'.implode(',', array_keys(WeddingIncomingPayment::$statusOptions))],
        ]);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function applyConfirmedTimestamp(array $data, ?WeddingIncomingPayment $existing = null): array
    {
        if (($data['status'] ?? null) === 'confirmed') {
            $data['confirmed_at'] = $existing?->confirmed_at ?? now();
        } elseif (array_key_exists('status', $data)) {
            $data['confirmed_at'] = null;
        }

        return $data;
    }

    private function findOwned(Request $request, int $id): WeddingIncomingPayment
    {
        return WeddingIncomingPayment::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
