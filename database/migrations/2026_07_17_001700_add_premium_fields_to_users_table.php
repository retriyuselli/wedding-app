<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_premium')->default(false)->after('password_changed_at');
            $table->string('premium_product_id')->nullable()->after('is_premium');
            $table->timestamp('premium_activated_at')->nullable()->after('premium_product_id');
            $table->string('apple_original_transaction_id')->nullable()->unique()->after('premium_activated_at');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'is_premium',
                'premium_product_id',
                'premium_activated_at',
                'apple_original_transaction_id',
            ]);
        });
    }
};
