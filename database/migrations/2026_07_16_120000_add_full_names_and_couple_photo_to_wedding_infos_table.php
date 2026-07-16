<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('wedding_infos', function (Blueprint $table) {
            $table->string('bride_full_name')->nullable()->after('bride_name');
            $table->string('groom_full_name')->nullable()->after('groom_name');
            $table->string('couple_photo')->nullable()->after('budaya');
        });
    }

    public function down(): void
    {
        Schema::table('wedding_infos', function (Blueprint $table) {
            $table->dropColumn(['bride_full_name', 'groom_full_name', 'couple_photo']);
        });
    }
};
