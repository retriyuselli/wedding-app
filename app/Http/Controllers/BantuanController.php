<?php

namespace App\Http\Controllers;

use App\Support\HelpContent;
use Illuminate\Http\Request;
use Illuminate\View\View;

class BantuanController extends Controller
{
    public function index(Request $request): View
    {
        $user = $request->user();
        $info = $user->weddingInfo;
        $events = $user->weddingEvents()->get();
        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->filter(fn ($event) => $event->tgl_acara?->isFuture())->sortBy('tgl_acara')->first()
            ?? $events->sortByDesc('tgl_acara')->first();

        $search = trim($request->string('q')->toString());
        $faqs = collect(HelpContent::faqs());

        if ($search !== '') {
            $query = strtolower($search);
            $faqs = $faqs->filter(fn (array $faq): bool => str_contains(strtolower($faq['question']), $query)
                || str_contains(strtolower($faq['answer']), $query));
        }

        return view('bantuan.index', [
            'coupleLabel' => $this->coupleLabel($info, $user->name),
            'weddingDateLabel' => $mainEvent?->tgl_acara?->translatedFormat('d F Y'),
            'unreadNotifications' => $user->customerNotifications()->where('is_unread', true)->count(),
            'search' => $search,
            'faqs' => $faqs->values(),
            'topics' => HelpContent::topics(),
            'popularGuides' => HelpContent::popularGuides(),
            'contactMethods' => HelpContent::contactMethods(),
            'supportEmail' => HelpContent::supportEmail(),
            'appVersion' => HelpContent::appVersion(),
            'lastUpdatedLabel' => HelpContent::lastUpdatedLabel(),
        ]);
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }
}
