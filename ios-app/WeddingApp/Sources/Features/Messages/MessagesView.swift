import SwiftUI

struct MessagesView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var threads: [MessageThread] = MessageThread.samples
    @State private var searchText = ""
    @State private var filter = MessageFilter()
    @State private var selectedThread: MessageThread?
    @FocusState private var isSearchFocused: Bool

    private let searchBarID = "messages-search-bar"

    private var filteredThreads: [MessageThread] {
        threads
            .filter { thread in
                let matchCategory = filter.category == .all || thread.category == filter.category
                let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                let matchSearch = query.isEmpty
                    || thread.name.localizedCaseInsensitiveContains(query)
                    || thread.lastMessage.localizedCaseInsensitiveContains(query)
                let matchUnread = !filter.unreadOnly || thread.hasUnread
                return matchCategory && matchSearch && matchUnread
            }
    }

    private var totalUnread: Int {
        threads.reduce(0) { $0 + $1.unreadCount }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

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
                .refreshable {}
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
        .navigationDestination(item: $selectedThread) { thread in
            MessageDetailView(thread: thread) { updated in
                if let index = threads.firstIndex(where: { $0.id == updated.id }) {
                    threads[index] = updated
                }
            }
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
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.8))
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

            Text("Messages")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text("Kelola percakapan dengan vendor,\npanitia, dan tim support.")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }

    private func circleButton(_ icon: String, isActive: Bool = false, badge: Int = 0) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(isActive ? AppTheme.sageDark : AppTheme.ink.opacity(0.72))
                .frame(width: 42, height: 42)
                .background((isActive ? AppTheme.lightSage : .white).opacity(0.86), in: Circle())
                .overlay {
                    Circle()
                        .stroke(AppTheme.sage.opacity(isActive ? 0.35 : 0), lineWidth: 1)
                }
                .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)

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
            statItem(label: "Total Chat", value: "\(threads.count)")
            statItem(label: "Belum Dibaca", value: "\(totalUnread)", tint: AppTheme.gold)
            statItem(label: "Vendor", value: "\(threads.filter { $0.category == .vendor }.count)")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.07), radius: 14, y: 7)
    }

    private func statItem(label: String, value: String, tint: Color = AppTheme.sageDark) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFont.semibold(18))
                .foregroundStyle(tint)
            Text(label)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var activeFilterRow: some View {
        HStack {
            Text("Menampilkan pesan belum dibaca")
                .font(AppFont.medium(12))
                .foregroundStyle(AppTheme.sageDark)
            Spacer()
            Button("Reset") {
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

            TextField("Cari percakapan atau pesan...", text: $searchText)
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.ink)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit { isSearchFocused = false }

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
        .background(AppTheme.surface, in: Capsule())
        .overlay {
            Capsule()
                .stroke(
                    isSearchFocused ? AppTheme.sageDark.opacity(0.35) : AppTheme.sage.opacity(0.10),
                    lineWidth: isSearchFocused ? 1.5 : 1
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
                Text(isSearching || filter.isActive ? "Hasil Pencarian" : "Percakapan")
                    .font(AppFont.semibold(18))
                    .foregroundStyle(AppTheme.sageDark)
                Spacer()
                if isSearching {
                    Text("\(filteredThreads.count) chat")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }
            }

            if filteredThreads.isEmpty {
                emptyState
            } else {
                VStack(spacing: 10) {
                    ForEach(filteredThreads) { thread in
                        Button {
                            let opened = MessageThread(
                                id: thread.id,
                                name: thread.name,
                                category: thread.category,
                                lastMessage: thread.lastMessage,
                                timeLabel: thread.timeLabel,
                                unreadCount: 0,
                                isOnline: thread.isOnline,
                                avatarSymbol: thread.avatarSymbol,
                                avatarTint: thread.avatarTint,
                                messages: thread.messages
                            )
                            if let index = threads.firstIndex(where: { $0.id == thread.id }) {
                                threads[index] = opened
                            }
                            selectedThread = opened
                        } label: {
                            MessageThreadRow(thread: thread)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(AppTheme.ink.opacity(0.25))
            Text("Percakapan tidak ditemukan")
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
            Text("Coba kata kunci lain atau ubah filter.")
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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
            .foregroundStyle(isSelected ? .white : AppTheme.sageDark)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isSelected ? AppTheme.sageDark : AppTheme.lightSage, in: Capsule())
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
                    Text(thread.lastMessage)
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
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(thread.hasUnread ? 0.18 : 0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 12, y: 6)
    }
}

// MARK: - Detail View

struct MessageDetailView: View {
    let thread: MessageThread
    let onUpdate: (MessageThread) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftText = ""
    @State private var messages: [ChatMessageItem]
    @FocusState private var isInputFocused: Bool

    init(thread: MessageThread, onUpdate: @escaping (MessageThread) -> Void) {
        self.thread = thread
        self.onUpdate = onUpdate
        _messages = State(initialValue: thread.messages)
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

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
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                composerBar
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var detailHeader: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.8))
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
                    .foregroundStyle(AppTheme.ink)
                Text(thread.isOnline ? "Online" : "Offline")
                    .font(AppFont.regular(11))
                    .foregroundStyle(thread.isOnline ? AppTheme.sage : AppTheme.ink.opacity(0.45))
            }

            Spacer()

            Image(systemName: "ellipsis")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.86), in: Circle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var composerBar: some View {
        HStack(spacing: 10) {
            TextField("Tulis pesan...", text: $draftText, axis: .vertical)
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
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AppTheme.mist
                            : AppTheme.sageDark,
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .disabled(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private func sendMessage() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let newMessage = ChatMessageItem(
            id: (messages.map(\.id).max() ?? 0) + 1,
            text: text,
            isOutgoing: true,
            timeLabel: "Baru"
        )
        messages.append(newMessage)
        draftText = ""

        let updated = MessageThread(
            id: thread.id,
            name: thread.name,
            category: thread.category,
            lastMessage: text,
            timeLabel: "Baru",
            unreadCount: 0,
            isOnline: thread.isOnline,
            avatarSymbol: thread.avatarSymbol,
            avatarTint: thread.avatarTint,
            messages: messages
        )
        onUpdate(updated)
    }
}

private struct ChatBubble: View {
    let message: ChatMessageItem

    var body: some View {
        HStack {
            if message.isOutgoing { Spacer(minLength: 48) }

            VStack(alignment: message.isOutgoing ? .trailing : .leading, spacing: 4) {
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
