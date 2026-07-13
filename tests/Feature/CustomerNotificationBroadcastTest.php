<?php

namespace Tests\Feature;

use App\Models\CustomerNotification;
use App\Models\User;
use App\Services\BroadcastCustomerNotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use InvalidArgumentException;
use Tests\TestCase;

class CustomerNotificationBroadcastTest extends TestCase
{
    use RefreshDatabase;

    public function test_send_to_all_users_creates_one_notification_per_user(): void
    {
        $users = User::factory()->count(3)->create();

        $result = app(BroadcastCustomerNotificationService::class)->sendToAllUsers([
            'group' => 'system',
            'title' => 'Pengumuman penting',
            'message' => 'Halo semua.',
            'icon' => 'bell.fill',
            'destination' => null,
            'tint' => 'info',
            'is_unread' => true,
        ]);

        $this->assertSame(3, $result['count']);
        $this->assertInstanceOf(CustomerNotification::class, $result['first']);
        $this->assertDatabaseCount('customer_notifications', 3);

        foreach ($users as $user) {
            $this->assertDatabaseHas('customer_notifications', [
                'user_id' => $user->id,
                'title' => 'Pengumuman penting',
                'is_unread' => true,
            ]);
        }
    }

    public function test_send_to_all_users_fails_when_no_users_exist(): void
    {
        $this->expectException(InvalidArgumentException::class);

        app(BroadcastCustomerNotificationService::class)->sendToAllUsers([
            'title' => 'Kosong',
            'is_unread' => true,
        ]);
    }
}
