<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vendor_packages', function (Blueprint $table) {
            $table->id();

            $table->foreignId('vendor_id')
                ->constrained('vendors')
                ->cascadeOnUpdate()
                ->cascadeOnDelete();

            $table->string('name', 150);
            $table->string('slug', 180);
            $table->text('description')->nullable();
            $table->decimal('price', 14, 2)->nullable();
            $table->string('price_type', 20)->default('fixed');
            $table->unsignedInteger('capacity_min')->nullable();
            $table->unsignedInteger('capacity_max')->nullable();
            $table->unsignedSmallInteger('duration_hours')->nullable();
            $table->json('inclusions')->nullable();
            $table->json('exclusions')->nullable();
            $table->string('cover_image')->nullable();
            $table->boolean('is_active')->default(true);
            $table->boolean('is_featured')->default(false);
            $table->unsignedInteger('sort_order')->default(0);

            $table->timestamps();

            $table->unique(['vendor_id', 'slug']);
            $table->index(['vendor_id', 'is_active', 'sort_order']);
            $table->index(['vendor_id', 'is_featured']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vendor_packages');
    }
};
