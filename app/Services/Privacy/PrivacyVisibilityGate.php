<?php

namespace App\Services\Privacy;

use App\Models\User;
use App\Support\PrivacySettings;
use Symfony\Component\HttpKernel\Exception\HttpException;

class PrivacyVisibilityGate
{
    public const ResourceProfile = 'profile';

    public const ResourceWedding = 'wedding';

    public const ResourceGuestList = 'guest_list';

    public const ResourceBudget = 'budget';

    /**
     * @return 'self'|'couple'|'vendor'|'authenticated'|'guest'
     */
    public function viewerRole(User $owner, ?User $viewer): string
    {
        if ($viewer === null) {
            return 'guest';
        }

        if ($viewer->id === $owner->id) {
            return 'self';
        }

        if ($this->isLinkedPartner($owner, $viewer)) {
            return 'couple';
        }

        if ($this->isVendorActor($viewer)) {
            return 'vendor';
        }

        return 'authenticated';
    }

    public function isLinkedPartner(User $owner, User $viewer): bool
    {
        $ownerPartnerId = PrivacySettings::partnerUserId($owner);
        if ($ownerPartnerId !== null && $ownerPartnerId === $viewer->id) {
            return true;
        }

        // Reciprocal link: viewer also points to owner as partner.
        $viewerPartnerId = PrivacySettings::partnerUserId($viewer);

        return $viewerPartnerId !== null && $viewerPartnerId === $owner->id;
    }

    public function isVendorActor(User $viewer): bool
    {
        return method_exists($viewer, 'hasRole')
            && ($viewer->hasRole('vendor') || $viewer->hasRole('Vendor'));
    }

    public function canAppearInDirectory(User $owner): bool
    {
        $settings = PrivacySettings::forUser($owner);

        return (bool) $settings[PrivacySettings::ShowInDirectory]
            && $settings[PrivacySettings::ProfileVisibility] === 'public';
    }

    public function canVendorContact(User $owner): bool
    {
        return (bool) PrivacySettings::forUser($owner)[PrivacySettings::AllowVendorContact];
    }

    public function canViewProfile(User $owner, ?User $viewer): bool
    {
        return $this->canViewResource(
            $owner,
            $viewer,
            PrivacySettings::forUser($owner)[PrivacySettings::ProfileVisibility],
            allowPublic: true,
            allowVendors: false,
        );
    }

    public function canViewWedding(User $owner, ?User $viewer): bool
    {
        return $this->canViewResource(
            $owner,
            $viewer,
            PrivacySettings::forUser($owner)[PrivacySettings::WeddingVisibility],
            allowPublic: false,
            allowVendors: true,
        );
    }

    public function canViewGuestList(User $owner, ?User $viewer): bool
    {
        return $this->canViewResource(
            $owner,
            $viewer,
            PrivacySettings::forUser($owner)[PrivacySettings::GuestListVisibility],
            allowPublic: false,
            allowVendors: false,
        );
    }

    public function canViewBudget(User $owner, ?User $viewer): bool
    {
        return $this->canViewResource(
            $owner,
            $viewer,
            PrivacySettings::forUser($owner)[PrivacySettings::BudgetVisibility],
            allowPublic: false,
            allowVendors: false,
        );
    }

    public function assertCanViewProfile(User $owner, ?User $viewer): void
    {
        $this->assert($this->canViewProfile($owner, $viewer), 'Profil ini bersifat privat.');
    }

    public function assertCanViewWedding(User $owner, ?User $viewer): void
    {
        $this->assert($this->canViewWedding($owner, $viewer), 'Detail pernikahan ini tidak tersedia untuk Anda.');
    }

    public function assertCanViewGuestList(User $owner, ?User $viewer): void
    {
        $this->assert($this->canViewGuestList($owner, $viewer), 'Daftar tamu ini bersifat privat.');
    }

    public function assertCanViewBudget(User $owner, ?User $viewer): void
    {
        $this->assert($this->canViewBudget($owner, $viewer), 'Anggaran ini bersifat privat.');
    }

    public function assertCanVendorContact(User $owner): void
    {
        $this->assert($this->canVendorContact($owner), 'Pemilik akun tidak mengizinkan vendor menghubungi.');
    }

    public function assertCanAppearInDirectory(User $owner): void
    {
        $this->assert($this->canAppearInDirectory($owner), 'Profil tidak tampil di direktori.');
    }

    private function canViewResource(
        User $owner,
        ?User $viewer,
        string $visibility,
        bool $allowPublic,
        bool $allowVendors,
    ): bool {
        $role = $this->viewerRole($owner, $viewer);

        if ($role === 'self') {
            return true;
        }

        return match ($visibility) {
            'private' => false,
            'couple' => $role === 'couple',
            'public' => $allowPublic && in_array($role, ['couple', 'vendor', 'authenticated', 'guest'], true),
            'vendors' => $allowVendors && ($role === 'vendor' || $role === 'couple'),
            default => false,
        };
    }

    private function assert(bool $allowed, string $message): void
    {
        if ($allowed) {
            return;
        }

        throw new HttpException(403, $message, null, [
            'X-Privacy-Code' => 'privacy_forbidden',
        ]);
    }
}
