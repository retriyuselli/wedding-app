<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vip_guests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('no')->nullable();
            $table->string('name');
            $table->string('jabatan')->nullable();
            $table->string('instansi')->nullable();
            $table->string('phone')->nullable();
            $table->string('kategori')->default('vip');
            $table->string('rsvp_status')->default('menunggu');
            $table->string('rsvp_updated_by_name')->nullable();
            $table->datetime('rsvp_updated_at')->nullable();
            $table->text('catatan')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vip_guests');
    }
};
