<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('wedding_events', function (Blueprint $table) {
            $table->unsignedInteger('sort_order')->default(0)->after('jenis_acara');
        });

        $userIds = DB::table('wedding_events')->distinct()->pluck('user_id');

        foreach ($userIds as $userId) {
            $events = DB::table('wedding_events')
                ->where('user_id', $userId)
                ->orderBy('tgl_acara')
                ->orderBy('id')
                ->get();

            foreach ($events as $index => $event) {
                DB::table('wedding_events')
                    ->where('id', $event->id)
                    ->update(['sort_order' => $index + 1]);
            }
        }
    }

    public function down(): void
    {
        Schema::table('wedding_events', function (Blueprint $table) {
            $table->dropColumn('sort_order');
        });
    }
};
