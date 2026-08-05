<?php

namespace Tests\Feature;

use Tests\TestCase;

class TermsOfServicePageTest extends TestCase
{
    public function test_terms_of_service_page_is_publicly_accessible(): void
    {
        $response = $this->get(route('terms'));

        $response
            ->assertOk()
            ->assertSee('Syarat & Ketentuan')
            ->assertSee('Wedding App')
            ->assertSee('1. Penerimaan Syarat')
            ->assertSee('info@weddingapp.co.id')
            ->assertSee('www.weddingapp.co.id');
    }
}
