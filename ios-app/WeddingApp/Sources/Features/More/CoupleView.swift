import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct CoupleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared
    @ObservedObject private var photoStore = CouplePhotoStore.shared

    @State private var brideName = ""
    @State private var brideFullName = ""
    @State private var bridePhone = ""
    @State private var brideFatherName = ""
    @State private var brideMotherName = ""
    @State private var groomName = ""
    @State private var groomFullName = ""
    @State private var groomPhone = ""
    @State private var groomFatherName = ""
    @State private var groomMotherName = ""
    @State private var budaya = ""
    @State private var customBudaya = ""
    @State private var couplePhotoURL: URL?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoPreview: UIImage?
    @State private var photoFileData: Data?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var photoSizeWarning: String?
    @State private var showPaywall = false
    @State private var showRemovePhotoConfirm = false
    @State private var isRemovingPhoto = false

    private var isPremium: Bool {
        premium.isPremium(user: session.currentUser)
    }

    private var couplePreview: String {
        let bride = brideName.trimmingCharacters(in: .whitespacesAndNewlines)
        let groom = groomName.trimmingCharacters(in: .whitespacesAndNewlines)

        if bride.isEmpty && groom.isEmpty {
            return L10n.Couple.nameEmpty
        }
        if bride.isEmpty { return groom }
        if groom.isEmpty { return bride }
        return "\(bride) & \(groom)"
    }

    /// Prefer local pick / shared store (same source as Beranda), then remote URL.
    private var displayedCouplePhoto: UIImage? {
        photoPreview ?? photoStore.previewImage
    }

    private var hasCouplePhoto: Bool {
        displayedCouplePhoto != nil || couplePhotoURL != nil
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Couple.title,
                        subtitle: L10n.Couple.subtitle
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    couplePreviewCard
                    photoUploadSection

                    MoreFormSection(title: L10n.Couple.brideSection) {
                        MoreInputRow(icon: "person.fill", placeholder: L10n.Couple.brideNicknamePlaceholder, text: $brideName)
                        MoreInputRow(icon: "person.text.rectangle", placeholder: L10n.Couple.brideFullNamePlaceholder, text: $brideFullName)
                        MoreInputRow(icon: "phone.fill", placeholder: L10n.Couple.phonePlaceholder, text: $bridePhone, keyboard: .phonePad)
                        MoreInputRow(icon: "figure.stand", placeholder: L10n.Couple.fatherPlaceholder, text: $brideFatherName)
                        MoreInputRow(icon: "figure.stand.dress", placeholder: L10n.Couple.motherPlaceholder, text: $brideMotherName)
                    }

                    MoreFormSection(title: L10n.Couple.groomSection) {
                        MoreInputRow(icon: "person.fill", placeholder: L10n.Couple.groomNicknamePlaceholder, text: $groomName)
                        MoreInputRow(icon: "person.text.rectangle", placeholder: L10n.Couple.groomFullNamePlaceholder, text: $groomFullName)
                        MoreInputRow(icon: "phone.fill", placeholder: L10n.Couple.phonePlaceholder, text: $groomPhone, keyboard: .phonePad)
                        MoreInputRow(icon: "figure.stand", placeholder: L10n.Couple.fatherPlaceholder, text: $groomFatherName)
                        MoreInputRow(icon: "figure.stand.dress", placeholder: L10n.Couple.motherPlaceholder, text: $groomMotherName)
                    }

                    MoreFormSection(title: L10n.Couple.cultureSection) {
                        CultureChipGrid(selected: $budaya, customText: $customBudaya)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .premiumContentLock(isPremium: isPremium, showPaywall: $showPaywall)
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            if isPremium {
                MorePrimaryButton(
                    title: L10n.Couple.save,
                    isLoading: isLoading,
                    isEnabled: canSave,
                    action: { Task { await save() } }
                )
            }
        }
        .task { await load() }
        .onChange(of: selectedPhotoItem) { _, item in
            Task { await loadSelectedPhoto(item) }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onUnlocked: {
                Task { await load() }
            })
            .environmentObject(session)
        }
        .confirmationDialog(
            L10n.Couple.photoRemoveConfirmTitle,
            isPresented: $showRemovePhotoConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Couple.photoRemove, role: .destructive) {
                Task { await removeCouplePhoto() }
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(L10n.Couple.photoRemoveConfirmMessage)
        }
    }

    private var photoPickerLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "photo.badge.plus")
            Text(displayedCouplePhoto == nil && couplePhotoURL == nil
                  ? L10n.Couple.photoUpload
                  : L10n.Couple.photoChange)
        }
        .font(AppFont.medium(14))
        .foregroundStyle(AppTheme.sageDark)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.nestedGlassFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var resolvedBudaya: String {
        CultureSelection.resolvedValue(selected: budaya, custom: customBudaya)
    }

    private var couplePreviewCard: some View {
        HStack(spacing: 14) {
            couplePhotoThumb(size: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(couplePreview)
                    .font(AppFont.medium(18))
                    .foregroundStyle(AppTheme.sageDark)
                    .lineLimit(2)

                Text(resolvedBudaya.isEmpty ? L10n.Couple.cultureEmpty : resolvedBudaya)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .premiumListRow(cornerRadius: 20)
    }

    private var photoUploadSection: some View {
        MoreFormSection(title: L10n.Couple.photoSection) {
            VStack(spacing: 12) {
                couplePhotoThumb(size: 112)

                if PremiumGate.allows(session) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        photoPickerLabel
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        showPaywall = true
                    } label: {
                        photoPickerLabel
                    }
                    .buttonStyle(.plain)
                }

                if hasCouplePhoto {
                    Button {
                        showRemovePhotoConfirm = true
                    } label: {
                        HStack(spacing: 8) {
                            if isRemovingPhoto {
                                ProgressView()
                                    .tint(Color.red.opacity(0.85))
                            } else {
                                Image(systemName: "trash")
                                Text(L10n.Couple.photoRemove)
                            }
                        }
                        .font(AppFont.medium(14))
                        .foregroundStyle(Color.red.opacity(0.85))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isRemovingPhoto || isLoading)
                }

                Text(L10n.Couple.photoHint)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.inkMuted(0.72))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let photoSizeWarning {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(.orange)
                        Text(photoSizeWarning)
                            .font(AppFont.regular(12))
                            .foregroundStyle(Color.red.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private func couplePhotoThumb(size: CGFloat) -> some View {
        Group {
            if let displayedCouplePhoto {
                Image(uiImage: displayedCouplePhoto)
                    .resizable()
                    .scaledToFill()
            } else if let couplePhotoURL {
                DownsampledAsyncImage(url: couplePhotoURL, maxPixelSize: size * 2) {
                    placeholderPhoto
                }
            } else {
                placeholderPhoto
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(AppTheme.iconChipStroke, lineWidth: 1)
        }
    }

    private var placeholderPhoto: some View {
        Image("CouplePortrait")
            .resizable()
            .scaledToFill()
    }

    private var canSave: Bool {
        !brideName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !groomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || photoFileData != nil
            || photoStore.pendingUploadData != nil
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        restorePendingPhotoIfNeeded()

        do {
            let envelope: Envelope<WeddingInfo> = try await APIClient.shared.request("wedding-info")
            apply(envelope.data)
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    /// Keep an unsaved pick visible after navigating away (Beranda already reads the same store).
    private func restorePendingPhotoIfNeeded() {
        if photoPreview == nil, let stored = photoStore.previewImage {
            photoPreview = stored
        }
        if photoFileData == nil, let pending = photoStore.pendingUploadData {
            photoFileData = pending
        }
    }

    private func apply(_ data: WeddingInfo) {
        brideName = data.brideName ?? ""
        brideFullName = data.brideFullName ?? ""
        bridePhone = data.bridePhone ?? ""
        brideFatherName = data.brideFatherName ?? ""
        brideMotherName = data.brideMotherName ?? ""
        groomName = data.groomName ?? ""
        groomFullName = data.groomFullName ?? ""
        groomPhone = data.groomPhone ?? ""
        groomFatherName = data.groomFatherName ?? ""
        groomMotherName = data.groomMotherName ?? ""
        CultureSelection.applyLoaded(data.budaya, selected: &budaya, custom: &customBudaya)
        if let urlString = data.couplePhotoUrl, let url = URL(string: urlString) {
            couplePhotoURL = url
        } else {
            couplePhotoURL = nil
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let saved: WeddingInfo
            let uploadData = photoFileData ?? photoStore.pendingUploadData
            if let uploadData {
                let envelope: Envelope<WeddingInfo> = try await APIClient.shared.uploadMultipart(
                    "wedding-info",
                    method: "POST",
                    fields: textFieldsForMultipart(),
                    fileFieldName: "couple_photo",
                    fileName: "couple.jpg",
                    mimeType: "image/jpeg",
                    fileData: uploadData
                )
                saved = envelope.data
                self.photoFileData = nil
                self.selectedPhotoItem = nil
                photoStore.clearPendingUpload()
                MediaImageCache.invalidateAll()
            } else {
                let envelope: Envelope<WeddingInfo> = try await APIClient.shared.request(
                    "wedding-info",
                    method: "PUT",
                    json: textPayload()
                )
                saved = envelope.data
            }

            apply(saved)
            if let preview = photoPreview ?? photoStore.previewImage, saved.couplePhotoUrl != nil {
                // Keep shared preview so Beranda + Pasangan stay in sync; remote cache was invalidated above.
                photoStore.setPreview(preview)
            }
            NotificationCenter.default.post(name: .weddingInfoDidChange, object: nil)
            dismiss()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    private func removeCouplePhoto() async {
        isRemovingPhoto = true
        errorMessage = nil
        photoSizeWarning = nil
        defer { isRemovingPhoto = false }

        // Local-only selection (not yet saved): clear without API call.
        if photoFileData != nil
            || photoStore.pendingUploadData != nil
            || (displayedCouplePhoto != nil && couplePhotoURL == nil) {
            selectedPhotoItem = nil
            photoPreview = nil
            photoFileData = nil
            photoStore.clear()
            return
        }

        do {
            let envelope: Envelope<WeddingInfo> = try await APIClient.shared.request(
                "wedding-info/photo",
                method: "DELETE"
            )
            apply(envelope.data)
            selectedPhotoItem = nil
            photoPreview = nil
            photoFileData = nil
            photoStore.clear()
            MediaImageCache.invalidateAll()
            NotificationCenter.default.post(name: .weddingInfoDidChange, object: nil)
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    private func textPayload() -> [String: Any] {
        var payload: [String: Any] = [:]
        func put(_ key: String, _ value: String) {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            payload[key] = trimmed.isEmpty ? NSNull() : trimmed
        }
        put("bride_name", brideName)
        put("bride_full_name", brideFullName)
        put("bride_phone", bridePhone)
        put("bride_father_name", brideFatherName)
        put("bride_mother_name", brideMotherName)
        put("groom_name", groomName)
        put("groom_full_name", groomFullName)
        put("groom_phone", groomPhone)
        put("groom_father_name", groomFatherName)
        put("groom_mother_name", groomMotherName)
        put("budaya", resolvedBudaya)
        return payload
    }

    private func textFieldsForMultipart() -> [String: String] {
        func value(_ text: String) -> String {
            text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return [
            "bride_name": value(brideName),
            "bride_full_name": value(brideFullName),
            "bride_phone": value(bridePhone),
            "bride_father_name": value(brideFatherName),
            "bride_mother_name": value(brideMotherName),
            "groom_name": value(groomName),
            "groom_full_name": value(groomFullName),
            "groom_phone": value(groomPhone),
            "groom_father_name": value(groomFatherName),
            "groom_mother_name": value(groomMotherName),
            "budaya": value(resolvedBudaya),
        ]
    }

    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let picked = try await item.loadTransferable(type: CouplePickedImage.self),
                  let image = UIImage(data: picked.data) else {
                photoSizeWarning = nil
                errorMessage = L10n.Couple.photoReadError
                selectedPhotoItem = nil
                return
            }

            // Always compress under ~2 MB — no size warning for large originals.
            guard let compressed = CouplePhotoCompressor.jpegData(from: image) else {
                photoSizeWarning = nil
                errorMessage = L10n.Couple.photoReadError
                selectedPhotoItem = nil
                photoPreview = nil
                photoFileData = nil
                return
            }

            photoPreview = UIImage(data: compressed) ?? image
            photoFileData = compressed
            photoStore.setPreview(photoPreview, uploadData: compressed)
            photoSizeWarning = nil
            errorMessage = nil
        } catch {
            photoSizeWarning = nil
            errorMessage = L10n.Couple.photoReadError
            selectedPhotoItem = nil
        }
    }
}

private struct CouplePickedImage: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            CouplePickedImage(data: data)
        }
        DataRepresentation(importedContentType: .jpeg) { data in
            CouplePickedImage(data: data)
        }
        DataRepresentation(importedContentType: .heic) { data in
            CouplePickedImage(data: data)
        }
        DataRepresentation(importedContentType: .png) { data in
            CouplePickedImage(data: data)
        }
    }
}
