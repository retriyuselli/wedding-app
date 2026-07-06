<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('customer_preparation_sub_tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('preparation_task_id')
                ->constrained('customer_preparation_tasks', indexName: 'prep_sub_tasks_task_id_fk')
                ->cascadeOnDelete();
            $table->string('title');
            $table->string('status')->default('pending');
            $table->date('due_date')->nullable();
            $table->date('completed_at')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_preparation_sub_tasks');
    }
};
