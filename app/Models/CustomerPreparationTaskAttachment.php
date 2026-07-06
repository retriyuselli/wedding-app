<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class CustomerPreparationTaskAttachment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'preparation_task_id',
        'file_name',
        'file_path',
        'file_size',
        'mime_type',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function preparationTask(): BelongsTo
    {
        return $this->belongsTo(CustomerPreparationTask::class, 'preparation_task_id');
    }

    protected static function booted(): void
    {
        static::creating(function (CustomerPreparationTaskAttachment $attachment): void {
            if ($attachment->user_id === null && $attachment->preparation_task_id !== null) {
                $attachment->user_id = CustomerPreparationTask::query()
                    ->whereKey($attachment->preparation_task_id)
                    ->value('user_id');
            }
        });
    }

    public function getUrlAttribute(): ?string
    {
        if ($this->file_path === '') {
            return null;
        }

        return Storage::disk('public')->url($this->file_path);
    }
}
