import SwiftUI

struct MessagesView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var threads: [MessageThread] = []
    @State private var searchText = ""
    @State private var filter = MessageFilter()
    @State private var selectedThread: MessageThread?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var isSearchFocused: Bool

    private let searchBarID = "messages-search-bar"

    private var filteredThreads: [MessageThread] {
        threads
            .filter { thread in
                let matchCategory = filter.category == .all || thread.category == filter.category
                let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                let matchSearch = query.isEmpty
                    || thread.name.localizedCaseInsensitiveContains(query)
                    || (thread.lastMessage ?? "").localizedCaseInsensitiveContains(query)
                let matchUnread = !filter.unreadOnly || thread.hasUnread
                return matchCategory && matchSearch && matchUnread
            }
    }

    private var totalUnread: Int {
        threads.reduce(0) { $0 + $1.unreadCount }
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        statsRow
                        searchRow
                            .id(searchBarID)
                        categoryRow
                        if filter.unreadOnly {
                            activeFilterRow
                        }
                        threadListSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: isSearchFocused) { _, focused in
                    guard focused else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(searchBarID, anchor: .top)
                    }
                }
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if isLoading && threads.isEmpty {
                ProgressView()
            }
        }
        .task { await loadThreads() }
        .refreshable { await loadThreads() }
        .navigationDestination(item: $selectedThread) { thread in
            MessageDetailView(thread: thread) {
                Task { await loadThreads() }
            }
        }
    }

    private func loadThreads() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[MessageThread]> = try await APIClient.shared.request("messages/threads")
            threads = envelope.data
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func activateSearch() {
        isSearchFocused = true
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    circleButton("arrow.left")
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 10) {
                    Button(action: activateSearch) {
                        circleButton("magnifyingglass", isActive: isSearchFocused || isSearching)
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            filter.unreadOnly.toggle()
                        }
                    } label: {
                        circleButton("bell", isActive: filter.unreadOnly, badge: totalUnread)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(L10n.Messages.title)
                .font(AppFont.serifBold(32))
                .foregroundStyle(AppTheme.titleOnBackground)

            Text(L10n.Messages.subtitle)
                .font(AppFont.serifRegular(12))
                .foregroundStyle(AppTheme.accentOnBackground)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }

    private func circleButton(_ icon: String, isActive: Bool = false, badge: Int = 0) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isActive ? AppTheme.labelOnLightSurface : AppTheme.iconOnChrome)
                .frame(width: 42, height: 42)
                .background((isActive ? AppTheme.selectedChipFill : AppTheme.chrome), in: Circle())
                .overlay {
                    Circle()
                        .stroke(
                            isActive ? AppTheme.sage.opacity(0.35) : AppTheme.hairline,
                            lineWidth: 1
                        )
                }

            if badge > 0 && icon == "bell" {
                Text(badge > 9 ? "9+" : "\(badge)")
                    .font(AppFont.medium(9))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(AppTheme.peachDark, in: Capsule())
                    .offset(x: 4, y: -2)
            }
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(label: L10n.Messages.totalChat, value: "\(threads.count)")
            statItem(label: L10n.Messages.unread, value: "\(totalUnread)", tint: AppTheme.goldOnLightSurface)
            statItem(label: L10n.Dashboard.vendors, value: "\(threads.filter { $0.category == .vendor }.count)")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .premiumGlassCard(cornerRadius: 22)
    }

    private func statItem(label: String, value: String, tint: Color = AppTheme.sageDark) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFont.semibold(18))
                .foregroundStyle(tint)
            Text(label)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.captionOnLightSurface)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var activeFilterRow: some View {
        HStack {
            Text(L10n.Messages.unreadBanner)
                .font(AppFont.medium(12))
                .foregroundStyle(AppTheme.sageDark)
            Spacer()
            Button(L10n.Common.reset) {
                filter.unreadOnly = false
            }
            .font(AppFont.medium(12))
            .foregroundStyle(AppTheme.ink.opacity(0.55))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.lightSage, in: Capsule())
    }

    // MARK: - Search

    private var searchRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSearchFocused ? AppTheme.sageDark : AppTheme.ink.opacity(0.35))

            TextField(L10n.Messages.searchPlaceholder, text: $searchText)
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.ink)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    isSearchFocused = false
                    KeyboardDismiss.resign()
                }

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.ink.opacity(0.28))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .premiumGlassCard(cornerRadius: 24)
        .overlay {
            Capsule()
                .stroke(
                    isSearchFocused ? AppTheme.sageDark.opacity(0.35) : Color.clear,
                    lineWidth: isSearchFocused ? 1.5 : 0
                )
        }
    }

    // MARK: - Categories

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MessageCategory.allCases) { category in
                    MessageCategoryChip(
                        category: category,
                        isSelected: filter.category == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            filter.category = category
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Thread List

    private var threadListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(isSearching || filter.isActive ? L10n.Messages.searchResults : L10n.Messages.conversations)
                    .font(AppFont.serifSemibold(18))
                    .foregroundStyle(AppTheme.titleOnBackground)
                Spacer()
                if isSearching {
                    Text(L10n.Messages.chatCount(filteredThreads.count))
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.mutedOnBackground.opacity(0.85))
                }
            }

            if filteredThreads.isEmpty {
                AppEmptyState(
                    icon: "bubble.left.and.bubble.right",
                    title: L10n.Messages.notFound,
                    message: L10n.Messages.notFoundSub,
                    onBackground: false
                )
                .premiumGlassCard(cornerRadius: 22)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(filteredThreads) { thread in
                        Button {
                            selectedThread = thread
                        } label: {
                            MessageThreadRow(thread: thread)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Category Chip

private struct MessageCategoryChip: View {
    let category: MessageCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12, weight: .medium))
                Text(category.label)
                    .font(AppFont.medium(12))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.labelOnLightSurface)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                Capsule().fill(isSelected ? AppTheme.sageDark : AppTheme.chipIdleFill)
            }
            .overlay {
                if !isSelected {
                    Capsule().stroke(AppTheme.hairline, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Thread Row

private struct MessageThreadRow: View {
    let thread: MessageThread

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: thread.avatarSymbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(thread.avatarTint, in: Circle())

                if thread.isOnline {
                    Circle()
                        .fill(AppTheme.sage)
                        .frame(width: 12, height: 12)
                        .overlay {
                            Circle().stroke(.white, lineWidth: 2)
                        }
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.name)
                        .font(AppFont.semibold(14))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text(thread.timeLabel)
                        .font(AppFont.regular(11))
                        .foregroundStyle(thread.hasUnread ? AppTheme.sageDark : AppTheme.ink.opacity(0.4))
                }

                HStack(alignment: .top) {
                    Text(thread.lastMessage ?? L10n.Messages.noMessage)
                        .font(AppFont.regular(12))
                        .foregroundStyle(thread.hasUnread ? AppTheme.ink.opacity(0.75) : AppTheme.ink.opacity(0.45))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    if thread.hasUnread {
                        Text("\(thread.unreadCount)")
                            .font(AppFont.medium(10))
                            .foregroundStyle(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(AppTheme.sageDark, in: Circle())
                    }
                }

                Text(thread.category.label)
                    .font(AppFont.medium(10))
                    .foregroundStyle(AppTheme.sageDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.lightSage, in: Capsule())
            }
        }
        .padding(14)
        .premiumListRow(cornerRadius: 22)
        .overlay {
            if thread.hasUnread {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.22), lineWidth: 1)
            }
        }
    }
}

