<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\UserResource;
use App\Services\Privacy\TwoFactorAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TwoFactorController extends Controller
{
    public function __construct(
        private TwoFactorAuthService $twoFactorAuthService,
    ) {}

    public function status(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'data' => [
                'enabled' => $this->twoFactorAuthService->isEnabled($user),
                'method' => 'email',
                'email' => $user->email,
            ],
        ]);
    }

    public function enable(Request $request): JsonResponse
    {
        $this->twoFactorAuthService->sendEnableCode($request->user());

        return response()->json([
            'message' => 'Kode verifikasi telah dikirim ke email Anda.',
        ]);
    }

    public function confirm(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'size:6'],
        ]);

        $this->twoFactorAuthService->confirmEnable($request->user(), $data['code']);

        return response()->json([
            'message' => 'Verifikasi dua langkah berhasil diaktifkan.',
            'data' => [
                'enabled' => true,
                'method' => 'email',
            ],
        ]);
    }

    public function disable(Request $request): JsonResponse
    {
        $this->twoFactorAuthService->sendDisableCode($request->user());

        return response()->json([
            'message' => 'Kode verifikasi untuk menonaktifkan 2FA telah dikirim.',
        ]);
    }

    public function confirmDisable(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'size:6'],
            'password' => ['nullable', 'string'],
        ]);

        $this->twoFactorAuthService->confirmDisable(
            $request->user(),
            $data['code'],
            $data['password'] ?? null,
        );

        return response()->json([
            'message' => 'Verifikasi dua langkah dinonaktifkan.',
            'data' => [
                'enabled' => false,
                'method' => 'email',
            ],
        ]);
    }

    public function verifyLogin(Request $request): JsonResponse
    {
        $data = $request->validate([
            'two_factor_token' => ['required', 'string'],
            'code' => ['required', 'string', 'size:6'],
            'device_name' => ['required', 'string', 'max:255'],
        ]);

        $user = $this->twoFactorAuthService->completeLoginChallenge(
            $data['two_factor_token'],
            $data['code'],
        );

        $token = $user->createToken($data['device_name'])->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }
}
