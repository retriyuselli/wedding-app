<?php

namespace App\Models;

use App\Support\DummyImage;
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

    public function categoryLabel(): string
    {
        return self::$categoryOptions[$this->category] ?? ucfirst($this->category);
    }

    public function coverImageUrl(): string
    {
        if ($this->image_url) {
            if (str_starts_with($this->image_url, 'http://') || str_starts_with($this->image_url, 'https://')) {
                return $this->image_url;
            }

            return asset('storage/'.$this->image_url);
        }

        return DummyImage::url('inspiration', $this->id);
    }

    public function photoCount(): int
    {
        if ($this->views_count > 0) {
            return max((int) round($this->views_count / 10), 12);
        }

        return 48 + (($this->id * 17) % 180);
    }

    /**
     * @return list<string>
     */
    public function paletteColors(): array
    {
        $palettes = [
            ['#385745', '#c29747', '#f6f8f6'],
            ['#6b8e6b', '#d4b06a', '#ffffff'],
            ['#547054', '#8aa68a', '#e8ede6'],
            ['#a67f3a', '#fbbf24', '#fff7ed'],
            ['#4b5563', '#d4ddd2', '#f9fafb'],
        ];

        return $palettes[$this->id % count($palettes)];
    }
}
