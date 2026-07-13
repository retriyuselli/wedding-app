<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->json('privacy_settings')->nullable()->after('notification_settings');
            $table->boolean('two_factor_enabled')->default(false)->after('privacy_settings');
            $table->timestamp('password_changed_at')->nullable()->after('password');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['privacy_settings', 'two_factor_enabled', 'password_changed_at']);
        });
    }
};
