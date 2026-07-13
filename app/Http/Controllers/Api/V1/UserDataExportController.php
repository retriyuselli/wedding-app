<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Privacy\UserDataExportService;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class UserDataExportController extends Controller
{
    public function __construct(
        private UserDataExportService $userDataExportService,
    ) {}

    public function download(Request $request): BinaryFileResponse
    {
        $path = $this->userDataExportService->createZip($request->user());

        return response()->download(
            $path,
            'wedding-app-data-export.zip',
            ['Content-Type' => 'application/zip']
        )->deleteFileAfterSend(true);
    }
}
