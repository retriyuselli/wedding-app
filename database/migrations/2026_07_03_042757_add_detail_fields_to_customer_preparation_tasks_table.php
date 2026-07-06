<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('customer_preparation_tasks', function (Blueprint $table) {
            $table->text('description')->nullable()->after('label');
            $table->text('notes')->nullable()->after('description');
            $table->string('priority')->default('medium')->after('notes');
        });
    }

    public function down(): void
    {
        Schema::table('customer_preparation_tasks', function (Blueprint $table) {
            $table->dropColumn(['description', 'notes', 'priority']);
        });
    }
};
