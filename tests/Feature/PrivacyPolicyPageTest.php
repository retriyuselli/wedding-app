<?php

namespace Tests\Feature;

use Tests\TestCase;

class PrivacyPolicyPageTest extends TestCase
{
    public function test_privacy_policy_page_is_publicly_accessible(): void
    {
        $response = $this->get(route('privacy-policy'));

        $response
            ->assertOk()
            ->assertSee('Kebijakan Privasi')
            ->assertSee('Wedding App')
            ->assertSee('1. Data yang Kami Kumpulkan')
            ->assertSee('info@weddingapp.co.id')
            ->assertSee('www.weddingapp.co.id');
    }
}
