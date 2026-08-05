import SwiftUI

private enum EmailSubject: String, CaseIterable, Identifiable {
    case account
    case budget
    case technical
    case data
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .account: return L10n.Help.emailSubjectAccount
        case .budget: return L10n.Help.emailSubjectBudget
        case .technical: return L10n.Help.emailSubjectTechnical
        case .data: return L10n.Help.emailSubjectData
        case .other: return L10n.Help.emailSubjectOther
        }
    }
}

// MARK: - Customer Support

struct HelpCustomerSupportView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var selectedTopic: SupportMessageTopic = .account
    @State private var message = ""
    @State private var supportThread: MessageThread?
    @State private var isLoading = false
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @State private var navigateToChat = false

    private var canSend: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Help.contactTitle,
                        subtitle: L10n.Help.contactSubtitle
                    )

                    introCard

                    if let supportThread {
                        existingChatCard(supportThread)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    MoreFormSection(title: L10n.Help.topicSection) {
                        topicPicker
                    }

                    MoreFormSection(title: L10n.Help.messageSection) {
                        messageField
                    }

                    tipsCard

                    serviceHoursCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }

            sendButton
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task { await loadSupportThread() }
        .navigationDestination(isPresented: $navigateToChat) {
            if let supportThread {
                MessageDetailView(thread: supportThread) {}
            }
        }
        .alert(L10n.Help.messageSentTitle, isPresented: $showSuccess) {
            Button(L10n.Help.viewConversation) { navigateToChat = true }
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(L10n.Help.messageSentBody)
        }
    }

    private var introCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 48, height: 48)
                .background(AppTheme.lightSage, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Help.contactIntroTitle)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.Help.contactIntroBody)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .premiumListRow(cornerRadius: 20)
    }

    private func existingChatCard(_ thread: MessageThread) -> some View {
        Button {
            navigateToChat = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: thread.avatarSymbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(thread.avatarTint, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(thread.name)
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.ink)
                    Text(thread.lastMessage ?? L10n.Help.continueSupportChat)
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                if thread.hasUnread {
                    Text("\(thread.unreadCount)")
                        .font(AppFont.semibold(11))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.sageDark, in: Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.28))
            }
            .padding(14)
            .premiumListRow(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private var topicPicker: some View {
        VStack(spacing: 8) {
            ForEach(SupportMessageTopic.allCases) { topic in
                Button {
                    selectedTopic = topic
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedTopic == topic ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(selectedTopic == topic ? AppTheme.sageDark : AppTheme.ink.opacity(0.25))

                        Text(topic.label)
                            .font(AppFont.regular(14))
                            .foregroundStyle(AppTheme.ink)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        selectedTopic == topic ? AppTheme.lightSage.opacity(0.5) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var messageField: some View {
        HStack(alignment: .top, spacing: 12) {
            MoreFieldIcon(name: "text.bubble")

            TextField(L10n.Help.messagePlaceholder, text: $message, axis: .vertical)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(4 ... 8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(MoreFieldBackground())
    }

    private var tipsCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark.opacity(0.75))

            Text(L10n.Help.messageTips)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumListRow(cornerRadius: 16)
    }

    private var serviceHoursCard: some View {
        HelpServiceHoursCard()
    }

    private var sendButton: some View {
        Button {
            Task { await sendMessage() }
        } label: {
            HStack(spacing: 8) {
                if isSending || isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(L10n.Help.sendMessage)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(AppTheme.primaryActionForeground(enabled: canSend))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                AppTheme.primaryActionFill(enabled: canSend),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(!canSend || isLoading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(AppTheme.surface)
    }

    private func loadSupportThread() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let envelope: Envelope<MessageThread> = try await APIClient.shared.request(
                "messages/threads/support"
            )
            supportThread = envelope.data
        } catch {
            supportThread = nil
            errorMessage = error.userFacingMessage
        }
    }

    private func sendMessage() async {
        if supportThread == nil {
            await loadSupportThread()
        }

        guard let supportThread else {
            errorMessage = L10n.Help.supportUnavailable(HelpContent.supportEmail)
            return
        }

        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSending = true
        errorMessage = nil
        defer { isSending = false }

        do {
            let _: Envelope<ChatMessageItem> = try await APIClient.shared.request(
                "messages/threads/\(supportThread.id)/send",
                method: "POST",
                json: [
                    "body": trimmed,
                    "topic": selectedTopic.rawValue,
                ]
            )
            message = ""
            showSuccess = true
            await loadSupportThread()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}

// MARK: - Send Email

struct HelpSendEmailView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var selectedSubject: EmailSubject = .account
    @State private var message = ""
    @State private var showCopiedAlert = false

    private var userName: String {
        session.currentUser?.name ?? L10n.Help.defaultUserName
    }

    private var userEmail: String {
        session.currentUser?.email ?? ""
    }

    private var mailtoURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = HelpContent.supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "[Wedding App] \(selectedSubject.label)"),
            URLQueryItem(name: "body", value: composedEmailBody),
        ]
        return components.url
    }

    private var composedEmailBody: String {
        var lines = [
            L10n.Help.emailFieldName(userName),
        ]

        if !userEmail.isEmpty {
            lines.append(L10n.Help.emailFieldEmail(userEmail))
        }

        lines.append("")
        lines.append(message.trimmingCharacters(in: .whitespacesAndNewlines))
        lines.append("")
        lines.append("—")
        lines.append(L10n.Help.emailSentFrom)

        return lines.joined(separator: "\n")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Help.emailTitle,
                        subtitle: L10n.Help.emailSubtitle
                    )

                    emailCard

                    MoreFormSection(title: L10n.Help.emailSubjectSection) {
                        subjectPicker
                    }

                    MoreFormSection(title: L10n.Help.emailBodySection) {
                        emailMessageField
                    }

                    previewCard

                    serviceHoursCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }

            actionButtons
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .alert(L10n.Help.emailCopiedTitle, isPresented: $showCopiedAlert) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(L10n.Help.emailCopiedBody(HelpContent.supportEmail))
        }
    }

    private var emailCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 48, height: 48)
                .background(AppTheme.lightSage, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(HelpContent.supportEmail)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.sageDark)

                Text(L10n.Help.emailOfficialBlurb)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
            }

            Spacer(minLength: 0)

            Button {
                UIPasteboard.general.string = HelpContent.supportEmail
                showCopiedAlert = true
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.lightSage, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .premiumListRow(cornerRadius: 20)
    }

    private var subjectPicker: some View {
        VStack(spacing: 8) {
            ForEach(EmailSubject.allCases) { subject in
                Button {
                    selectedSubject = subject
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedSubject == subject ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(selectedSubject == subject ? AppTheme.sageDark : AppTheme.ink.opacity(0.25))

                        Text(subject.label)
                            .font(AppFont.regular(14))
                            .foregroundStyle(AppTheme.ink)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        selectedSubject == subject ? AppTheme.lightSage.opacity(0.5) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emailMessageField: some View {
        HStack(alignment: .top, spacing: 12) {
            MoreFieldIcon(name: "text.alignleft")

            TextField(L10n.Help.emailBodyPlaceholder, text: $message, axis: .vertical)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(5 ... 10)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(MoreFieldBackground())
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Help.emailPreview)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)

            Text(composedEmailBody)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumListRow(cornerRadius: 16)
    }

    private var serviceHoursCard: some View {
        HelpServiceHoursCard()
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            if let mailtoURL {
                Link(destination: mailtoURL) {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.open.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text(L10n.Help.openMailApp)
                            .font(AppFont.medium(16))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(AppTheme.surface)
    }
}

// MARK: - Shared

struct HelpServiceHoursCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "headphones")
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 48, height: 48)
                .background(AppTheme.lightSage, in: Circle())

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Help.serviceHoursTitle)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)

                HStack(spacing: 16) {
                    Label(L10n.Help.serviceDays, systemImage: "calendar")
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                    Label(L10n.Help.serviceHours, systemImage: "clock")
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                }

                Text(L10n.Help.serviceHoursResponse)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .premiumListRow(cornerRadius: 20)
    }
}
