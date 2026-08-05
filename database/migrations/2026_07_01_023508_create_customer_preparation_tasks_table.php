<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('customer_preparation_tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wedding_event_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('section_id')
                ->nullable()
                ->references('id')
                ->on('customer_preparation_sections')
                ->nullOnDelete();
            $table->string('title');
            $table->string('label')->nullable();
            $table->string('status')->default('pending');
            $table->date('due_date')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_preparation_tasks');
    }
};
