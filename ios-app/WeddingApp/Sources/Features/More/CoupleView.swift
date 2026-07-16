import PhotosUI
import SwiftUI

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

    private let maxPhotoBytes = 1_024 * 1_024

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
            let data = envelope.data
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
            }
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

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

        do {
            let _: Envelope<WeddingInfo> = try await APIClient.shared.request(
                "wedding-info",
                method: "PUT",
                json: payload
            )

            if let photoFileData {
                guard photoFileData.count <= maxPhotoBytes else {
                    errorMessage = L10n.Couple.photoTooLarge
                    return
                }

                let uploaded: Envelope<WeddingInfo> = try await APIClient.shared.uploadMultipart(
                    "wedding-info/photo",
                    method: "POST",
                    fields: [:],
                    fileFieldName: "couple_photo",
                    fileName: "couple.jpg",
                    mimeType: "image/jpeg",
                    fileData: photoFileData
                )
                if let urlString = uploaded.data.couplePhotoUrl, let url = URL(string: urlString) {
                    couplePhotoURL = url
                }
                self.photoFileData = nil
            }

            dismiss()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
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
        var quality: CGFloat = 0.9
        var data = image.jpegData(compressionQuality: quality)
        while let current = data, current.count > maxBytes, quality > 0.25 {
            quality -= 0.1
            data = image.jpegData(compressionQuality: quality)
        }
        guard let data, data.count <= maxBytes else { return nil }
        return data
    }
}
