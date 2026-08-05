<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\GuestResource;
use App\Http\Resources\V1\WeddingBudgetResource;
use App\Http\Resources\V1\WeddingEventResource;
use App\Http\Resources\V1\WeddingInfoResource;
use App\Models\User;
use App\Services\Privacy\PrivacyVisibilityGate;
use App\Services\Privacy\SharedPremiumAccess;
use App\Services\WeddingBudgetSummaryCalculator;
use App\Support\PrivacySettings;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class SharedPrivacyController extends Controller
{
    public function __construct(
        private PrivacyVisibilityGate $visibilityGate,
        private SharedPremiumAccess $sharedPremiumAccess,
        private WeddingBudgetSummaryCalculator $budgetSummaryCalculator,
    ) {}

    public function directory(Request $request): JsonResponse
    {
        $users = User::query()
            ->with('weddingInfo')
            ->orderBy('name')
            ->limit(100)
            ->get()
            ->filter(fn (User $user) => $this->visibilityGate->canAppearInDirectory($user))
            ->values()
            ->map(fn (User $user) => $this->publicProfilePayload($user));

        return response()->json([
            'data' => $users,
        ]);
    }

    public function profile(Request $request, User $user): JsonResponse
    {
        $this->visibilityGate->assertCanViewProfile($user, $request->user());

        $user->loadMissing('weddingInfo');

        return response()->json([
            'data' => $this->publicProfilePayload($user),
            'meta' => [
                'viewer_role' => $this->visibilityGate->viewerRole($user, $request->user()),
            ],
        ]);
    }

    public function wedding(Request $request, User $user): JsonResponse
    {
        $this->visibilityGate->assertCanViewWedding($user, $request->user());

        $info = $user->weddingInfo;
        $events = $user->weddingEvents()->get();

        return response()->json([
            'data' => [
                'wedding_info' => (new WeddingInfoResource($info))->resolve(),
                'events' => WeddingEventResource::collection($events)->resolve(),
            ],
            'meta' => [
                'viewer_role' => $this->visibilityGate->viewerRole($user, $request->user()),
            ],
        ]);
    }

    public function guests(Request $request, User $user): AnonymousResourceCollection
    {
        $this->visibilityGate->assertCanViewGuestList($user, $request->user());
        $this->sharedPremiumAccess->assertCanAccessProResource(
            $user,
            $request->user(),
            SharedPremiumAccess::ResourceGuests,
        );

        $guests = $user->guests()->orderBy('no')->orderBy('name')->get();

        return GuestResource::collection($guests)->additional([
            'meta' => [
                'viewer_role' => $this->visibilityGate->viewerRole($user, $request->user()),
                'via_owner_premium' => $request->user()?->id !== $user->id && $user->isPremium(),
            ],
        ]);
    }

    public function budget(Request $request, User $user): JsonResponse
    {
        $this->visibilityGate->assertCanViewBudget($user, $request->user());
        $this->sharedPremiumAccess->assertCanAccessProResource(
            $user,
            $request->user(),
            SharedPremiumAccess::ResourceBudget,
        );

        return response()->json([
            'data' => [
                'budget' => (new WeddingBudgetResource($user->weddingBudget))->resolve(),
                'summary' => $this->budgetSummaryCalculator->calculate($user),
            ],
            'meta' => [
                'viewer_role' => $this->visibilityGate->viewerRole($user, $request->user()),
                'via_owner_premium' => $request->user()?->id !== $user->id && $user->isPremium(),
            ],
        ]);
    }

    public function requestVendorContact(Request $request, User $user): JsonResponse
    {
        $viewer = $request->user();
        abort_unless($viewer !== null, 401);

        if ($viewer->id !== $user->id && ! $this->visibilityGate->isVendorActor($viewer)) {
            abort(403, 'Hanya vendor yang dapat mengirim permintaan kontak.');
        }

        $this->visibilityGate->assertCanVendorContact($user);

        return response()->json([
            'message' => 'Permintaan kontak diizinkan oleh pengaturan privasi pemilik akun.',
            'data' => [
                'user_id' => $user->id,
                'allow_vendor_contact' => true,
                'whatsapp' => $user->whatsapp,
                'email' => $user->email,
            ],
        ]);
    }

    /**
     * @return array<string, mixed>
     */
    private function publicProfilePayload(User $user): array
    {
        $settings = PrivacySettings::forUser($user);
        $info = $user->weddingInfo;

        return [
            'id' => $user->id,
            'name' => $user->name,
            'avatar_url' => $user->avatarUrl(),
            'profile_visibility' => $settings[PrivacySettings::ProfileVisibility],
            'show_in_directory' => (bool) $settings[PrivacySettings::ShowInDirectory],
            'allow_vendor_contact' => (bool) $settings[PrivacySettings::AllowVendorContact],
            'couple_preview' => $this->couplePreview($info),
            'budaya' => $info?->budaya,
        ];
    }

    private function couplePreview(mixed $info): ?string
    {
        if ($info === null) {
            return null;
        }

        $bride = trim((string) ($info->bride_name ?? ''));
        $groom = trim((string) ($info->groom_name ?? ''));

        if ($bride === '' && $groom === '') {
            return null;
        }

        if ($bride === '') {
            return $groom;
        }

        if ($groom === '') {
            return $bride;
        }

        return "{$bride} & {$groom}";
    }
}
