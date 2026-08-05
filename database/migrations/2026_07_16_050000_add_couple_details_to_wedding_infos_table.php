<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('wedding_infos', function (Blueprint $table) {
            $table->string('bride_phone')->nullable()->after('bride_name');
            $table->string('bride_father_name')->nullable()->after('bride_phone');
            $table->string('bride_mother_name')->nullable()->after('bride_father_name');
            $table->string('groom_phone')->nullable()->after('groom_name');
            $table->string('groom_father_name')->nullable()->after('groom_phone');
            $table->string('groom_mother_name')->nullable()->after('groom_father_name');
        });
    }

    public function down(): void
    {
        Schema::table('wedding_infos', function (Blueprint $table) {
            $table->dropColumn([
                'bride_phone',
                'bride_father_name',
                'bride_mother_name',
                'groom_phone',
                'groom_father_name',
                'groom_mother_name',
            ]);
        });
    }
};
