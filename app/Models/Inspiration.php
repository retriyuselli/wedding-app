<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Inspiration extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'category',
        'image_url',
        'thumbnail_symbol',
        'likes_count',
        'views_count',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'likes_count' => 'integer',
            'views_count' => 'integer',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public static array $categoryOptions = [
        'dekorasi' => 'Dekorasi',
        'gaun' => 'Gaun Pengantin',
        'makeup' => 'Makeup',
        'katering' => 'Katering',
        'venue' => 'Wedding Venue',
    ];

    public function savedByUsers(): BelongsToMany
    {
        return $this->belongsToMany(User::class)->withTimestamps();
    }

    public function likedByUsers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'inspiration_likes')->withTimestamps();
    }
}
