<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\Activitylog\Support\LogOptions;
use Spatie\Activitylog\Models\Concerns\LogsActivity;

class VendorReview extends Model
{
    use HasFactory, LogsActivity;

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logFillable()
            ->logOnlyDirty()
            ->dontLogEmptyChanges();
    }

    protected $fillable = [
        'vendor_id', 'user_id', 'reviewer_name', 'reviewer_avatar',
        'rating', 'body', 'photo', 'admin_reply', 'admin_reply_by', 'admin_replied_at',
        'reviewed_at', 'is_approved', 'reviewer_ip',
    ];

    protected $casts = [
        'rating'      => 'integer',
        'admin_replied_at' => 'datetime',
        'reviewed_at' => 'date',
        'is_approved' => 'boolean',
    ];

    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function adminReplyBy()
    {
        return $this->belongsTo(User::class, 'admin_reply_by');
    }
}
