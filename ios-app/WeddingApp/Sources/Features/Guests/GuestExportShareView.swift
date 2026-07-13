import SwiftUI

struct GuestExportShareView: View {
    let guests: [Guest]
    let vipGuests: [VipGuest]
    let familyMembers: [FamilyMember]

    @Environment(\.dismiss) private var dismiss
    @State private var exportFileURL: URL?
    @State private var writeError: String?

    private var totalCount: Int {
        guests.count + vipGuests.count + familyMembers.count
    }

    private var confirmedCount: Int {
        rsvpCount(in: guests.map(\.rsvpStatus))
            + rsvpCount(in: vipGuests.map(\.rsvpStatus))
            + rsvpCount(in: familyMembers.map(\.rsvpStatus))
    }

    private var pendingCount: Int {
        rsvpCount(in: guests.map(\.rsvpStatus), status: "menunggu")
            + rsvpCount(in: vipGuests.map(\.rsvpStatus), status: "menunggu")
            + rsvpCount(in: familyMembers.map(\.rsvpStatus), status: "menunggu")
    }

    private var absentCount: Int {
        rsvpCount(in: guests.map(\.rsvpStatus), status: "tidak_hadir")
            + rsvpCount(in: vipGuests.map(\.rsvpStatus), status: "tidak_hadir")
            + rsvpCount(in: familyMembers.map(\.rsvpStatus), status: "tidak_hadir")
    }

    private var csvText: String {
        GuestListExporter.csv(
            guests: guests,
            vipGuests: vipGuests,
            familyMembers: familyMembers
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            overviewSection
                            sectionsPreview
                            formatNote
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }

                    shareBar
                }
            }
            .navigationTitle(L10n.Guest.exportTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if let exportFileURL {
                        ShareLink(item: exportFileURL) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task {
                exportFileURL = writeExportFile()
            }
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.Guest.exportOverview)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.5))

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                metricCard(L10n.Guest.totalGuests, "\(totalCount)", AppTheme.sageDark)
                metricCard(L10n.Common.confirmed, "\(confirmedCount)", AppTheme.sage)
                metricCard(L10n.Common.pending, "\(pendingCount)", AppTheme.gold)
                metricCard(L10n.Common.notAttending, "\(absentCount)", AppTheme.ink.opacity(0.55))
            }
        }
    }

    private var sectionsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Guest.exportIncluded)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.5))

            sectionRow(icon: "person.2.fill", title: L10n.Guest.tabGuests, count: guests.count)
            sectionRow(icon: "star.fill", title: L10n.Guest.tabVip, count: vipGuests.count)
            sectionRow(icon: "house.fill", title: L10n.Guest.tabFamily, count: familyMembers.count)
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var formatNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Guest.exportFormatTitle)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)
            Text(L10n.Guest.exportFormatSub)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)

            if let writeError {
                Text(writeError)
                    .font(AppFont.regular(12))
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.lightSage.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func metricCard(_ title: String, _ value: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.45))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(AppFont.medium(20))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.lightSage.opacity(0.35), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func sectionRow(icon: String, title: String, count: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 36, height: 36)
                .background(AppTheme.sage.opacity(0.12), in: Circle())

            Text(title)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.ink)

            Spacer()

            Text("\(count)")
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
        }
    }

    private var shareBar: some View {
        Group {
            if let exportFileURL {
                ShareLink(item: exportFileURL) {
                    Label(L10n.Guest.exportShareAction, systemImage: "square.and.arrow.up")
                        .font(AppFont.medium(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)
                .background(.ultraThinMaterial)
            } else if totalCount == 0 {
                Text(L10n.Guest.exportEmpty)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 20)
                    .background(.ultraThinMaterial)
            }
        }
    }

    private func rsvpCount(in statuses: [String], status: String = "hadir") -> Int {
        statuses.filter { $0 == status }.count
    }

    private func writeExportFile() -> URL? {
        guard totalCount > 0 else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let fileName = "Daftar-Tamu-\(formatter.string(from: Date())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            // UTF-8 BOM helps Excel detect encoding for Indonesian text.
            let bom = "\u{FEFF}"
            try (bom + csvText).write(to: url, atomically: true, encoding: .utf8)
            writeError = nil
            return url
        } catch {
            writeError = error.localizedDescription
            return nil
        }
    }
}

enum GuestListExporter {
    static func csv(
        guests: [Guest],
        vipGuests: [VipGuest],
        familyMembers: [FamilyMember]
    ) -> String {
        var lines: [String] = [
            [
                "No",
                "Tipe",
                "Nama",
                "Telepon",
                "Email",
                "Nomor Meja",
                "Jabatan",
                "Instansi",
                "Kategori",
                "Peran",
                "Status RSVP",
                "Catatan",
            ].map(escape).joined(separator: ","),
        ]

        for guest in guests.sorted(by: numberThenName) {
            lines.append(row([
                guest.no.map(String.init) ?? "",
                L10n.Guest.tabGuests,
                guest.name,
                guest.phone ?? "",
                guest.email ?? "",
                guest.tableNumber ?? "",
                "",
                "",
                "",
                "",
                RsvpKind.from(rsvp: guest.rsvpStatus).label,
                guest.catatan ?? "",
            ]))
        }

        for vip in vipGuests.sorted(by: numberThenName) {
            lines.append(row([
                vip.no.map(String.init) ?? "",
                L10n.Guest.tabVip,
                vip.name,
                vip.phone ?? "",
                "",
                "",
                vip.jabatan ?? "",
                vip.instansi ?? "",
                vip.kategoriLabel,
                "",
                RsvpKind.from(rsvp: vip.rsvpStatus).label,
                vip.catatan ?? "",
            ]))
        }

        for member in familyMembers.sorted(by: numberThenName) {
            lines.append(row([
                member.no.map(String.init) ?? "",
                L10n.Guest.tabFamily,
                member.name,
                member.phone ?? "",
                "",
                "",
                "",
                "",
                "",
                member.role ?? "",
                RsvpKind.from(rsvp: member.rsvpStatus).label,
                "",
            ]))
        }

        return lines.joined(separator: "\n")
    }

    private static func numberThenName<T: GuestNumberSortable>(_ lhs: T, _ rhs: T) -> Bool {
        let left = lhs.no ?? Int.max
        let right = rhs.no ?? Int.max
        if left != right {
            return left < right
        }
        return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }

    private static func row(_ values: [String]) -> String {
        values.map(escape).joined(separator: ",")
    }

    private static func escape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}

private protocol GuestNumberSortable {
    var no: Int? { get }
    var name: String { get }
}

extension Guest: GuestNumberSortable {}
extension VipGuest: GuestNumberSortable {}
extension FamilyMember: GuestNumberSortable {}