// MARK: - Detail View

struct MessageDetailView: View {
    let thread: MessageThread
    let onThreadUpdated: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftText = ""
    @State private var messages: [ChatMessageItem] = []
    @State private var isLoading = false
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool

    init(thread: MessageThread, onThreadUpdated: @escaping () -> Void) {
        self.thread = thread
        self.onThreadUpdated = onThreadUpdated
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                detailHeader

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    .overlay {
                        if isLoading && messages.isEmpty {
                            ProgressView()
                        }
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                composerBar
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task { await loadMessages() }
    }

    private func loadMessages() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let envelope: Envelope<MessageThread> = try await APIClient.shared.request("messages/threads/\(thread.id)")
            messages = envelope.data.messages
            onThreadUpdated()
        } catch {
            messages = thread.messages
        }
    }

    private var detailHeader: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.iconOnChrome)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.chrome, in: Circle())
                    .overlay {
                        Circle().stroke(AppTheme.hairline, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)

            Image(systemName: thread.avatarSymbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(thread.avatarTint, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(thread.name)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.titleOnGlass)
                Text(thread.isOnline ? L10n.Messages.online : L10n.Messages.offline)
                    .font(AppFont.regular(11))
                    .foregroundStyle(thread.isOnline ? AppTheme.goldOnLightSurface : AppTheme.captionOnLightSurface)
            }

            Spacer()

            Image(systemName: "ellipsis")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.iconOnChip)
                .frame(width: 36, height: 36)
                .background {
                    Circle()
                        .fill(AppTheme.iconChipFill)
                }
                .overlay {
                    Circle().stroke(AppTheme.iconChipStroke, lineWidth: 1)
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.surface)
    }

    private var composerBar: some View {
        HStack(spacing: 10) {
            TextField(L10n.Messages.writePlaceholder, text: $draftText, axis: .vertical)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1 ... 4)
                .focused($isInputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.surface, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
                }

            Button(action: sendMessage) {
                let canSend = !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryActionForeground(enabled: canSend))
                    .frame(width: 42, height: 42)
                    .background(
                        AppTheme.primaryActionFill(enabled: canSend),
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .disabled(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(AppTheme.surface)
    }

    private func sendMessage() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        draftText = ""
        isSending = true

        Task {
            defer { isSending = false }

            do {
                let envelope: Envelope<ChatMessageItem> = try await APIClient.shared.request(
                    "messages/threads/\(thread.id)/send",
                    method: "POST",
                    json: ["body": text]
                )
                messages.append(envelope.data)
                onThreadUpdated()
            } catch {
                draftText = text
            }
        }
    }
}

private struct ChatBubble: View {
    let message: ChatMessageItem

    var body: some View {
        HStack {
            if message.isOutgoing { Spacer(minLength: 48) }

            VStack(alignment: message.isOutgoing ? .trailing : .leading, spacing: 4) {
                if let topicLabel = message.topicLabel, message.isOutgoing {
                    Text(topicLabel)
                        .font(AppFont.medium(10))
                        .foregroundStyle(message.isOutgoing ? .white.opacity(0.85) : AppTheme.sageDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            message.isOutgoing ? Color.white.opacity(0.18) : AppTheme.lightSage,
                            in: Capsule()
                        )
                }

                Text(message.text)
                    .font(AppFont.regular(13))
                    .foregroundStyle(message.isOutgoing ? .white : AppTheme.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isOutgoing ? AppTheme.sageDark : AppTheme.surface,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
                    .overlay {
                        if !message.isOutgoing {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                        }
                    }

                Text(message.timeLabel)
                    .font(AppFont.regular(10))
                    .foregroundStyle(AppTheme.ink.opacity(0.35))
            }

            if !message.isOutgoing { Spacer(minLength: 48) }
        }
    }
}
