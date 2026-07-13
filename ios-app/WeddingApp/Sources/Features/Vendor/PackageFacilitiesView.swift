import SwiftUI
import UIKit

struct PackageFacilitiesView: View {
    let sections: [VendorFacilitySection]
    var itemHtml: String? = nil
    var showsHeader: Bool = true

    private var hasHtml: Bool {
        !(itemHtml?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }

    private var hasSections: Bool {
        !displaySections.isEmpty
    }

    var body: some View {
        Group {
            if hasSections || hasHtml {
                VStack(alignment: .leading, spacing: 12) {
                    if showsHeader {
                        Text("Deskripsi")
                            .font(AppFont.semibold(18))
                            .foregroundStyle(AppTheme.ink)
                    }

                    // Prefer structured sections for a polished numbered layout.
                    // Fall back to raw RichEditor HTML only when parsing produced nothing.
                    if hasSections {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(displaySections.enumerated()), id: \.offset) { _, section in
                                sectionBlock(section)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.sage.opacity(0.08), lineWidth: 1)
                        }
                    } else if let itemHtml, hasHtml {
                        RichEditorHTMLView(html: itemHtml)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(AppTheme.sage.opacity(0.08), lineWidth: 1)
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var displaySections: [VendorFacilitySection] {
        sections
            .map { section in
                VendorFacilitySection(
                    title: section.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    items: section.items
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                )
            }
            .filter { !$0.items.isEmpty }
    }

    private func sectionBlock(_ section: VendorFacilitySection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if shouldShowSectionTitle(section.title) {
                Text(section.title)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.offset) { index, item in
                    if index > 0 {
                        Divider()
                            .overlay(AppTheme.ink.opacity(0.07))
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(AppFont.semibold(11))
                            .foregroundStyle(AppTheme.sageDark)
                            .frame(width: 24, height: 24)
                            .background(AppTheme.mist, in: Circle())

                        Text(item)
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.82))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 3)
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func shouldShowSectionTitle(_ title: String) -> Bool {
        guard !title.isEmpty else {
            return false
        }

        if displaySections.count > 1 {
            return true
        }

        return !isGenericFacilitiesTitle(title)
    }

    private func isGenericFacilitiesTitle(_ title: String) -> Bool {
        title
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased() == "fasilitas"
    }
}

/// Renders Filament/TipTap RichEditor HTML when structured sections are unavailable.
struct RichEditorHTMLView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> IntrinsicTextView {
        let textView = IntrinsicTextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.required, for: .vertical)
        return textView
    }

    func updateUIView(_ textView: IntrinsicTextView, context: Context) {
        let ink = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.90, green: 0.90, blue: 0.88, alpha: 1)
                : UIColor(red: 0.18, green: 0.18, blue: 0.16, alpha: 1)
        }

        let wrapped = """
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <div style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;font-size:13px;line-height:1.5;">
        <style>
          body{margin:0;padding:0}
          strong,b{font-weight:700}
          p{margin:0 0 10px 0}
          ol{list-style:decimal;margin:6px 0 16px 0;padding-left:1.35em}
          ul{list-style:decimal;margin:6px 0 16px 0;padding-left:1.35em}
          li{margin:4px 0}
        </style>
        \(html)
        </div>
        """

        guard let data = wrapped.data(using: .utf8) else { return }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]

        if let attributed = try? NSMutableAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        ) {
            let fullRange = NSRange(location: 0, length: attributed.length)
            attributed.addAttribute(.foregroundColor, value: ink, range: fullRange)
            textView.attributedText = attributed
        } else {
            textView.text = html.strippingHTMLTags()
            textView.textColor = ink
            textView.font = .systemFont(ofSize: 13)
        }

        textView.invalidateIntrinsicContentSize()
    }

    final class IntrinsicTextView: UITextView {
        override var intrinsicContentSize: CGSize {
            let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width - 64
            let size = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            return CGSize(width: UIView.noIntrinsicMetric, height: ceil(size.height))
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            invalidateIntrinsicContentSize()
        }
    }
}

private extension String {
    func strippingHTMLTags() -> String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PackageExclusionsView: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tidak Termasuk")
                .font(AppFont.semibold(14))
                .foregroundStyle(AppTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if index > 0 {
                        Divider()
                            .overlay(AppTheme.ink.opacity(0.07))
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(AppFont.semibold(11))
                            .foregroundStyle(AppTheme.sageDark)
                            .frame(width: 24, height: 24)
                            .background(AppTheme.mist, in: Circle())

                        Text(item)
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.82))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 3)
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.08), lineWidth: 1)
        }
    }
}
