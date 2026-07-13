<?php

namespace App\Support;

use App\Models\User;

class PrivacySettings
{
    public const ProfileVisibility = 'profile_visibility';

    public const WeddingVisibility = 'wedding_visibility';

    public const GuestListVisibility = 'guest_list_visibility';

    public const BudgetVisibility = 'budget_visibility';

    public const ShowInDirectory = 'show_in_directory';

    public const AllowVendorContact = 'allow_vendor_contact';

    /**
     * @return array<string, mixed>
     */
    public static function defaults(): array
    {
        return [
            self::ProfileVisibility => 'private',
            self::WeddingVisibility => 'couple',
            self::GuestListVisibility => 'private',
            self::BudgetVisibility => 'private',
            self::ShowInDirectory => false,
            self::AllowVendorContact => true,
        ];
    }

    /**
     * @return array<string, array<int, string>>
     */
    public static function optionSets(): array
    {
        return [
            self::ProfileVisibility => ['private', 'couple', 'public'],
            self::WeddingVisibility => ['private', 'couple', 'vendors'],
            self::GuestListVisibility => ['private', 'couple'],
            self::BudgetVisibility => ['private', 'couple'],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function forUser(User $user): array
    {
        $stored = is_array($user->privacy_settings) ? $user->privacy_settings : [];

        return array_merge(self::defaults(), $stored);
    }

    /**
     * @param  array<string, mixed>  $input
     * @return array<string, mixed>
     */
    public static function validatedPayload(array $input): array
    {
        $defaults = self::defaults();
        $options = self::optionSets();
        $payload = [];

        foreach ($defaults as $key => $default) {
            if (! array_key_exists($key, $input)) {
                continue;
            }

            $value = $input[$key];

            if (isset($options[$key])) {
                if (! in_array($value, $options[$key], true)) {
                    continue;
                }

                $payload[$key] = $value;

                continue;
            }

            $payload[$key] = (bool) $value;
        }

        return $payload;
    }
}
