<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wedding_incoming_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('bank_name')->nullable();
            $table->decimal('amount', 15, 2)->default(0);
            $table->date('transfer_date');
            $table->string('sender_name');
            $table->string('description')->nullable();
            $table->string('reference_number')->nullable();
            $table->string('proof_url')->nullable();
            $table->string('status')->default('menunggu');
            $table->datetime('confirmed_at')->nullable();
            $table->string('confirmed_by')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wedding_incoming_payments');
    }
};
