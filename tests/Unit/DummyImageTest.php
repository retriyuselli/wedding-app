<?php

namespace Tests\Unit;

use App\Support\DummyImage;
use Tests\TestCase;

class DummyImageTest extends TestCase
{
    public function test_dummy_image_returns_asset_url_for_known_types(): void
    {
        $this->assertStringContainsString('/images/dashboard/dummy-avatar.svg', DummyImage::url('avatar'));
        $this->assertStringContainsString('/images/dashboard/dummy-vendor-2.svg', DummyImage::url('vendor', 1));
        $this->assertStringContainsString('/images/dashboard/dummy-inspiration-1.svg', DummyImage::url('inspiration', 0));
    }
}
