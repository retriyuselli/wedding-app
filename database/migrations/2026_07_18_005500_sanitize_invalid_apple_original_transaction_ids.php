<?php

use App\Models\User;
use App\Services\Billing\WeddingProEntitlementService;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        $service = app(WeddingProEntitlementService::class);

        User::query()
            ->whereNotNull('apple_original_transaction_id')
            ->orderBy('id')
            ->each(function (User $user) use ($service): void {
                $tx = (string) $user->apple_original_transaction_id;

                if ($service->isUsableAppleTransactionId($tx)) {
                    return;
                }

                // Keep manual Pro if needed, but free the colliding placeholder ID.
                $user->forceFill([
                    'apple_original_transaction_id' => $user->isPremium()
                        ? 'manual-sanitized-'.$user->id
                        : null,
                ])->save();
            });
    }

    public function down(): void
    {
        // Irreversible data repair.
    }
};
