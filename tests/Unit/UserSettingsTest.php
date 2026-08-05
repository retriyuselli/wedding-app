<?php

namespace Tests\Unit;

use App\Models\User;
use App\Support\UserSettings;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class UserSettingsTest extends TestCase
{
    #[Test]
    public function it_merges_defaults_with_stored_user_settings(): void
    {
        $user = new User([
            'notification_settings' => [
                'dark_mode' => true,
                'language' => 'en',
            ],
        ]);

        $settings = UserSettings::forUser($user);

        $this->assertTrue($settings['dark_mode']);
        $this->assertSame('en', $settings['language']);
        $this->assertSame('IDR', $settings['currency']);
    }
}
