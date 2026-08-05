<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inspirations', function (Blueprint $table) {
            $table->text('description')->nullable()->after('title');
            $table->unsignedInteger('views_count')->default(0)->after('likes_count');
        });
    }

    public function down(): void
    {
        Schema::table('inspirations', function (Blueprint $table) {
            $table->dropColumn(['description', 'views_count']);
        });
    }
};
