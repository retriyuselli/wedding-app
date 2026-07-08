<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CustomerPreparationTask extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'wedding_event_id',
        'section_id',
        'title',
        'label',
        'description',
        'notes',
        'priority',
        'status',
        'due_date',
        'sort_order',
    ];

    protected $casts = [
        'due_date' => 'date',
    ];

    public static array $statusOptions = [
        'pending' => 'Belum',
        'in_progress' => 'Sedang Dikerjakan',
        'done' => 'Selesai',
    ];

    public static array $priorityOptions = [
        'high' => 'Tinggi',
        'medium' => 'Sedang',
        'low' => 'Rendah',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function weddingEvent(): BelongsTo
    {
        return $this->belongsTo(WeddingEvent::class, 'wedding_event_id');
    }

    public function section(): BelongsTo
    {
        return $this->belongsTo(CustomerPreparationSection::class, 'section_id');
    }

    public function subTasks(): HasMany
    {
        return $this->hasMany(CustomerPreparationSubTask::class, 'preparation_task_id')->orderBy('sort_order');
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(CustomerPreparationTaskAttachment::class, 'preparation_task_id')->latest();
    }

    /**
     * Sinkronkan status task induk berdasarkan progress sub tugas.
     */
    public function syncStatusFromSubTasks(): void
    {
        $subTasks = $this->subTasks()->get();

        if ($subTasks->isEmpty()) {
            return;
        }

        $statuses = $subTasks->pluck('status');

        if ($statuses->every(fn (string $status): bool => $status === 'done')) {
            $this->status = 'done';

            return;
        }

        if ($statuses->every(fn (string $status): bool => $status === 'pending')) {
            $this->status = 'pending';

            return;
        }

        $this->status = 'in_progress';
    }

    protected static function booted(): void
    {
        static::creating(function (CustomerPreparationTask $task): void {
            if ($task->sort_order !== null) {
                return;
            }

            $query = static::query()->where('user_id', $task->user_id);

            if ($task->section_id !== null) {
                $query->where('section_id', $task->section_id);
            } else {
                $query->whereNull('section_id');
            }

            $task->sort_order = ((int) $query->max('sort_order')) + 1;
        });
    }
}
