import SwiftUI

struct WeddingDocumentItem: Identifiable, Hashable {
    let id: String
    let taskTitle: String
    let attachment: PreparationTaskAttachment

    init(taskTitle: String, attachment: PreparationTaskAttachment) {
        self.taskTitle = taskTitle
        self.attachment = attachment
        id = "\(taskTitle)-\(attachment.id)"
    }

    var category: DocumentCategory {
        DocumentCategory.match(taskTitle: taskTitle, fileName: attachment.fileName)
    }
}

enum DocumentCategory: String, CaseIterable, Identifiable {
    case all
    case akad
    case resepsi
    case vendor
    case keuangan

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return L10n.Common.all
        case .akad: return "Akad"
        case .resepsi: return "Resepsi"
        case .vendor: return "Vendor"
        case .keuangan: return "Keuangan"
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .akad: return "hands.sparkles"
        case .resepsi: return "fork.knife"
        case .vendor: return "person.2"
        case .keuangan: return "creditcard"
        }
    }

    private var keywords: [String] {
        switch self {
        case .all: return []
        case .akad: return ["akad", "nikah", "ijab", "khutbah", "mahar", "gaun", "busana"]
        case .resepsi: return ["resepsi", "dekorasi", "ballroom", "desain", "undangan", "souvenir", "dokumentasi"]
        case .vendor: return ["vendor", "invoice", "catering", "mua", "wedding organizer", "wo", "kontrak"]
        case .keuangan: return ["anggaran", "budget", "keuangan", "biaya", "pembayaran", "kwitansi", "rincian"]
        }
    }

    static func match(taskTitle: String, fileName: String) -> DocumentCategory {
        let haystack = "\(taskTitle) \(fileName)".lowercased()

        for category in [DocumentCategory.akad, .resepsi, .vendor, .keuangan] {
            if category.keywords.contains(where: { haystack.contains($0) }) {
                return category
            }
        }

        if fileName.lowercased().hasSuffix(".xls") || fileName.lowercased().hasSuffix(".xlsx") {
            return .keuangan
        }

        return .vendor
    }
}

