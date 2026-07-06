<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

use Spatie\Activitylog\Support\LogOptions;
use Spatie\Activitylog\Models\Concerns\LogsActivity;

class Wishlist extends Model
{
    use LogsActivity;

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logFillable()
            ->logOnlyDirty()
            ->dontLogEmptyChanges();
    }

    protected $fillable = ['user_id', 'vendor_package_id'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function vendorPackage()
    {
        return $this->belongsTo(VendorPackage::class);
    }
}
