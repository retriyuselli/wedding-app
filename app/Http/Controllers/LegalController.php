<?php

namespace App\Http\Controllers;

use App\Support\PrivacyPolicyContent;
use App\Support\TermsOfServiceContent;
use Illuminate\View\View;

class LegalController extends Controller
{
    public function privacyPolicy(): View
    {
        return $this->legalView('legal.privacy-policy', PrivacyPolicyContent::class);
    }

    public function termsOfService(): View
    {
        return $this->legalView('legal.terms-of-service', TermsOfServiceContent::class);
    }

    /**
     * @param  class-string<PrivacyPolicyContent|TermsOfServiceContent>  $contentClass
     */
    private function legalView(string $view, string $contentClass): View
    {
        return view($view, [
            'lastUpdated' => $contentClass::lastUpdated(),
            'introduction' => $contentClass::introduction(),
            'sections' => $contentClass::sections(),
            'contactEmail' => config('wedding.brand.contact_email'),
            'websiteUrl' => config('wedding.brand.website_url'),
            'websiteDisplay' => config('wedding.brand.website_display'),
            'developer' => config('wedding.brand.developer'),
            'appName' => config('wedding.brand.name'),
        ]);
    }
}
