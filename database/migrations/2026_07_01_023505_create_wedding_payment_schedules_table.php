<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wedding_payment_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wedding_event_id')->nullable()->constrained()->nullOnDelete();
            $table->unsignedBigInteger('source_template_id')->nullable();
            $table->foreignId('customer_payment_method_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->string('vendor_name')->nullable();
            $table->string('category')->nullable();
            $table->decimal('amount', 15, 2)->default(0);
            $table->date('due_date')->nullable();
            $table->string('status')->default('pending');
            $table->datetime('paid_at')->nullable();
            $table->string('proof_url')->nullable();
            $table->text('notes')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wedding_payment_schedules');
    }
};
