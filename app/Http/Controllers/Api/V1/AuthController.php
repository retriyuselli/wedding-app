<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\ActiveSessionResource;
use App\Http\Resources\V1\UserResource;
use App\Models\User;
use App\Services\SocialAuthenticationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(
        private SocialAuthenticationService $socialAuthenticationService,
    ) {}

    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'device_name' => ['required', 'string', 'max:255'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);

        $token = $user->createToken($data['device_name'])->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_name' => ['required', 'string', 'max:255'],
        ]);

        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        $token = $user->createToken($data['device_name'])->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
        ]);

        Password::sendResetLink([
            'email' => $data['email'],
        ]);

        return response()->json([
            'message' => 'Jika email terdaftar, instruksi reset kata sandi sudah dikirim.',
        ]);
    }

    public function google(Request $request): JsonResponse
    {
        $data = $request->validate([
            'id_token' => ['required', 'string'],
            'device_name' => ['required', 'string', 'max:255'],
        ]);

        $user = $this->socialAuthenticationService->userFromGoogleIdToken($data['id_token']);

        $token = $user->createToken($data['device_name'])->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }

    public function apple(Request $request): JsonResponse
    {
        $data = $request->validate([
            'identity_token' => ['required', 'string'],
            'device_name' => ['required', 'string', 'max:255'],
            'full_name' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
        ]);

        $user = $this->socialAuthenticationService->userFromAppleIdentityToken(
            $data['identity_token'],
            $data['full_name'] ?? null,
            $data['email'] ?? null,
        );

        $token = $user->createToken($data['device_name'])->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil logout.']);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => new UserResource($request->user()),
        ]);
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'whatsapp' => ['nullable', 'string', 'max:20'],
        ]);

        $user = $request->user();
        $user->update([
            'name' => $data['name'],
            'whatsapp' => $data['whatsapp'] ?? null,
        ]);

        return response()->json([
            'user' => new UserResource($user->fresh()),
        ]);
    }

    public function changePassword(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->usesSocialLogin()) {
            throw ValidationException::withMessages([
                'current_password' => ['Akun Anda masuk melalui Google atau Apple. Ubah kata sandi tidak tersedia.'],
            ]);
        }

        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        if (! Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['Kata sandi saat ini tidak sesuai.'],
            ]);
        }

        $user->update([
            'password' => $data['password'],
        ]);

        $currentTokenId = $user->currentAccessToken()?->id;
        $user->tokens()
            ->when($currentTokenId, fn ($query) => $query->where('id', '!=', $currentTokenId))
            ->delete();

        return response()->json([
            'message' => 'Kata sandi berhasil diubah.',
        ]);
    }

    public function deleteAccount(Request $request): JsonResponse
    {
        $user = $request->user();

        $rules = [
            'confirmation' => ['required', 'string', 'in:HAPUS'],
        ];

        if (! $user->usesSocialLogin()) {
            $rules['password'] = ['required', 'string'];
        }

        $data = $request->validate($rules);

        if (isset($data['password']) && ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'password' => ['Kata sandi tidak sesuai.'],
            ]);
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'message' => 'Akun berhasil dihapus.',
        ]);
    }

    public function sessions(Request $request): JsonResponse
    {
        $currentTokenId = $request->user()->currentAccessToken()?->id;

        $sessions = $request->user()->tokens()
            ->orderByDesc('last_used_at')
            ->orderByDesc('created_at')
            ->get()
            ->map(function ($token) use ($currentTokenId) {
                $token->setAttribute('is_current', $token->id === $currentTokenId);

                return $token;
            });

        return response()->json([
            'data' => ActiveSessionResource::collection($sessions),
        ]);
    }

    public function destroySession(Request $request, int $token): JsonResponse
    {
        $session = $request->user()->tokens()->whereKey($token)->firstOrFail();
        $isCurrent = $session->id === $request->user()->currentAccessToken()?->id;

        $session->delete();

        return response()->json([
            'message' => $isCurrent ? 'Sesi perangkat ini telah diakhiri.' : 'Sesi berhasil diakhiri.',
            'logged_out_current_device' => $isCurrent,
        ]);
    }

    public function destroyOtherSessions(Request $request): JsonResponse
    {
        $currentTokenId = $request->user()->currentAccessToken()?->id;

        $deletedCount = $request->user()->tokens()
            ->when($currentTokenId, fn ($query) => $query->where('id', '!=', $currentTokenId))
            ->delete();

        return response()->json([
            'message' => 'Semua sesi lain berhasil diakhiri.',
            'revoked_count' => $deletedCount,
        ]);
    }
}
