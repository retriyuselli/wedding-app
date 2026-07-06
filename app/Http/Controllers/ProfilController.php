<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

class ProfilController extends Controller
{
    public function index(): View
    {
        $user = Auth::user();
        $info = $user->weddingInfo;

        return view('profil.index', compact('user', 'info'));
    }

    public function updateProfile(Request $request): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email,'.Auth::id()],
            'whatsapp' => ['nullable', 'string', 'max:20'],
        ]);

        Auth::user()->update([
            'name' => $request->name,
            'email' => $request->email,
            'whatsapp' => $request->whatsapp ?: null,
        ]);

        return back()->with('success_profile', 'Profil berhasil disimpan.');
    }

    public function updateWeddingInfo(Request $request): RedirectResponse
    {
        $request->validate([
            'groom_name' => ['nullable', 'string', 'max:255'],
            'bride_name' => ['nullable', 'string', 'max:255'],
            'budaya' => ['nullable', 'string', 'max:100'],
        ]);

        Auth::user()->weddingInfo()->updateOrCreate(
            ['user_id' => Auth::id()],
            [
                'groom_name' => $request->groom_name ?: null,
                'bride_name' => $request->bride_name ?: null,
                'budaya' => $request->budaya ?: null,
            ]
        );

        return back()->with('success_wedding', 'Info pernikahan berhasil disimpan.');
    }

    public function updatePassword(Request $request): RedirectResponse
    {
        $request->validate([
            'current_password' => ['required'],
            'new_password' => ['required', 'min:8', 'confirmed'],
        ], [], [
            'current_password' => 'password saat ini',
            'new_password' => 'password baru',
        ]);

        if (! Hash::check($request->current_password, Auth::user()->password)) {
            return back()->withErrors(['current_password' => 'Password saat ini tidak sesuai.']);
        }

        Auth::user()->update(['password' => Hash::make($request->new_password)]);

        return back()->with('success_password', 'Password berhasil diubah.');
    }
}
