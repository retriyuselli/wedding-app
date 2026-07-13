<?php

namespace App\Http\Controllers;

use App\Models\FamilyMember;
use App\Models\Guest;
use App\Models\VipGuest;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Illuminate\View\View;

class TamuController extends Controller
{
    public function index(Request $request): View
    {
        $user = Auth::user();
        $weddingInfo = $user->weddingInfo;
        $events = $user->weddingEvents()->get();

        $status = $request->string('status')->toString() ?: 'all';
        $grup = $request->string('grup')->toString() ?: '';
        $kategori = $request->string('kategori')->toString() ?: '';
        $search = $request->string('q')->trim()->toString();
        $perPage = (int) $request->integer('per_page', 8);
        $perPage = in_array($perPage, [8, 10, 25, 50], true) ? $perPage : 8;

        $allGuests = $this->unifiedGuests($user->id);

        $summary = $this->buildSummary($allGuests);

        $filtered = $allGuests
            ->when($status !== 'all', fn (Collection $items) => $items->where('display_status', $status))
            ->when($grup !== '', fn (Collection $items) => $items->where('tab', $grup))
            ->when($kategori !== '', fn (Collection $items) => $items->where('kategori_key', $kategori))
            ->when($search !== '', function (Collection $items) use ($search): Collection {
                return $items->filter(fn (array $guest): bool => str_contains(
                    strtolower($guest['name']),
                    strtolower($search),
                ) || str_contains(strtolower($guest['kontak']), strtolower($search)));
            })
            ->values();

        $guests = $this->paginateCollection($filtered, $perPage, $request);

        $groupSummary = $this->buildGroupSummary($allGuests);

        $mainEvent = $events->firstWhere('jenis_acara', 'akad')
            ?? $events->sortByDesc('tgl_acara')->first();

        $unreadNotifications = $user->customerNotifications()
            ->where('is_unread', true)
            ->count();

        $statusTabs = [
            ['key' => 'all', 'label' => 'Semua Tamu'],
            ['key' => 'akan_datang', 'label' => 'Akan Datang'],
            ['key' => 'konfirmasi', 'label' => 'Konfirmasi'],
            ['key' => 'belum_konfirmasi', 'label' => 'Belum Konfirmasi'],
        ];

        $grupOptions = [
            '' => 'Semua Grup',
            'umum' => 'Tamu Umum',
            'keluarga' => 'Keluarga',
            'vip' => 'VIP',
        ];

        $kategoriOptions = collect(['' => 'Semua Kategori'])
            ->merge(collect(VipGuest::$kategoriOptions)->prepend('Keluarga', 'keluarga')->prepend('Regular', 'regular'));

        return view('tamu.index', [
            'guests' => $guests,
            'summary' => $summary,
            'groupSummary' => $groupSummary,
            'statusTabs' => $statusTabs,
            'grupOptions' => $grupOptions,
            'kategoriOptions' => $kategoriOptions,
            'activeStatus' => $status,
            'activeGrup' => $grup,
            'activeKategori' => $kategori,
            'search' => $search,
            'perPage' => $perPage,
            'coupleLabel' => $this->coupleLabel($weddingInfo, $user->name),
            'weddingDateLabel' => $mainEvent?->tgl_acara?->translatedFormat('d M Y'),
            'unreadNotifications' => $unreadNotifications,
        ]);
    }

    public function create(Request $request): View
    {
        $tab = $request->get('tab', 'umum');

        return view('tamu.create', compact('tab'));
    }

    public function store(Request $request): RedirectResponse
    {
        $tab = $request->input('tab', 'umum');

        $rules = [
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'rsvp_status' => ['required', 'in:menunggu,hadir,tidak_hadir'],
        ];

        if ($tab === 'umum') {
            $rules['email'] = ['nullable', 'email'];
            $rules['table_number'] = ['nullable', 'string', 'max:50'];
        }

        $request->validate($rules);

        $data = [
            'user_id' => Auth::id(),
            'name' => $request->name,
            'phone' => $request->phone ?: null,
            'rsvp_status' => $request->rsvp_status,
            'catatan' => $request->catatan ?: null,
        ];

        if ($tab === 'umum') {
            $data['email'] = $request->email ?: null;
            $data['table_number'] = $request->table_number ?: null;
            Guest::create($data);
        } elseif ($tab === 'keluarga') {
            $data['role'] = $request->role ?: null;
            $data['no'] = $request->no ?: null;
            FamilyMember::create($data);
        } else {
            $data['jabatan'] = $request->jabatan ?: null;
            $data['instansi'] = $request->instansi ?: null;
            $data['kategori'] = $request->kategori ?? 'vip';
            $data['no'] = $request->no ?: null;
            VipGuest::create($data);
        }

        return redirect()->route('tamu')->with('success', 'Tamu berhasil ditambahkan.');
    }

