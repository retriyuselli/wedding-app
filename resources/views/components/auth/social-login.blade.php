@props([
    'dividerText' => 'atau masuk dengan',
    'googleEnabled' => false,
    'appleEnabled' => false,
    'googleClientId' => null,
    'appleClientId' => null,
    'appleRedirectUri' => '',
])

@if ($googleEnabled || $appleEnabled)
    <div class="my-6 flex items-center gap-3">
        <div class="h-px flex-1 bg-gray-200"></div>
        <span class="text-xs text-gray-400">{{ $dividerText }}</span>
        <div class="h-px flex-1 bg-gray-200"></div>
    </div>

    <div @class([
        'grid gap-3',
        $googleEnabled && $appleEnabled ? 'grid-cols-2' : 'grid-cols-1',
    ])>
        @if ($googleEnabled)
            <button
                type="button"
                id="google-signin-button"
                class="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white text-sm font-medium text-gray-700 transition hover:bg-gray-50"
            >
                <svg class="h-4 w-4" viewBox="0 0 24 24" aria-hidden="true">
                    <path fill="#EA4335" d="M12 10.2v3.9h5.5c-.24 1.3-1.7 3.8-5.5 3.8-3.3 0-6-2.7-6-6s2.7-6 6-6c1.9 0 3.2.8 3.9 1.5l2.7-2.6C17.5 3.2 15 2.2 12 2.2 6.8 2.2 2.5 6.5 2.5 11.7S6.8 21.2 12 21.2c6.9 0 8.6-4.8 8.6-7.2 0-.5 0-.9-.1-1.2H12z"/>
                </svg>
                Google
            </button>
        @endif

        @if ($appleEnabled)
            <button
                type="button"
                id="apple-signin-button"
                class="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white text-sm font-medium text-gray-700 transition hover:bg-gray-50"
            >
                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    <path d="M16.365 1.43c0 1.14-.46 2.23-1.28 3.03-.84.82-2.04 1.28-3.27 1.22-.04-1.1.48-2.22 1.28-3.02.86-.84 2.1-1.3 3.27-1.23ZM20.8 17.13c-.57 1.3-.85 1.88-1.58 3.03-1.03 1.58-2.48 3.55-4.28 3.56-1.6.01-2.01-1.03-4.18-1.02-2.17.01-2.64 1.04-4.24 1.02-1.8-.01-3.17-1.72-4.2-3.3-2.88-4.4-3.18-9.56-1.4-12.3 1.27-1.95 3.28-3.1 5.18-3.1 1.93 0 3.14 1.03 4.74 1.03 1.53 0 2.46-1.03 4.66-1.03 1.67 0 3.44.9 4.7 2.46-4.13 2.24-3.46 8.07.6 9.65Z"/>
                </svg>
                Apple
            </button>
        @endif
    </div>

    <form id="google-auth-form" method="POST" action="{{ route('auth.google') }}" class="hidden">
        @csrf
        <input type="hidden" name="credential" id="google-credential">
    </form>

    <form id="apple-auth-form" method="POST" action="{{ route('auth.apple') }}" class="hidden">
        @csrf
        <input type="hidden" name="identity_token" id="apple-identity-token">
        <input type="hidden" name="full_name" id="apple-full-name">
        <input type="hidden" name="email" id="apple-email">
    </form>

    @push('scripts')
        @if ($googleEnabled)
            <script src="https://accounts.google.com/gsi/client" async defer></script>
        @endif

        @if ($appleEnabled)
            <script src="https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js" async defer></script>
        @endif

        <script>
            document.addEventListener('DOMContentLoaded', () => {
                const googleClientId = @json($googleClientId);
                const appleClientId = @json($appleClientId);
                const appleRedirectUri = @json($appleRedirectUri);

                const submitGoogleCredential = (credential) => {
                    const input = document.getElementById('google-credential');
                    const form = document.getElementById('google-auth-form');

                    if (!input || !form || !credential) {
                        return;
                    }

                    input.value = credential;
                    form.submit();
                };

                const initializeGoogleSignIn = () => {
                    if (!googleClientId || !window.google?.accounts?.id) {
                        return;
                    }

                    window.google.accounts.id.initialize({
                        client_id: googleClientId,
                        callback: (response) => submitGoogleCredential(response.credential),
                        ux_mode: 'popup',
                        auto_select: false,
                    });

                    const googleButton = document.getElementById('google-signin-button');

                    if (googleButton) {
                        googleButton.addEventListener('click', () => {
                            window.google.accounts.id.prompt();
                        });
                    }
                };

                const initializeAppleSignIn = () => {
                    if (!appleClientId || !window.AppleID?.auth) {
                        return;
                    }

                    window.AppleID.auth.init({
                        clientId: appleClientId,
                        scope: 'name email',
                        redirectURI: appleRedirectUri,
                        usePopup: true,
                    });

                    const appleButton = document.getElementById('apple-signin-button');

                    if (!appleButton) {
                        return;
                    }

                    appleButton.addEventListener('click', async () => {
                        try {
                            const response = await window.AppleID.auth.signIn();
                            const form = document.getElementById('apple-auth-form');
                            const identityTokenInput = document.getElementById('apple-identity-token');
                            const fullNameInput = document.getElementById('apple-full-name');
                            const emailInput = document.getElementById('apple-email');

                            if (!form || !identityTokenInput || !response?.authorization?.id_token) {
                                return;
                            }

                            identityTokenInput.value = response.authorization.id_token;

                            const appleUser = response.user ?? null;
                            const givenName = appleUser?.name?.firstName ?? '';
                            const familyName = appleUser?.name?.lastName ?? '';
                            const fullName = [givenName, familyName].filter(Boolean).join(' ').trim();

                            if (fullNameInput) {
                                fullNameInput.value = fullName;
                            }

                            if (emailInput) {
                                emailInput.value = appleUser?.email ?? '';
                            }

                            form.submit();
                        } catch (error) {
                            if (error?.error !== 'popup_closed_by_user') {
                                console.error('Apple Sign In failed', error);
                            }
                        }
                    });
                };

                const waitForProvider = (check, initialize, attempts = 0) => {
                    if (check()) {
                        initialize();

                        return;
                    }

                    if (attempts >= 40) {
                        return;
                    }

                    window.setTimeout(() => waitForProvider(check, initialize, attempts + 1), 150);
                };

                if (googleClientId) {
                    waitForProvider(
                        () => window.google?.accounts?.id,
                        initializeGoogleSignIn,
                    );
                }

                if (appleClientId) {
                    waitForProvider(
                        () => window.AppleID?.auth,
                        initializeAppleSignIn,
                    );
                }
            });
        </script>
    @endpush
@endif
