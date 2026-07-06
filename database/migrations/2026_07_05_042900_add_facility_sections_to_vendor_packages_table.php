<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('vendor_packages', function (Blueprint $table) {
            $table->json('facility_sections')->nullable()->after('inclusions');
        });
    }

    public function down(): void
    {
        Schema::table('vendor_packages', function (Blueprint $table) {
            $table->dropColumn('facility_sections');
        });
    }
};