    public function edit(string $tab, int $id): View
    {
        $record = $this->findRecord($tab, $id);

        return view('tamu.edit', compact('tab', 'record'));
    }

    public function update(Request $request, string $tab, int $id): RedirectResponse
    {
        $rules = [
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'rsvp_status' => ['required', 'in:menunggu,hadir,tidak_hadir'],
        ];

        if ($tab === 'umum') {
            $rules['email'] = ['nullable', 'email'];
            $rules['table_number'] = ['nullable', 'string', 'max:50'];
        }

        $request->validate($rules);

        $data = [
            'name' => $request->name,
            'phone' => $request->phone ?: null,
            'rsvp_status' => $request->rsvp_status,
            'catatan' => $request->catatan ?: null,
        ];

        if ($tab === 'umum') {
            $data['email'] = $request->email ?: null;
            $data['table_number'] = $request->table_number ?: null;
        } elseif ($tab === 'keluarga') {
            $data['role'] = $request->role ?: null;
            $data['no'] = $request->no ?: null;
        } else {
            $data['jabatan'] = $request->jabatan ?: null;
            $data['instansi'] = $request->instansi ?: null;
            $data['kategori'] = $request->kategori ?? 'vip';
            $data['no'] = $request->no ?: null;
        }

        $this->findRecord($tab, $id)->update($data);

        return redirect()->route('tamu')->with('success', 'Tamu berhasil diperbarui.');
    }

    public function destroy(string $tab, int $id): RedirectResponse
    {
        $this->findRecord($tab, $id)->delete();

        return redirect()->route('tamu')->with('success', 'Tamu berhasil dihapus.');
    }

    public function updateRsvp(Request $request, string $tab, int $id): RedirectResponse
    {
        $request->validate(['rsvp_status' => ['required', 'in:menunggu,hadir,tidak_hadir']]);

        $this->findRecord($tab, $id)->update([
            'rsvp_status' => $request->rsvp_status,
            'rsvp_updated_by_name' => Auth::user()->name,
            'rsvp_updated_at' => now(),
        ]);

        return back();
    }

    /**
     * @return Collection<int, array{
     *     id: int,
     *     tab: string,
     *     name: string,
     *     initials: string,
     *     grup: string,
     *     kategori: string,
     *     kategori_key: string,
     *     kontak: string,
     *     phone: ?string,
     *     email: ?string,
     *     rsvp_status: string,
     *     display_status: string,
     *     display_status_label: string,
     *     jumlah: int,
     *     invitation_sent: bool
     * }>
     */
    private function unifiedGuests(int $userId): Collection
    {
        $guests = Guest::query()
            ->where('user_id', $userId)
            ->orderBy('no')
            ->orderBy('name')
            ->get()
            ->map(fn (Guest $guest): array => $this->normalizeRecord($guest, 'umum', 'Tamu Umum', 'Regular', 'regular'));

        $family = FamilyMember::query()
            ->where('user_id', $userId)
            ->orderBy('no')
            ->orderBy('name')
            ->get()
            ->map(fn (FamilyMember $member): array => $this->normalizeRecord(
                $member,
                'keluarga',
                'Keluarga',
                $member->role ?: 'Keluarga',
                'keluarga',
            ));

        $vip = VipGuest::query()
            ->where('user_id', $userId)
            ->orderBy('no')
            ->orderBy('name')
            ->get()
            ->map(fn (VipGuest $guest): array => $this->normalizeRecord(
                $guest,
                'vip',
                'VIP',
                VipGuest::$kategoriOptions[$guest->kategori] ?? $guest->kategori,
                $guest->kategori,
            ));

        return $guests->merge($family)->merge($vip)
            ->sortBy([
                fn (array $guest): int => (int) ($guest['no'] ?? PHP_INT_MAX),
                fn (array $guest): string => Str::lower($guest['name']),
            ])
            ->values();
    }

    /**
     * @return array{
     *     id: int,
     *     tab: string,
     *     name: string,
     *     initials: string,
     *     grup: string,
     *     kategori: string,
     *     kategori_key: string,
     *     kontak: string,
     *     phone: ?string,
     *     email: ?string,
     *     rsvp_status: string,
     *     display_status: string,
     *     display_status_label: string,
     *     jumlah: int,
     *     invitation_sent: bool
     * }
     */
    private function normalizeRecord(
        Model $record,
        string $tab,
        string $grup,
        string $kategori,
        string $kategoriKey,
    ): array {
        $phone = $record->phone ?? null;
        $email = $record->email ?? null;
        $displayStatus = $this->displayRsvpStatus($record->rsvp_status, $phone, $email);

        return [
            'id' => $record->id,
            'no' => $record->no ?? null,
            'tab' => $tab,
            'name' => $record->name,
            'initials' => $this->initials($record->name),
            'grup' => $grup,
            'kategori' => $kategori,
            'kategori_key' => $kategoriKey,
            'kontak' => $phone ?: ($email ?: '—'),
            'phone' => $phone,
            'email' => $email,
            'rsvp_status' => $record->rsvp_status,
            'display_status' => $displayStatus,
            'display_status_label' => $this->displayRsvpLabel($displayStatus),
            'jumlah' => 1,
            'invitation_sent' => (bool) ($phone || $email),
        ];
    }

