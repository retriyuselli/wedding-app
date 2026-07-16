<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\UserResource;
use App\Models\User;
use App\Services\Billing\AppleTransactionVerifier;
use App\Services\Privacy\SharedPremiumAccess;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use InvalidArgumentException;

class BillingController extends Controller
{
    public function __construct(
        private AppleTransactionVerifier $appleTransactionVerifier,
        private SharedPremiumAccess $sharedPremiumAccess,
    ) {}

    public function entitlement(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        return response()->json([
            'data' => [
                'is_premium' => $user->isPremium(),
                'premium_product_id' => $user->premium_product_id,
                'premium_activated_at' => $user->premium_activated_at,
                'shared_premium_access' => $this->sharedPremiumAccess->accessibleOwnersFor($user),
            ],
        ]);
    }

    public function verifyApple(Request $request): JsonResponse
    {
        $data = $request->validate([
            'product_id' => ['required', 'string', 'max:255'],
            'transaction_id' => ['required', 'string', 'max:255'],
            'original_transaction_id' => ['required', 'string', 'max:255'],
            'signed_transaction' => ['required', 'string'],
        ]);

        if (! in_array($data['product_id'], config('billing.pro_product_ids', []), true)) {
            throw ValidationException::withMessages([
                'product_id' => ['Produk tidak valid untuk Wedding Pro.'],
            ]);
        }

        try {
            $verified = $this->appleTransactionVerifier->verify(
                $data['signed_transaction'],
                $data['product_id'],
                $data['transaction_id'],
                $data['original_transaction_id'],
            );
        } catch (InvalidArgumentException $exception) {
            throw ValidationException::withMessages([
                'signed_transaction' => [$exception->getMessage()],
            ]);
        }

        /** @var User $user */
        $user = $request->user();

        $owner = User::query()
            ->where('apple_original_transaction_id', $verified['original_transaction_id'])
            ->first();

        if ($owner && $owner->id !== $user->id) {
            throw ValidationException::withMessages([
                'original_transaction_id' => ['Pembelian ini sudah terhubung ke akun lain.'],
            ]);
        }

        if ($user->isPremium()
            && $user->apple_original_transaction_id === $verified['original_transaction_id']) {
            return response()->json([
                'message' => 'Wedding Pro sudah aktif.',
                'user' => new UserResource($user),
            ]);
        }

        $user->forceFill([
            'is_premium' => true,
            'premium_product_id' => $verified['product_id'],
            'premium_activated_at' => $user->premium_activated_at ?? now(),
            'apple_original_transaction_id' => $verified['original_transaction_id'],
        ])->save();

        return response()->json([
            'message' => 'Wedding Pro berhasil diaktifkan.',
            'user' => new UserResource($user->fresh()),
        ]);
    }
}
