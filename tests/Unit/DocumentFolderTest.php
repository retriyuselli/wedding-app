<?php

namespace Tests\Unit;

use App\Support\DocumentFolder;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class DocumentFolderTest extends TestCase
{
    #[Test]
    public function it_matches_vendor_contracts_to_vendor_folder(): void
    {
        $folder = DocumentFolder::match('Meeting vendor dekorasi', 'Kontrak_Vendor.pdf');

        $this->assertSame(DocumentFolder::Vendor, $folder);
    }

    #[Test]
    public function it_matches_spreadsheets_to_finance_folder(): void
    {
        $folder = DocumentFolder::match('Persiapan awal', 'anggaran.xlsx');

        $this->assertSame(DocumentFolder::Finance, $folder);
    }

    #[Test]
    public function it_matches_legal_documents_to_legal_folder(): void
    {
        $folder = DocumentFolder::match('Fotokopi KTP kedua mempelai', 'KTP_Salinan.pdf');

        $this->assertSame(DocumentFolder::Legal, $folder);
    }
}