    /**
     * @param  Collection<int, array<string, mixed>>  $guests
     * @return array{
     *     total: int,
     *     akan_datang: int,
     *     konfirmasi: int,
     *     belum_konfirmasi: int,
     *     undangan_terkirim: int,
     *     akan_datang_percent: int,
     *     konfirmasi_percent: int,
     *     belum_konfirmasi_percent: int,
     *     undangan_terkirim_percent: int
     * }
     */
    private function buildSummary(Collection $guests): array
    {
        $total = $guests->count();

        $akanDatang = $guests->where('display_status', 'akan_datang')->count();
        $konfirmasi = $guests->where('display_status', 'konfirmasi')->count();
        $belumKonfirmasi = $guests->where('display_status', 'belum_konfirmasi')->count();
        $undanganTerkirim = $guests->where('invitation_sent', true)->count();

        return [
            'total' => $total,
            'akan_datang' => $akanDatang,
            'konfirmasi' => $konfirmasi,
            'belum_konfirmasi' => $belumKonfirmasi,
            'undangan_terkirim' => $undanganTerkirim,
            'akan_datang_percent' => $total > 0 ? (int) round(($akanDatang / $total) * 100) : 0,
            'konfirmasi_percent' => $total > 0 ? (int) round(($konfirmasi / $total) * 100) : 0,
            'belum_konfirmasi_percent' => $total > 0 ? (int) round(($belumKonfirmasi / $total) * 100) : 0,
            'undangan_terkirim_percent' => $total > 0 ? (int) round(($undanganTerkirim / $total) * 100) : 0,
        ];
    }

    /**
     * @param  Collection<int, array<string, mixed>>  $guests
     * @return Collection<int, array{label: string, count: int, percent: int}>
     */
    private function buildGroupSummary(Collection $guests): Collection
    {
        $total = max($guests->count(), 1);

        return collect([
            ['key' => 'Keluarga', 'label' => 'Keluarga'],
            ['key' => 'Tamu Umum', 'label' => 'Teman'],
            ['key' => 'VIP', 'label' => 'Rekan Kerja'],
        ])->map(function (array $group) use ($guests, $total): array {
            $count = $guests->where('grup', $group['key'])->count();

            return [
                'label' => $group['label'],
                'count' => $count,
                'percent' => (int) round(($count / $total) * 100),
            ];
        });
    }

    /**
     * @param  Collection<int, array<string, mixed>>  $items
     */
    private function paginateCollection(Collection $items, int $perPage, Request $request): LengthAwarePaginator
    {
        $page = LengthAwarePaginator::resolveCurrentPage();
        $total = $items->count();
        $results = $items->slice(($page - 1) * $perPage, $perPage)->values();

        return new LengthAwarePaginator(
            $results,
            $total,
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );
    }

    private function displayRsvpStatus(string $rsvpStatus, ?string $phone, ?string $email): string
    {
        if ($rsvpStatus === 'hadir') {
            return 'akan_datang';
        }

        if ($rsvpStatus === 'tidak_hadir') {
            return 'tidak_hadir';
        }

        if ($phone || $email) {
            return 'konfirmasi';
        }

        return 'belum_konfirmasi';
    }

    private function displayRsvpLabel(string $displayStatus): string
    {
        return match ($displayStatus) {
            'akan_datang' => 'Akan Datang',
            'konfirmasi' => 'Konfirmasi',
            'tidak_hadir' => 'Tidak Hadir',
            default => 'Belum Konfirmasi',
        };
    }

    private function initials(string $name): string
    {
        $parts = preg_split('/\s+/', trim($name)) ?: [];

        if (count($parts) >= 2) {
            return strtoupper(substr($parts[0], 0, 1).substr($parts[1], 0, 1));
        }

        return strtoupper(substr($name, 0, 2));
    }

    private function coupleLabel(?object $weddingInfo, string $fallbackName): string
    {
        if ($weddingInfo?->groom_name && $weddingInfo?->bride_name) {
            return "{$weddingInfo->groom_name} & {$weddingInfo->bride_name}";
        }

        return $fallbackName;
    }

    private function findRecord(string $tab, int $id): Model
    {
        $model = match ($tab) {
            'keluarga' => FamilyMember::class,
            'vip' => VipGuest::class,
            default => Guest::class,
        };

        return $model::where('user_id', Auth::id())->findOrFail($id);
    }
}
