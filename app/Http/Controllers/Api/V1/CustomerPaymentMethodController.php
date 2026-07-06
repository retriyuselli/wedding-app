<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\CustomerPaymentMethodResource;
use App\Models\CustomerPaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CustomerPaymentMethodController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $methods = $request->user()->paymentMethods()->get();

        return CustomerPaymentMethodResource::collection($methods);
    }

    public function store(Request $request): CustomerPaymentMethodResource
    {
        $data = $this->validated($request);
        $data['is_primary'] ??= false;

        if ($data['is_primary']) {
            $request->user()->paymentMethods()->update(['is_primary' => false]);
        }

        $method = $request->user()->paymentMethods()->create($data);

        return new CustomerPaymentMethodResource($method);
    }

    public function show(Request $request, int $customerPaymentMethod): CustomerPaymentMethodResource
    {
        return new CustomerPaymentMethodResource($this->findOwned($request, $customerPaymentMethod));
    }

    public function update(Request $request, int $customerPaymentMethod): CustomerPaymentMethodResource
    {
        $data = $this->validated($request);
        $method = $this->findOwned($request, $customerPaymentMethod);

        if ($data['is_primary'] ?? false) {
            $request->user()->paymentMethods()->where('id', '!=', $method->id)->update(['is_primary' => false]);
        }

        $method->update($data);

        return new CustomerPaymentMethodResource($method);
    }

    public function destroy(Request $request, int $customerPaymentMethod): \Illuminate\Http\Response
    {
        $this->findOwned($request, $customerPaymentMethod)->delete();

        return response()->noContent();
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request): array
    {
        return $request->validate([
            'name'           => ['required', 'string', 'max:255'],
            'logo_icon'      => ['nullable', 'string', 'max:255'],
            'account_number' => ['nullable', 'string', 'max:255'],
            'account_name'   => ['nullable', 'string', 'max:255'],
            'is_primary'     => ['nullable', 'boolean'],
            'type'           => ['nullable', 'string', 'max:255'],
        ]);
    }

    private function findOwned(Request $request, int $id): CustomerPaymentMethod
    {
        return CustomerPaymentMethod::where('user_id', $request->user()->id)->findOrFail($id);
    }
}
