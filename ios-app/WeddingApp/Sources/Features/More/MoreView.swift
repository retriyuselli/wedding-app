import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var info = WeddingInfo(id: nil, groomName: "", brideName: "", budaya: "", songlist: [])
    @State private var events: [WeddingEvent] = []

    private var coupleName: String {
        let bride = info.brideName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let groom = info.groomName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if bride.isEmpty && groom.isEmpty {
            return session.currentUser?.name ?? "Wedding Couple"
        }
        return [bride, groom].filter { !$0.isEmpty }.joined(separator: " & ")
    }

    private var weddingDate: Date? {
        events.compactMap { $0.tglAcara.flatMap { DateFormatter.moreInput.date(from: $0) } }
            .sorted()
            .last
    }

    private var primaryLocation: String {
        events.compactMap(\.lokasiAcara).first { !$0.isEmpty } ?? "Lokasi belum diatur"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        profileCard
                        sectionGroup(title: "Perencanaan Saya", items: planningItems)
                        sectionGroup(title: "Akun & Pengaturan", items: accountItems)
                        shareCard
                        logoutButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task { await load() }
            .refreshable { await load() }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                Task { await load() }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("More")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text("Pengaturan, informasi, dan lainnya\nuntuk pengalaman terbaik Anda.")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 88, alignment: .top)
        .padding(.top, 8)
    }

    private var profileCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image("CouplePortrait")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 66, height: 66)
                    .clipShape(Circle())
                    .overlay { Circle().stroke(AppTheme.gold.opacity(0.5), lineWidth: 1.5) }

                VStack(alignment: .leading, spacing: 3) {
                    Text(coupleName)
                        .font(AppFont.medium(19))
                        .foregroundStyle(AppTheme.sageDark)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(weddingDate.map { DateFormatter.moreDisplay.string(from: $0) } ?? "Tanggal belum diatur")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))

                    Text(primaryLocation)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }

            NavigationLink {
                InfoTabView()
            } label: {
                HStack {
                    Label("Edit Profil", systemImage: "square.and.pencil")
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppTheme.sageDark)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.3))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
    }

    private func sectionGroup(title: String, items: [MoreItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    MoreRow(item: items[index])
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 12, y: 6)
        }
    }

    private var planningItems: [MoreItem] {
        [
            MoreItem(icon: "calendar", title: "Detail Pernikahan", subtitle: "Tanggal, lokasi, dan informasi penting", destination: .weddingDetail),
            MoreItem(icon: "person.2", title: "Pasangan", subtitle: "Informasi mempelai", destination: .weddingInfo),
            MoreItem(icon: "checklist", title: "Vendor Tersimpan", subtitle: "Daftar vendor pilihan Anda", destination: nil),
            MoreItem(icon: "heart", title: "Inspirasi & Ide", subtitle: "Simpan inspirasi dan referensi", destination: nil),
            MoreItem(icon: "folder", title: "Dokumen", subtitle: "Simpan dokumen penting pernikahan", destination: nil),
        ]
    }

    private var accountItems: [MoreItem] {
        [
            MoreItem(icon: "gearshape", title: "Pengaturan", subtitle: "Notifikasi, tampilan, dan preferensi", destination: nil),
            MoreItem(icon: "lock", title: "Privasi & Keamanan", subtitle: "Kelola privasi dan keamanan akun", destination: nil),
            MoreItem(icon: "bell", title: "Pengingat", subtitle: "Atur pengingat dan notifikasi", destination: nil),
            MoreItem(icon: "globe", title: "Bahasa", subtitle: "Indonesia", destination: nil),
            MoreItem(icon: "questionmark.circle", title: "Bantuan & FAQ", subtitle: "Pusat bantuan dan pertanyaan umum", destination: nil),
            MoreItem(icon: "info.circle", title: "Tentang Wedding App", subtitle: "Versi 1.0.0", destination: nil),
        ]
    }

    private var shareCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "envelope.open")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(AppTheme.sageDark)

            VStack(alignment: .leading, spacing: 3) {
                Text("Bagikan Wedding App")
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.sageDark)
                Text("Bantu teman Anda yang sedang\nmerencanakan pernikahan.")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .lineSpacing(1)
            }

            Spacer(minLength: 4)

            ShareLink(item: URL(string: "https://paketpernikahan.co.id")!) {
                Label("Bagikan", systemImage: "square.and.arrow.up")
                    .font(AppFont.medium(12))
                    .foregroundStyle(AppTheme.sageDark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(.white, in: Capsule())
                    .overlay { Capsule().stroke(AppTheme.sage.opacity(0.2), lineWidth: 1) }
            }
        }
        .padding(16)
        .background(AppTheme.lightSage.opacity(0.7), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
        }
    }

    private var logoutButton: some View {
        Button {
            Task { await session.logout() }
        } label: {
            Label("Keluar dari Akun", systemImage: "rectangle.portrait.and.arrow.right")
                .font(AppFont.medium(15))
                .foregroundStyle(Color.red.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func load() async {
        do {
            async let infoEnvelope: Envelope<WeddingInfo> = APIClient.shared.request("wedding-info")
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")
            info = try await infoEnvelope.data
            events = try await eventEnvelope.data
        } catch {
            // biarkan tampilan pakai data default kalau gagal
        }
    }
}

private struct MoreItem: Identifiable {
    enum Destination {
        case weddingDetail
        case weddingInfo
        case events
    }

    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let destination: Destination?
}

private struct MoreRow: View {
    let item: MoreItem

    var body: some View {
        if let destination = item.destination {
            NavigationLink {
                switch destination {
                case .weddingDetail: WeddingDetailView()
                case .weddingInfo: InfoTabView()
                case .events: EventListView()
                }
            } label: {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 34, height: 34)
                .background(AppTheme.sage.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                Text(item.subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private extension DateFormatter {
    static let moreInput: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static let moreDisplay: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()
}
