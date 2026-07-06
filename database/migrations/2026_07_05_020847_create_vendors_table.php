<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vendors', function (Blueprint $table) {
            $table->id();

            // Relasi ke categories
            $table->foreignId('category_id')
                ->constrained('categories')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            // Informasi utama vendor
            $table->string('name', 150);
            $table->string('slug', 180)->unique();

            // Media
            $table->string('logo')->nullable();
            $table->string('cover_image')->nullable();

            // Deskripsi
            $table->text('description')->nullable();

            // Lokasi
            $table->string('province', 100)->nullable();
            $table->string('city', 100)->nullable();
            $table->text('address')->nullable();

            // Kontak
            $table->string('phone', 30)->nullable();
            $table->string('email', 150)->nullable();
            $table->string('website')->nullable();
            $table->string('instagram')->nullable();

            // Status vendor
            $table->boolean('is_verified')->default(false);
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_active')->default(true);

            // Urutan tampilan
            $table->unsignedInteger('sort_order')->default(0);

            $table->timestamps();

            // Database Index
            $table->index(['category_id', 'is_active']);
            $table->index(['is_featured', 'is_active']);
            $table->index(['is_active', 'sort_order']);
            $table->index(['province', 'city']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vendors');
    }
};