struct WeddingDocumentsView: View {
    @State private var documents: [WeddingDocumentItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedCategory: DocumentCategory = .all
    @State private var showComingSoon = false

    private let storageQuotaMB: Double = 500

    private var usedStorageBytes: Int {
        documents.reduce(0) { $0 + ($1.attachment.fileSize ?? 0) }
    }

    private var usedStorageMB: Double {
        Double(usedStorageBytes) / 1_048_576
    }

    private var storageFraction: Double {
        min(usedStorageMB / storageQuotaMB, 1)
    }

    private var filteredDocuments: [WeddingDocumentItem] {
        documents.filter { document in
            let matchesCategory = selectedCategory == .all || document.category == selectedCategory
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = query.isEmpty
                || document.attachment.fileName.lowercased().contains(query)
                || document.taskTitle.lowercased().contains(query)
            return matchesCategory && matchesSearch
        }
    }

    private func count(for category: DocumentCategory) -> Int {
        if category == .all {
            return documents.count
        }
        return documents.filter { $0.category == category }.count
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Documents.title,
                        subtitle: L10n.Documents.subtitle
                    )

                    searchBar

                    storageCard

                    uploadRow

                    categorySection

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    recentSection

                    securityNote
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task { await load() }
        .refreshable { await load() }
        .alert(L10n.Common.comingSoon, isPresented: $showComingSoon) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(L10n.Common.comingSoonMessage)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))

                TextField(L10n.Documents.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppTheme.ink)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
            }

            Button {
                showComingSoon = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 13, weight: .semibold))
                    Text(L10n.Common.filter)
                        .font(AppFont.medium(13))
                }
                .foregroundStyle(AppTheme.sageDark)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var storageCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "folder.fill")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 44, height: 44)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Documents.storage)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)

                Text(L10n.Documents.storageUsed(formatStorage(usedStorageMB), Int(storageQuotaMB)))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.mist.opacity(0.7))
                        Capsule()
                            .fill(AppTheme.sageDark)
                            .frame(width: max(proxy.size.width * storageFraction, storageFraction > 0 ? 8 : 0))
                    }
                }
                .frame(height: 7)
            }

            Text(String(format: "%.1f%%", storageFraction * 100))
                .font(AppFont.semibold(13))
                .foregroundStyle(AppTheme.sageDark)
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var uploadRow: some View {
        HStack(spacing: 12) {
            Button {
                showComingSoon = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up.doc")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(AppTheme.sageDark)
                        .frame(width: 46, height: 46)
                        .background(AppTheme.lightSage.opacity(0.7), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.Documents.upload)
                            .font(AppFont.medium(14))
                            .foregroundStyle(AppTheme.sageDark)
                        Text(L10n.Documents.uploadHint)
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.45))
                            .lineLimit(2)
                        Text(L10n.Documents.uploadLimit)
                            .font(AppFont.regular(10))
                            .foregroundStyle(AppTheme.ink.opacity(0.35))
                    }

                    Spacer(minLength: 0)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.surface)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            AppTheme.sage.opacity(0.4),
                            style: StrokeStyle(lineWidth: 1.4, dash: [6, 4])
                        )
                }
            }
            .buttonStyle(.plain)

            Button {
                showComingSoon = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(AppTheme.sageDark)
                    Text(L10n.Documents.newFolder)
                        .font(AppFont.medium(11))
                        .foregroundStyle(AppTheme.sageDark)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: 96)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.Common.category)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Button {
                    showComingSoon = true
                } label: {
                    HStack(spacing: 3) {
                        Text(L10n.Common.seeAll)
                            .font(AppFont.regular(12))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(AppTheme.sageDark.opacity(0.75))
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(DocumentCategory.allCases) { category in
                        categoryChip(category)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func categoryChip(_ category: DocumentCategory) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            selectedCategory = category
        } label: {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .regular))
                Text(category.label)
                    .font(AppFont.medium(11))
                Text("\(count(for: category))")
                    .font(AppFont.regular(11))
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : AppTheme.ink.opacity(0.4))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.sageDark)
            .frame(width: 74, height: 82)
            .background(
                isSelected ? AppTheme.sageDark : AppTheme.surface,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.sage.opacity(isSelected ? 0 : 0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.Documents.recent)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Button {
                    showComingSoon = true
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Common.sort)
                            .font(AppFont.regular(12))
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.sageDark.opacity(0.75))
                }
                .buttonStyle(.plain)
            }

            if isLoading && documents.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if filteredDocuments.isEmpty {
                MoreEmptyState(
                    icon: "folder",
                    title: documents.isEmpty ? L10n.Documents.empty : "Tidak ada dokumen",
                    message: documents.isEmpty
                        ? L10n.Documents.emptySub
                        : "Tidak ada dokumen yang cocok dengan pencarian atau kategori ini."
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(filteredDocuments) { document in
                        documentRow(document)
                    }
                }
            }
        }
    }

    private func documentRow(_ document: WeddingDocumentItem) -> some View {
        HStack(spacing: 12) {
            fileBadge(for: document.attachment)

            VStack(alignment: .leading, spacing: 3) {
                Text(document.attachment.fileName)
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                Text(metaLine(document))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Menu {
                if let urlString = document.attachment.url, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Label("Buka / Unduh", systemImage: "arrow.down.to.line")
                    }
                    ShareLink(item: url) {
                        Label(L10n.Common.share, systemImage: "square.and.arrow.up")
                    }
                } else {
                    Button {
                        showComingSoon = true
                    } label: {
                        Label(L10n.Common.share, systemImage: "square.and.arrow.up")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func fileBadge(for attachment: PreparationTaskAttachment) -> some View {
        let ext = fileExtension(for: attachment)
        let color = badgeColor(for: ext)

        return VStack(spacing: 2) {
            Image(systemName: "doc.fill")
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(ext)
                .font(AppFont.semibold(8))
                .foregroundStyle(color)
        }
        .frame(width: 44, height: 44)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func metaLine(_ document: WeddingDocumentItem) -> String {
        let category = document.category.label
        let size = formatFileSize(document.attachment.fileSize ?? 0)
        let uploaded = displayDate(fromISO: document.attachment.createdAt) ?? "Tanggal tidak diketahui"
        return "\(category) · \(size) · \(uploaded)"
    }

    private var securityNote: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark.opacity(0.8))

            Text(L10n.Documents.securityNote)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))

            Spacer(minLength: 8)

            Image(systemName: "lock.fill")
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.sageDark.opacity(0.6))
        }
        .padding(14)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[PreparationTask]> = try await APIClient.shared.request("customer-preparation-tasks")
            documents = envelope.data.flatMap { task in
                (task.attachments ?? []).map { attachment in
                    WeddingDocumentItem(taskTitle: task.title, attachment: attachment)
                }
            }
            .sorted { lhs, rhs in
                let lhsDate = lhs.attachment.createdAt ?? ""
                let rhsDate = rhs.attachment.createdAt ?? ""
                return lhsDate > rhsDate
            }
        } catch {
            errorMessage = error.userFacingMessage
            documents = []
        }
    }

    private func fileExtension(for attachment: PreparationTaskAttachment) -> String {
        if let dotRange = attachment.fileName.range(of: ".", options: .backwards) {
            let ext = String(attachment.fileName[dotRange.upperBound...]).uppercased()
            if !ext.isEmpty, ext.count <= 4 {
                return ext
            }
        }

        let mime = attachment.mimeType?.lowercased() ?? ""
        if mime.contains("pdf") { return "PDF" }
        if mime.contains("png") { return "PNG" }
        if mime.contains("jpeg") || mime.contains("jpg") { return "JPG" }
        if mime.contains("sheet") || mime.contains("excel") { return "XLS" }
        return "DOC"
    }

    private func badgeColor(for ext: String) -> Color {
        switch ext {
        case "PDF": return Color(red: 0.83, green: 0.33, blue: 0.29)
        case "JPG", "JPEG": return AppTheme.sageDark
        case "PNG": return AppTheme.gold
        case "XLS", "XLSX", "CSV": return AppTheme.plum
        case "DOC", "DOCX": return Color(red: 0.24, green: 0.44, blue: 0.66)
        default: return AppTheme.ink.opacity(0.55)
        }
    }

    private func formatStorage(_ mb: Double) -> String {
        if mb >= 0.1 {
            return String(format: "%.1f MB", mb)
        }
        if mb <= 0 {
            return "0 MB"
        }
        let kb = mb * 1024
        return String(format: "%.0f KB", max(kb, 1))
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let mb = Double(bytes) / 1_048_576
        if mb >= 0.1 {
            return String(format: "%.1f MB", mb)
        }
        let kb = Double(bytes) / 1024
        return String(format: "%.0f KB", max(kb, 1))
    }

    private func displayDate(fromISO raw: String?) -> String? {
        guard let raw else { return nil }

        let parsers = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd",
        ]

        for format in parsers {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) {
                let display = DateFormatter()
                display.locale = Locale(identifier: "id_ID")
                display.dateFormat = "d MMM yyyy"
                return display.string(from: date)
            }
        }

        return nil
    }
}
