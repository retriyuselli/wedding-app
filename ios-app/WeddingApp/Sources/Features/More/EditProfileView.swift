import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore

    @State private var name = ""
    @State private var whatsapp = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var email: String {
        session.currentUser?.email ?? ""
    }

    private var avatarURL: URL? {
        guard let urlString = session.currentUser?.avatarUrl,
              !urlString.isEmpty else {
            return nil
        }

        return URL(string: urlString)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    profilePhotoCard

                    formSection(title: L10n.Profile.accountSection) {
                        VStack(spacing: 10) {
                            inputRow(icon: "person.fill", placeholder: L10n.Profile.namePlaceholder, text: $name)

                            HStack(spacing: 12) {
                                fieldIcon("envelope.fill")

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(email.isEmpty ? L10n.Profile.emailUnavailable : email)
                                        .font(AppFont.regular(14))
                                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                                    Text(L10n.Profile.emailLocked)
                                        .font(AppFont.regular(11))
                                        .foregroundStyle(AppTheme.ink.opacity(0.4))
                                }

                                Spacer(minLength: 0)

                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppTheme.ink.opacity(0.25))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(fieldBackground)
                        }
                    }

                    formSection(title: L10n.Profile.contactSection) {
                        inputRow(
                            icon: "phone.fill",
                            placeholder: L10n.Profile.whatsappPlaceholder,
                            text: $whatsapp,
                            keyboard: .phonePad
                        )
                    }

                    infoCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) { saveButton }
        .onAppear { populateIfNeeded() }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.72))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.86), in: Circle())
                    .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 4) {
                Text(L10n.Profile.title)
                    .font(AppFont.medium(18))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.Profile.subtitle)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Color.clear.frame(width: 42, height: 42)
        }
        .padding(.bottom, 4)
    }

    private var profilePhotoCard: some View {
        HStack(spacing: 16) {
            Group {
                if let avatarURL {
                    AsyncImage(url: avatarURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            placeholderAvatar
                        }
                    }
                } else {
                    placeholderAvatar
                }
            }
            .frame(width: 78, height: 78)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(AppTheme.gold.opacity(0.5), lineWidth: 1.5)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(name.isEmpty ? L10n.Profile.nameEmpty : name)
                    .font(AppFont.medium(17))
                    .foregroundStyle(AppTheme.sageDark)
                    .lineLimit(2)

                Text(L10n.Profile.photoNote)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var placeholderAvatar: some View {
        Image("CouplePortrait")
            .resizable()
            .scaledToFill()
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.gold)

            Text(L10n.Profile.info)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppTheme.lightSage.opacity(0.45), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)

            VStack(spacing: 10) {
                content()
            }
            .padding(14)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
        }
    }

    private func inputRow(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            fieldIcon(icon)

            TextField(placeholder, text: text)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .keyboardType(keyboard)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(fieldBackground)
    }

    private func fieldIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(AppTheme.ink.opacity(0.45))
            .frame(width: 36, height: 36)
            .background(AppTheme.mist.opacity(0.65), in: Circle())
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(AppTheme.lightSage.opacity(0.35))
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(L10n.Profile.save)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canSave ? AppTheme.sageDark : AppTheme.sageDark.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canSave || isLoading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func populateIfNeeded() {
        guard let user = session.currentUser else {
            return
        }

        name = user.name
        whatsapp = user.whatsapp ?? ""
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWhatsapp = whatsapp.trimmingCharacters(in: .whitespacesAndNewlines)

        var payload: [String: Any] = [
            "name": trimmedName,
        ]

        if !trimmedWhatsapp.isEmpty {
            payload["whatsapp"] = trimmedWhatsapp
        }

        do {
            let response: UserResponse = try await APIClient.shared.request(
                "auth/profile",
                method: "PUT",
                json: payload
            )
            session.currentUser = response.user
            dismiss()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
