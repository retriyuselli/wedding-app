<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::table('wedding_payment_schedules')
            ->where('status', 'pending')
            ->whereNotNull('proof_url')
            ->update([
                'status' => 'paid',
                'paid_at' => now(),
                'updated_at' => now(),
            ]);
    }

    public function down(): void
    {
        // Irreversible data correction.
    }
};
