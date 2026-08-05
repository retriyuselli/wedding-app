<?php

namespace App\Models\Paket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Read-only mirror of paketpernikahan.co.id category_vendors.
 */
class CategoryVendor extends Model
{
    protected $connection = 'mysql_paket';

    protected $table = 'category_vendors';

    public $timestamps = true;

    protected $guarded = ['*'];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function vendors(): HasMany
    {
        return $this->hasMany(Vendor::class, 'category', 'slug');
    }
}
