<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Support\HelpContent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HelpCenterController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $locale = $request->string('locale', 'id')->toString();

        return response()->json([
            'data' => [
                'support_email' => HelpContent::supportEmail(),
                'support_whatsapp' => HelpContent::supportWhatsapp(),
                'support_whatsapp_url' => HelpContent::supportWhatsappUrl(),
                'app_version' => HelpContent::appVersion(),
                'last_updated_label' => HelpContent::lastUpdatedLabel(),
                'faqs' => HelpContent::faqs(),
                'topics' => HelpContent::topics(),
                'popular_guides' => HelpContent::popularGuides(),
                'contact_methods' => HelpContent::contactMethods(),
                'locale' => in_array($locale, ['id', 'en'], true) ? $locale : 'id',
            ],
        ]);
    }
}
