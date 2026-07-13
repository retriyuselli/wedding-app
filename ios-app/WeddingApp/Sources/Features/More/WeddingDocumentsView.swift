import SwiftUI
import UIKit
import UniformTypeIdentifiers

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

    var apiValue: String? {
        self == .all ? nil : rawValue
    }
}

enum DocumentSortOption: String, CaseIterable, Identifiable {
    case latest
    case oldest
    case name
    case nameDesc = "name_desc"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .latest: return "Terbaru"
        case .oldest: return "Terlama"
        case .name: return "Nama A–Z"
        case .nameDesc: return "Nama Z–A"
        }
    }
}

struct WeddingDocumentsView: View {
    @State private var documents: [WeddingDocumentItem] = []
    @State private var folders: [DocumentFolderItem] = []
    @State private var summary: WeddingDocumentSummary?
    @State private var isLoading = false
    @State private var isUploading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedCategory: DocumentCategory = .all
    @State private var selectedFolderId: Int?
    @State private var sortOption: DocumentSortOption = .latest
    @State private var showFileImporter = false
    @State private var showNewFolderAlert = false
    @State private var newFolderName = ""
    @State private var showFilterSheet = false
    @State private var showCategorySheet = false
    @State private var statusTitle = ""
    @State private var statusMessage: String?
    @State private var showStatus = false
    @State private var uploadCategory: DocumentCategory = .vendor
    @State private var uploadFolderId: Int?
    @State private var searchReloadTask: Task<Void, Never>?
    @State private var isDownloading = false
    @State private var downloadShareURL: URL?
    @State private var showDownloadShare = false

    private var storageQuotaMB: Double {
        Double(summary?.quotaBytes ?? (500 * 1024 * 1024)) / 1_048_576
    }

    private var usedStorageBytes: Int {
        summary?.usedBytes ?? documents.reduce(0) { $0 + ($1.fileSize ?? 0) }
    }

    private var usedStorageMB: Double {
        Double(usedStorageBytes) / 1_048_576
    }

    private var storageFraction: Double {
        min(usedStorageMB / max(storageQuotaMB, 1), 1)
    }

