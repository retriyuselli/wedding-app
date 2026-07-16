import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct CoupleView: View {
    @Environment(\.dismiss) private var dismiss

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
    @State private var couplePhotoURL: URL?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoPreview: UIImage?
    @State private var photoFileData: Data?
    @State private var isLoading = false
    @State private var errorMessage: String?

    /// Keep under PHP `post_max_size` (often 2M) after multipart overhead.
    private let maxPhotoBytes = 1_850_000

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

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
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
                        MoreInputRow(
                            icon: "heart.text.square",
                            placeholder: L10n.Couple.culturePlaceholder,
                            text: $budaya
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            MorePrimaryButton(
                title: L10n.Couple.save,
                isLoading: isLoading,
                isEnabled: canSave,
                action: { Task { await save() } }
            )
        }
        .task { await load() }
        .onChange(of: selectedPhotoItem) { _, item in
            Task { await loadSelectedPhoto(item) }
        }
    }

    private var couplePreviewCard: some View {
        HStack(spacing: 14) {
            couplePhotoThumb(size: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(couplePreview)
                    .font(AppFont.medium(18))
                    .foregroundStyle(AppTheme.sageDark)
                    .lineLimit(2)

                Text(budaya.isEmpty ? L10n.Couple.cultureEmpty : budaya)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 20)
    }

    private var photoUploadSection: some View {
        MoreFormSection(title: L10n.Couple.photoSection) {
            VStack(spacing: 12) {
                couplePhotoThumb(size: 112)

                PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                        Text(photoPreview == nil && couplePhotoURL == nil
                              ? L10n.Couple.photoUpload
                              : L10n.Couple.photoChange)
                    }
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.nestedGlassFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Text(L10n.Couple.photoHint)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.inkMuted(0.55))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func couplePhotoThumb(size: CGFloat) -> some View {
        Group {
            if let photoPreview {
                Image(uiImage: photoPreview)
                    .resizable()
                    .scaledToFill()
            } else if let couplePhotoURL {
                AsyncImage(url: couplePhotoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholderPhoto
                    default:
                        ProgressView()
                    }
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
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let envelope: Envelope<WeddingInfo> = try await APIClient.shared.request("wedding-info")
            apply(envelope.data)
        } catch {
            errorMessage = error.userFacingMessage
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
        budaya = data.budaya ?? ""
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
            if let photoFileData {
                guard photoFileData.count <= maxPhotoBytes else {
                    errorMessage = L10n.Couple.photoTooLarge
                    return
                }

                let envelope: Envelope<WeddingInfo> = try await APIClient.shared.uploadMultipart(
                    "wedding-info",
                    method: "POST",
                    fields: textFieldsForMultipart(),
                    fileFieldName: "couple_photo",
                    fileName: "couple.jpg",
                    mimeType: "image/jpeg",
                    fileData: photoFileData
                )
                saved = envelope.data
                self.photoFileData = nil
                self.selectedPhotoItem = nil
            } else {
                let envelope: Envelope<WeddingInfo> = try await APIClient.shared.request(
                    "wedding-info",
                    method: "PUT",
                    json: textPayload()
                )
                saved = envelope.data
            }

            apply(saved)
            if photoPreview != nil, saved.couplePhotoUrl != nil {
                photoPreview = nil
            }
            dismiss()
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
        put("budaya", budaya)
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
            "budaya": value(budaya),
        ]
    }

    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let picked = try await item.loadTransferable(type: CouplePickedImage.self),
                  let image = UIImage(data: picked.data) else {
                errorMessage = L10n.Couple.photoReadError
                selectedPhotoItem = nil
                return
            }

            guard let compressed = compressJPEG(image, maxBytes: maxPhotoBytes) else {
                errorMessage = L10n.Couple.photoTooLarge
                selectedPhotoItem = nil
                photoPreview = nil
                photoFileData = nil
                return
            }

            photoPreview = image
            photoFileData = compressed
            errorMessage = nil
        } catch {
            errorMessage = L10n.Couple.photoReadError
            selectedPhotoItem = nil
        }
    }

    private func compressJPEG(_ image: UIImage, maxBytes: Int) -> Data? {
        var working = image
        if let resized = resizedForUpload(image) {
            working = resized
        }

        var quality: CGFloat = 0.85
        var data = working.jpegData(compressionQuality: quality)
        while let current = data, current.count > maxBytes, quality > 0.2 {
            quality -= 0.1
            data = working.jpegData(compressionQuality: quality)
        }
        guard let data, data.count <= maxBytes else { return nil }
        return data
    }

    private func resizedForUpload(_ image: UIImage) -> UIImage? {
        let maxDimension: CGFloat = 1600
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return image }

        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
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
