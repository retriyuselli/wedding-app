<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerPreparationSubTask extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'preparation_task_id',
        'title',
        'status',
        'due_date',
        'completed_at',
        'sort_order',
    ];

    protected $casts = [
        'due_date'     => 'date',
        'completed_at' => 'date',
    ];

    public static array $statusOptions = [
        'pending'     => 'Belum',
        'in_progress' => 'Sedang Dikerjakan',
        'done'        => 'Selesai',
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
        static::creating(function (CustomerPreparationSubTask $subTask): void {
            if ($subTask->user_id === null && $subTask->preparation_task_id !== null) {
                $subTask->user_id = CustomerPreparationTask::query()
                    ->whereKey($subTask->preparation_task_id)
                    ->value('user_id');
            }
        });
    }

    public function cycleStatus(): void
    {
        $this->status = match ($this->status) {
            'pending'     => 'in_progress',
            'in_progress' => 'done',
            'done'        => 'pending',
            default       => 'pending',
        };

        $this->completed_at = $this->status === 'done' ? now()->toDateString() : null;
    }
}
