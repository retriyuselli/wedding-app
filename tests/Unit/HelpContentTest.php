<?php

namespace Tests\Unit;

use App\Support\HelpContent;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class HelpContentTest extends TestCase
{
    #[Test]
    public function it_provides_faq_and_contact_content(): void
    {
        $this->assertCount(6, HelpContent::faqs());
        $this->assertCount(8, HelpContent::topics());
        $this->assertCount(3, HelpContent::contactMethods());
        $this->assertStringContainsString('support@', HelpContent::supportEmail());
        $this->assertStringStartsWith('https://wa.me/', HelpContent::supportWhatsappUrl());
    }
}
