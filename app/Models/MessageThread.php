<?php

namespace App\Models;

use App\Support\DummyImage;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class MessageThread extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'category',
        'avatar_url',
        'is_online',
    ];

    protected function casts(): array
    {
        return [
            'is_online' => 'boolean',
        ];
    }

    public static array $categoryOptions = [
        'vendor' => 'Vendor',
        'committee' => 'Panitia',
        'support' => 'Support',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class)->orderBy('created_at');
    }

    public function latestMessage(): HasOne
    {
        return $this->hasOne(Message::class)->latestOfMany();
    }

    public function categoryLabel(): string
    {
        return self::$categoryOptions[$this->category] ?? ucfirst($this->category);
    }

    public function avatarImageUrl(): string
    {
        if ($this->avatar_url) {
            if (str_starts_with($this->avatar_url, 'http://') || str_starts_with($this->avatar_url, 'https://')) {
                return $this->avatar_url;
            }

            return asset('storage/'.$this->avatar_url);
        }

        return DummyImage::url('avatar', $this->id);
    }

    public function initials(): string
    {
        $parts = preg_split('/\s+/', trim($this->name)) ?: [];

        if (count($parts) >= 2) {
            return strtoupper(substr($parts[0], 0, 1).substr($parts[1], 0, 1));
        }

        return strtoupper(substr($this->name, 0, 2));
    }
}
