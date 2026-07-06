<?php

namespace App\Http\Controllers;

use App\Models\FamilyMember;
use App\Models\Guest;
use App\Models\VipGuest;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class TamuController extends Controller
{
    public function index(Request $request): View
    {
        $tab = $request->get('tab', 'umum');
        $search = $request->get('search', '');
        $rsvp = $request->get('rsvp', '');
        $userId = Auth::id();

        $filter = function ($query) use ($search, $rsvp) {
            if ($search) {
                $query->where('name', 'like', '%'.$search.'%');
            }
            if ($rsvp) {
                $query->where('rsvp_status', $rsvp);
            }
        };

        $guests = Guest::where('user_id', $userId)->tap($filter)->orderBy('name')->get();
        $family = FamilyMember::where('user_id', $userId)->tap($filter)->orderBy('no')->orderBy('name')->get();
        $vipList = VipGuest::where('user_id', $userId)->tap($filter)->orderBy('no')->orderBy('name')->get();

        $activeList = match ($tab) {
            'keluarga' => $family,
            'vip' => $vipList,
            default => $guests,
        };

        $rsvpSummary = [
            'hadir' => $activeList->where('rsvp_status', 'hadir')->count(),
            'tidak_hadir' => $activeList->where('rsvp_status', 'tidak_hadir')->count(),
            'menunggu' => $activeList->where('rsvp_status', 'menunggu')->count(),
        ];

        return view('tamu.index', compact('tab', 'search', 'rsvp', 'guests', 'family', 'vipList', 'rsvpSummary'));
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

        return redirect()->route('tamu', ['tab' => $tab])->with('success', 'Tamu berhasil ditambahkan.');
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

        return redirect()->route('tamu', ['tab' => $tab])->with('success', 'Tamu berhasil diperbarui.');
    }

    public function destroy(string $tab, int $id): RedirectResponse
    {
        $this->findRecord($tab, $id)->delete();

        return redirect()->route('tamu', ['tab' => $tab])->with('success', 'Tamu berhasil dihapus.');
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
