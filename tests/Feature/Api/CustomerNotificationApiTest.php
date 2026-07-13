<?php

namespace Tests\Feature\Api;

use App\Models\CustomerNotification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CustomerNotificationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_index_returns_only_authenticated_user_notifications(): void
    {
        $user = User::factory()->create();
        $other = User::factory()->create();

        CustomerNotification::factory()->for($user)->create([
            'title' => 'Mine',
            'is_unread' => true,
        ]);
        CustomerNotification::factory()->for($other)->create([
            'title' => 'Theirs',
            'is_unread' => true,
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/customer-notifications')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Mine')
            ->assertJsonPath('data.0.is_unread', true)
            ->assertJsonMissing(['title' => 'Theirs']);
    }

    public function test_unread_only_filter_works(): void
    {
        $user = User::factory()->create();

        CustomerNotification::factory()->for($user)->create([
            'title' => 'Unread',
            'is_unread' => true,
        ]);
        CustomerNotification::factory()->for($user)->create([
            'title' => 'Read',
            'is_unread' => false,
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/customer-notifications?unread_only=1')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Unread');
    }

    public function test_guest_cannot_list_notifications(): void
    {
        $this->getJson('/api/v1/customer-notifications')->assertUnauthorized();
    }
}
