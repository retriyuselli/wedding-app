<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CustomerPreparationSection extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'icon',
        'sort_order',
    ];

    /**
     * @var array<string, string>
     */
    public static array $iconOptions = [
        'person.2' => 'Keluarga',
        'calendar' => 'Kalender',
        'doc.text' => 'Dokumen',
        'envelope' => 'Undangan',
        'building.2' => 'Venue',
        'house' => 'Tempat',
        'sparkles' => 'Dekorasi',
        'tshirt' => 'Busana',
        'fork.knife' => 'Konsumsi',
        'camera' => 'Dokumentasi',
        'gift' => 'Hantaran',
        'giftcard' => 'Mahar',
        'person.wave.2' => 'Penceramah',
        'person.badge.shield.checkmark' => 'Penghulu',
        'mappin.and.ellipse' => 'Lokasi',
        'list.bullet.rectangle' => 'Susunan Acara',
        'checklist' => 'Perlengkapan',
        'checkmark.circle' => 'Ceklis Hari-H',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(CustomerPreparationTask::class, 'section_id')->orderBy('sort_order');
    }

    protected static function booted(): void
    {
        static::creating(function (CustomerPreparationSection $section): void {
            if ($section->sort_order !== null) {
                return;
            }

            $maxOrder = static::query()
                ->where('user_id', $section->user_id)
                ->max('sort_order');

            $section->sort_order = ((int) $maxOrder) + 1;
        });
    }
}
