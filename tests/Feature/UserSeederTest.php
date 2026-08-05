<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class UserSeederTest extends TestCase
{
    use RefreshDatabase;

    public function test_it_seeds_free_and_pro_app_review_accounts(): void
    {
        $this->seed(UserSeeder::class);

        $free = User::query()
            ->where('email', 'review.free@weddingapp.co.id')
            ->firstOrFail();

        $this->assertSame('App Review Free', $free->name);
        $this->assertTrue(Hash::check('ReviewFree2026!', $free->password));
        $this->assertNotNull($free->email_verified_at);
        $this->assertFalse($free->isPremium());
        $this->assertNull($free->premium_product_id);
        $this->assertNull($free->premium_activated_at);
        $this->assertNull($free->apple_original_transaction_id);

        $pro = User::query()
            ->where('email', 'review.pro@weddingapp.co.id')
            ->firstOrFail();

        $this->assertSame('App Review Pro', $pro->name);
        $this->assertTrue(Hash::check('ReviewPro2026!', $pro->password));
        $this->assertNotNull($pro->email_verified_at);
        $this->assertTrue($pro->isPremium());
        $this->assertSame('wedding_pro_unlock', $pro->premium_product_id);
        $this->assertNotNull($pro->premium_activated_at);
        $this->assertSame('app-review-demo-pro', $pro->apple_original_transaction_id);
    }
}
