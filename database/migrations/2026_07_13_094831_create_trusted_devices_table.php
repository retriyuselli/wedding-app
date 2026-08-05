<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trusted_devices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('device_name');
            $table->string('device_identifier');
            $table->string('platform', 32)->nullable();
            $table->boolean('is_trusted')->default(true);
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('trusted_at')->nullable();
            $table->unsignedBigInteger('personal_access_token_id')->nullable()->index();
            $table->timestamps();

            $table->unique(['user_id', 'device_identifier']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trusted_devices');
    }
};