    private func count(for category: DocumentCategory) -> Int {
        if let counts = summary?.counts {
            return counts[category.rawValue] ?? (category == .all ? (counts["all"] ?? 0) : 0)
        }
        if category == .all {
            return documents.count
        }
        return documents.filter { $0.categoryKind == category }.count
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
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.pdf, .jpeg, .png, .image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                Task { await upload(from: url) }
            case .failure(let error):
                statusTitle = L10n.Common.warning
                statusMessage = error.localizedDescription
                showStatus = true
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
        }
        .sheet(isPresented: $showCategorySheet) {
            categorySheet
        }
        .sheet(isPresented: $showDownloadShare) {
            if let downloadShareURL {
                NavigationStack {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.sageDark)
                        Text("Dokumen siap dibuka")
                            .font(AppFont.medium(16))
                            .foregroundStyle(AppTheme.ink)
                        Text(downloadShareURL.lastPathComponent)
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        ShareLink(item: downloadShareURL) {
                            Label("Buka / Bagikan", systemImage: "square.and.arrow.up")
                                .font(AppFont.medium(15))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 28)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(L10n.Common.close) { showDownloadShare = false }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .alert("Buat Folder Baru", isPresented: $showNewFolderAlert) {
            TextField("Nama folder", text: $newFolderName)
            Button(L10n.Common.cancel, role: .cancel) {
                newFolderName = ""
            }
            Button(L10n.Common.save) {
                let name = newFolderName
                Task { await createFolder(named: name) }
            }
        } message: {
            Text("Masukkan nama folder untuk mengelompokkan dokumen.")
        }
        .alert(statusTitle, isPresented: $showStatus) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(statusMessage ?? "")
        }
        .onChange(of: selectedCategory) { _, _ in
            Task { await loadDocuments() }
        }
        .onChange(of: selectedFolderId) { _, _ in
            Task { await loadDocuments() }
        }
        .onChange(of: sortOption) { _, _ in
            Task { await loadDocuments() }
        }
        .onChange(of: searchText) { _, _ in
            Task { await loadDocumentsDebounced() }
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
                showFilterSheet = true
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

            Text(String(format: "%.1f%%", (summary?.usedPercent ?? storageFraction * 100)))
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
                uploadCategory = selectedCategory == .all ? .vendor : selectedCategory
                uploadFolderId = selectedFolderId
                showFileImporter = true
            } label: {
                HStack(spacing: 12) {
                    Group {
                        if isUploading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.up.doc")
                                .font(.system(size: 22, weight: .light))
                        }
                    }
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
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            AppTheme.sage.opacity(0.4),
                            style: StrokeStyle(lineWidth: 1.4, dash: [6, 4])
                        )
                }
            }
            .buttonStyle(.plain)
            .disabled(isUploading)

            Button {
                newFolderName = ""
                showNewFolderAlert = true
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
                    showCategorySheet = true
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

            if !folders.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        folderChip(id: nil, title: "Semua folder")
                        ForEach(folders) { folder in
                            folderChip(id: folder.id, title: folder.name)
                        }
                    }
                }
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
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

    private func folderChip(id: Int?, title: String) -> some View {
        let isSelected = selectedFolderId == id

        return Button {
            selectedFolderId = id
        } label: {
            Text(title)
                .font(AppFont.medium(12))
                .foregroundStyle(isSelected ? .white : AppTheme.sageDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? AppTheme.sageDark : AppTheme.lightSage,
                    in: Capsule()
                )
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
                Menu {
                    ForEach(DocumentSortOption.allCases) { option in
                        Button {
                            sortOption = option
                        } label: {
                            if sortOption == option {
                                Label(option.label, systemImage: "checkmark")
                            } else {
                                Text(option.label)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Common.sort)
                            .font(AppFont.regular(12))
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.sageDark.opacity(0.75))
                }
            }

            if isLoading && documents.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if documents.isEmpty {
                MoreEmptyState(
                    icon: "folder",
                    title: searchText.isEmpty && selectedCategory == .all && selectedFolderId == nil
                        ? L10n.Documents.empty
                        : "Tidak ada dokumen",
                    message: searchText.isEmpty && selectedCategory == .all && selectedFolderId == nil
                        ? L10n.Documents.emptySub
                        : "Tidak ada dokumen yang cocok dengan pencarian atau kategori ini."
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(documents) { document in
                        documentRow(document)
                    }
                }
            }
        }
    }

    private func documentRow(_ document: WeddingDocumentItem) -> some View {
        HStack(spacing: 12) {
            fileBadge(for: document)

            VStack(alignment: .leading, spacing: 3) {
                Text(document.fileName)
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
                Button {
                    Task { await downloadOrOpen(document) }
                } label: {
                    Label(
                        isDownloading ? "Mengunduh…" : "Buka / Unduh",
                        systemImage: "arrow.down.to.line"
                    )
                }
                .disabled(isDownloading)

                if document.isUploaded {
                    Button(role: .destructive) {
                        Task { await deleteDocument(document) }
                    } label: {
                        Label(L10n.Common.delete, systemImage: "trash")
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

    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("Kategori") {
                    ForEach(DocumentCategory.allCases) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            HStack {
                                Text(category.label)
                                Spacer()
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppTheme.sageDark)
                                }
                            }
                        }
                    }
                }

                Section("Folder") {
                    Button {
                        selectedFolderId = nil
                    } label: {
                        HStack {
                            Text("Semua folder")
                            Spacer()
                            if selectedFolderId == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.sageDark)
                            }
                        }
                    }

                    ForEach(folders) { folder in
                        Button {
                            selectedFolderId = folder.id
                        } label: {
                            HStack {
                                Text(folder.name)
                                Spacer()
                                if selectedFolderId == folder.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppTheme.sageDark)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(L10n.Common.filter)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.done) { showFilterSheet = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var categorySheet: some View {
        NavigationStack {
            List {
                Section("Kategori") {
                    ForEach(DocumentCategory.allCases) { category in
                        Button {
                            selectedCategory = category
                            selectedFolderId = nil
                            showCategorySheet = false
                        } label: {
                            HStack {
                                Label(category.label, systemImage: category.icon)
                                Spacer()
                                Text("\(count(for: category))")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if !folders.isEmpty {
                    Section("Folder") {
                        ForEach(folders) { folder in
                            Button {
                                selectedFolderId = folder.id
                                selectedCategory = .all
                                showCategorySheet = false
                            } label: {
                                HStack {
                                    Label(folder.name, systemImage: "folder")
                                    Spacer()
                                    Text("\(folder.documentsCount ?? 0)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(L10n.Common.category)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.done) { showCategorySheet = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
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

    private func fileBadge(for document: WeddingDocumentItem) -> some View {
        let ext = fileExtension(for: document)
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
        let category = document.categoryKind.label
        let size = formatFileSize(document.fileSize ?? 0)
        let uploaded = displayDate(fromISO: document.createdAt) ?? "Tanggal tidak diketahui"
        let folder = document.folderName.map { " · \($0)" } ?? ""
        return "\(category)\(folder) · \(size) · \(uploaded)"
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        async let documentsTask: Void = loadDocuments()
        async let foldersTask: Void = loadFolders()
        async let summaryTask: Void = loadSummary()
        _ = await (documentsTask, foldersTask, summaryTask)
    }

    private func loadDocuments() async {
        do {
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "sort", value: sortOption.rawValue),
            ]
            if let category = selectedCategory.apiValue {
                queryItems.append(URLQueryItem(name: "category", value: category))
            }
            if let selectedFolderId {
                queryItems.append(URLQueryItem(name: "folder_id", value: String(selectedFolderId)))
            }
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                queryItems.append(URLQueryItem(name: "q", value: trimmed))
            }

            let envelope: Envelope<[WeddingDocumentItem]> = try await APIClient.shared.request(
                "wedding-documents",
                queryItems: queryItems
            )
            documents = envelope.data
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
            documents = []
        }
    }

    private func loadDocumentsDebounced() async {
        searchReloadTask?.cancel()
        let task = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await loadDocuments()
        }
        searchReloadTask = task
        await task.value
    }

    private func loadFolders() async {
        do {
            let envelope: Envelope<[DocumentFolderItem]> = try await APIClient.shared.request("document-folders")
            folders = envelope.data
        } catch {
            guard !error.isRequestCancelled else { return }
        }
    }

    private func loadSummary() async {
        do {
            let envelope: Envelope<WeddingDocumentSummary> = try await APIClient.shared.request("wedding-documents/summary")
            summary = envelope.data
        } catch {
            guard !error.isRequestCancelled else { return }
        }
    }

    private func createFolder(named rawName: String) async {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            statusTitle = L10n.Common.warning
            statusMessage = "Nama folder tidak boleh kosong."
            showStatus = true
            return
        }

        do {
            let envelope: Envelope<DocumentFolderItem> = try await APIClient.shared.request(
                "document-folders",
                method: "POST",
                json: ["name": name]
            )
            folders.append(envelope.data)
            folders.sort { ($0.sortOrder ?? 0, $0.name) < ($1.sortOrder ?? 0, $1.name) }
            selectedFolderId = envelope.data.id
            newFolderName = ""
            statusTitle = "Folder dibuat"
            statusMessage = "Folder \"\(envelope.data.name)\" siap dipakai."
            showStatus = true
        } catch {
            statusTitle = L10n.Common.warning
            statusMessage = error.userFacingMessage
            showStatus = true
        }
    }

    private func upload(from url: URL) async {
        isUploading = true
        defer { isUploading = false }

        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            if data.count > 10 * 1024 * 1024 {
                statusTitle = L10n.Common.warning
                statusMessage = L10n.Documents.uploadLimit
                showStatus = true
                return
            }

            let fileName = url.lastPathComponent.isEmpty ? "document.pdf" : url.lastPathComponent
            let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"

            var fields: [String: String] = [
                "category": uploadCategory == .all ? DocumentCategory.vendor.rawValue : uploadCategory.rawValue,
            ]
            if let uploadFolderId {
                fields["document_folder_id"] = String(uploadFolderId)
            }

            let _: Envelope<WeddingDocumentItem> = try await APIClient.shared.uploadMultipart(
                "wedding-documents",
                fields: fields,
                fileFieldName: "file",
                fileName: fileName,
                mimeType: mimeType,
                fileData: data
            )

            await load()
            statusTitle = "Berhasil diunggah"
            statusMessage = "Dokumen \"\(fileName)\" sudah tersimpan."
            showStatus = true
        } catch {
            guard !error.isRequestCancelled else { return }
            statusTitle = L10n.Common.warning
            statusMessage = error.userFacingMessage
            showStatus = true
        }
    }

    private func deleteDocument(_ document: WeddingDocumentItem) async {
        guard document.isUploaded else { return }

        do {
            try await APIClient.shared.requestNoContent("wedding-documents/\(document.id)", method: "DELETE")
            await load()
        } catch {
            statusTitle = L10n.Common.warning
            statusMessage = error.userFacingMessage
            showStatus = true
        }
    }

    @MainActor
    private func downloadOrOpen(_ document: WeddingDocumentItem) async {
        if document.isUploaded {
            isDownloading = true
            defer { isDownloading = false }

            do {
                let downloaded = try await APIClient.shared.downloadFile(
                    "wedding-documents/\(document.id)/download",
                    fallbackFileName: document.fileName
                )
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(downloaded.fileName)
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
                try downloaded.data.write(to: url, options: .atomic)
                downloadShareURL = url
                showDownloadShare = true
            } catch {
                guard !error.isRequestCancelled else { return }
                statusTitle = L10n.Common.warning
                statusMessage = error.userFacingMessage
                showStatus = true
            }
            return
        }

        guard let urlString = document.url, let url = URL(string: urlString) else {
            statusTitle = L10n.Common.warning
            statusMessage = "Tautan dokumen tidak tersedia."
            showStatus = true
            return
        }

        await UIApplication.shared.open(url)
    }

    private func fileExtension(for document: WeddingDocumentItem) -> String {
        if let dotRange = document.fileName.range(of: ".", options: .backwards) {
            let ext = String(document.fileName[dotRange.upperBound...]).uppercased()
            if !ext.isEmpty, ext.count <= 4 {
                return ext
            }
        }

        let mime = document.mimeType?.lowercased() ?? ""
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
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ",
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
