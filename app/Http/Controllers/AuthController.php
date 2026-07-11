<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\SocialAuthenticationService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class AuthController extends Controller
{
    public function __construct(
        private SocialAuthenticationService $socialAuthenticationService,
    ) {}

    public function showLogin(): View
    {
        return view('auth.login', $this->socialAuthViewData());
    }

    public function login(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'min:6'],
        ]);

        if (! Auth::attempt($credentials, $request->boolean('remember'))) {
            return back()->withErrors(['email' => 'Email atau password salah.'])->withInput();
        }

        $request->session()->regenerate();

        return redirect()->intended(route('dashboard'));
    }

    public function showRegister(): View
    {
        return view('auth.register', $this->socialAuthViewData());
    }

    public function showResetPassword(Request $request, string $token): View
    {
        return view('auth.reset-password', [
            'email' => $request->query('email'),
            'token' => $token,
        ]);
    }

    public function register(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'min:8', 'confirmed'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);

        Auth::login($user);
        $request->session()->regenerate();

        return redirect()->route('dashboard');
    }

    public function resetPassword(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string'],
            'email' => ['required', 'email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $status = Password::reset(
            $data,
            function (User $user, string $password): void {
                $user->forceFill([
                    'password' => Hash::make($password),
                    'remember_token' => Str::random(60),
                ])->save();
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return back()->withErrors(['email' => __($status)])->withInput();
        }

        return redirect()
            ->route('login')
            ->with('status', 'Kata sandi berhasil diatur ulang. Silakan masuk dengan kata sandi baru.');
    }

    public function google(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'credential' => ['required', 'string'],
        ]);

        try {
            $user = $this->socialAuthenticationService->userFromGoogleIdToken($data['credential']);
        } catch (ValidationException $exception) {
            return back()->withErrors($exception->errors());
        }

        return $this->loginSocialUser($request, $user);
    }

    public function apple(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'identity_token' => ['required', 'string'],
            'full_name' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
        ]);

        try {
            $user = $this->socialAuthenticationService->userFromAppleIdentityToken(
                $data['identity_token'],
                $data['full_name'] ?? null,
                $data['email'] ?? null,
            );
        } catch (ValidationException $exception) {
            return back()->withErrors($exception->errors());
        }

        return $this->loginSocialUser($request, $user);
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }

    /**
     * @return array<string, mixed>
     */
    private function socialAuthViewData(): array
    {
        return [
            'googleEnabled' => filled(config('services.google.client_id')),
            'appleEnabled' => filled(config('services.apple.client_id')),
            'googleClientId' => config('services.google.client_id'),
            'appleClientId' => config('services.apple.client_id'),
            'appleRedirectUri' => route('login'),
        ];
    }

    private function loginSocialUser(Request $request, User $user): RedirectResponse
    {
        Auth::login($user, true);
        $request->session()->regenerate();

        return redirect()->intended(route('dashboard'));
    }
}
