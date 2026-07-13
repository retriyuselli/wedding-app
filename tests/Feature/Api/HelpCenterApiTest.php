<?php

namespace Tests\Feature\Api;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class HelpCenterApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_help_center_is_publicly_available(): void
    {
        $this->getJson('/api/v1/help-center')
            ->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'support_email',
                    'support_whatsapp',
                    'faqs',
                    'topics',
                    'contact_methods',
                ],
            ])
            ->assertJsonPath('data.support_email', fn ($email) => is_string($email) && $email !== '');
    }
}
