<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\TrustedDeviceResource;
use App\Models\TrustedDevice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class TrustedDeviceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $devices = $request->user()
            ->trustedDevices()
            ->orderByDesc('is_trusted')
            ->orderByDesc('last_used_at')
            ->get();

        $currentIdentifier = $request->string('current_device_identifier')->toString();

        $devices->each(function (TrustedDevice $device) use ($currentIdentifier): void {
            $device->setAttribute(
                'is_current',
                $currentIdentifier !== '' && $device->device_identifier === $currentIdentifier
            );
        });

        return response()->json([
            'data' => TrustedDeviceResource::collection($devices),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'device_name' => ['required', 'string', 'max:255'],
            'device_identifier' => ['required', 'string', 'max:255'],
            'platform' => ['nullable', 'string', 'max:32'],
            'is_trusted' => ['sometimes', 'boolean'],
        ]);

        $tokenId = $request->user()->currentAccessToken()?->id;
        $isTrusted = $data['is_trusted'] ?? true;

        $device = TrustedDevice::query()->updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'device_identifier' => $data['device_identifier'],
            ],
            [
                'device_name' => $data['device_name'],
                'platform' => $data['platform'] ?? 'ios',
                'is_trusted' => $isTrusted,
                'last_used_at' => now(),
                'trusted_at' => $isTrusted ? now() : null,
                'personal_access_token_id' => $tokenId,
            ]
        );

        $device->setAttribute('is_current', true);

        return response()->json([
            'data' => new TrustedDeviceResource($device),
            'message' => 'Perangkat berhasil disimpan.',
        ], 201);
    }

    public function update(Request $request, int $trustedDevice): JsonResponse
    {
        $device = $this->findOwned($request, $trustedDevice);

        $data = $request->validate([
            'device_name' => ['sometimes', 'string', 'max:255'],
            'is_trusted' => ['sometimes', 'boolean'],
        ]);

        if (array_key_exists('is_trusted', $data)) {
            $data['trusted_at'] = $data['is_trusted'] ? ($device->trusted_at ?? now()) : null;
        }

        $device->update($data);

        return response()->json([
            'data' => new TrustedDeviceResource($device->fresh()),
            'message' => 'Perangkat berhasil diperbarui.',
        ]);
    }

    public function destroy(Request $request, int $trustedDevice): Response
    {
        $device = $this->findOwned($request, $trustedDevice);
        $device->delete();

        return response()->noContent();
    }

    private function findOwned(Request $request, int $id): TrustedDevice
    {
        return TrustedDevice::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);
    }
}
