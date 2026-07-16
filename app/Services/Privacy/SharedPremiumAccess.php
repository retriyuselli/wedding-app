<?php

namespace App\Services\Privacy;

use App\Models\User;
use App\Support\PrivacySettings;
use Symfony\Component\HttpKernel\Exception\HttpException;

class SharedPremiumAccess
{
    public const ResourceGuests = 'guests';

    public const ResourceBudget = 'budget';

    /**
     * Pro resources that partners may inherit from a premium owner's wedding.
     *
     * @return list<string>
     */
    public static function proResources(): array
    {
        return [
            self::ResourceGuests,
            self::ResourceBudget,
        ];
    }

    public function __construct(
        private PrivacyVisibilityGate $visibilityGate,
    ) {}

    /**
     * Viewer may read a Pro shared resource when visibility allows and the
     * data owner holds Wedding Pro (option A: share the owner's premium only).
     */
    public function canAccessProResource(User $owner, ?User $viewer, string $resource): bool
    {
        if ($viewer === null) {
            return false;
        }

        if ($viewer->id === $owner->id) {
            return true;
        }

        if (! $owner->isPremium()) {
            return false;
        }

        return match ($resource) {
            self::ResourceGuests => $this->visibilityGate->canViewGuestList($owner, $viewer),
            self::ResourceBudget => $this->visibilityGate->canViewBudget($owner, $viewer),
            default => false,
        };
    }

    public function assertCanAccessProResource(User $owner, ?User $viewer, string $resource): void
    {
        if ($this->canAccessProResource($owner, $viewer, $resource)) {
            return;
        }

        if ($viewer !== null && $viewer->id !== $owner->id && ! $owner->isPremium()) {
            throw new HttpException(403, 'Pemilik data belum mengaktifkan Wedding Pro.', null, [
                'X-Privacy-Code' => 'owner_premium_required',
            ]);
        }

        throw new HttpException(403, config('billing.pro_required_message'), null, [
            'X-Privacy-Code' => 'premium_required',
        ]);
    }

    /**
     * Premium weddings the viewer can access as a linked partner.
     *
     * @return list<array{user_id: int, name: string, email: string|null, resources: list<string>}>
     */
    public function accessibleOwnersFor(User $viewer): array
    {
        $candidates = $this->linkedPartnerCandidates($viewer);
        $result = [];

        foreach ($candidates as $owner) {
            if (! $owner->isPremium()) {
                continue;
            }

            $resources = [];
            foreach (self::proResources() as $resource) {
                if ($this->canAccessProResource($owner, $viewer, $resource)) {
                    $resources[] = $resource;
                }
            }

            if ($resources === []) {
                continue;
            }

            $result[] = [
                'user_id' => $owner->id,
                'name' => $owner->name,
                'email' => $owner->email,
                'resources' => $resources,
            ];
        }

        return $result;
    }

    /**
     * @return list<User>
     */
    private function linkedPartnerCandidates(User $viewer): array
    {
        $ids = [];

        $directPartnerId = PrivacySettings::partnerUserId($viewer);
        if ($directPartnerId !== null && $directPartnerId !== $viewer->id) {
            $ids[$directPartnerId] = true;
        }

        // Reciprocal: owners who listed this viewer as partner.
        $ownersPointingHere = User::query()
            ->where('id', '!=', $viewer->id)
            ->where('privacy_settings->partner_user_id', $viewer->id)
            ->get(['id', 'name', 'email', 'is_premium', 'privacy_settings']);

        foreach ($ownersPointingHere as $owner) {
            $ids[$owner->id] = true;
        }

        if ($ids === []) {
            return [];
        }

        return User::query()
            ->whereIn('id', array_keys($ids))
            ->get(['id', 'name', 'email', 'is_premium', 'privacy_settings'])
            ->all();
    }
}
