import SwiftUI

private enum EmailSubject: String, CaseIterable, Identifiable {
    case account = "Bantuan Akun"
    case budget = "Bantuan Budget"
    case technical = "Kendala Teknis"
    case data = "Permintaan Data"
    case other = "Pertanyaan Umum"

    var id: String { rawValue }
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
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: "Hubungi Customer Support",
                        subtitle: "Tim kami siap membantu Anda"
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

                    MoreFormSection(title: "Topik Pertanyaan") {
                        topicPicker
                    }

                    MoreFormSection(title: "Pesan Anda") {
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
        .alert("Pesan Terkirim", isPresented: $showSuccess) {
            Button("Lihat Percakapan") { navigateToChat = true }
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text("Pesan Anda sudah dikirim ke tim support. Kami akan merespons sesegera mungkin pada jam layanan.")
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
                Text("Chat dengan Tim Support")
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                Text("Jelaskan kendala atau pertanyaan Anda. Tim kami akan membalas melalui fitur pesan di aplikasi.")
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(AppTheme.lightSage.opacity(0.45), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                    Text(thread.lastMessage ?? "Lanjutkan percakapan dengan support")
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
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
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

            TextField("Tulis pesan atau pertanyaan Anda di sini...", text: $message, axis: .vertical)
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

            Text("Sertakan detail yang jelas agar tim kami dapat membantu lebih cepat, seperti langkah yang sudah dicoba atau tangkapan layar jika ada.")
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                Text("Kirim Pesan")
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canSend ? AppTheme.sageDark : AppTheme.sageDark.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canSend || isLoading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
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
            errorMessage = "Percakapan support belum tersedia. Silakan kirim email ke \(HelpContent.supportEmail)."
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
        session.currentUser?.name ?? "Pengguna Wedding App"
    }

    private var userEmail: String {
        session.currentUser?.email ?? ""
    }

    private var mailtoURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = HelpContent.supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "[Wedding App] \(selectedSubject.rawValue)"),
            URLQueryItem(name: "body", value: composedEmailBody),
        ]
        return components.url
    }

    private var composedEmailBody: String {
        var lines = [
            "Nama: \(userName)",
        ]

        if !userEmail.isEmpty {
            lines.append("Email: \(userEmail)")
        }

        lines.append("")
        lines.append(message.trimmingCharacters(in: .whitespacesAndNewlines))
        lines.append("")
        lines.append("—")
        lines.append("Dikirim dari Wedding App")

        return lines.joined(separator: "\n")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: "Kirim Email",
                        subtitle: "Hubungi kami melalui email"
                    )

                    emailCard

                    MoreFormSection(title: "Subjek Email") {
                        subjectPicker
                    }

                    MoreFormSection(title: "Isi Pesan") {
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
        .alert("Email Disalin", isPresented: $showCopiedAlert) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text("Alamat \(HelpContent.supportEmail) telah disalin ke clipboard.")
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

                Text("Email resmi customer support Wedding App")
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
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
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

                        Text(subject.rawValue)
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

            TextField("Tulis pesan Anda di sini...", text: $message, axis: .vertical)
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
            Text("Pratinjau Email")
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)

            Text(composedEmailBody)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.lightSage.opacity(0.45), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                        Text("Buka Aplikasi Email")
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
        .background(.ultraThinMaterial)
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
                Text("Jam Layanan Customer Support")
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)

                HStack(spacing: 16) {
                    Label(HelpContent.serviceDays, systemImage: "calendar")
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                    Label(HelpContent.serviceHours, systemImage: "clock")
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                }

                Text("Kami akan merespons Anda secepat mungkin.")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
        }
    }
}
