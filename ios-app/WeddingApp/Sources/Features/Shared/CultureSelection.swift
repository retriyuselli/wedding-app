import SwiftUI

/// Shared culture/adat selection: preset chips + optional custom text for "Lainnya".
enum CultureSelection {
    static var otherLabel: String { L10n.Onboarding.cultureOther }

    /// Preset chips shown in pickers (excludes "Lainnya").
    static var presets: [String] {
        L10n.Onboarding.cultureOptions.filter { $0 != otherLabel }
    }

    /// All chip options including "Lainnya".
    static var chipOptions: [String] { L10n.Onboarding.cultureOptions }

    static func isOther(_ value: String) -> Bool {
        value == otherLabel
    }

    /// Resolve what to persist in `wedding_infos.budaya`.
    static func resolvedValue(selected: String, custom: String) -> String {
        let trimmedCustom = custom.trimmingCharacters(in: .whitespacesAndNewlines)
        if isOther(selected) {
            return trimmedCustom
        }
        return selected.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isValid(selected: String, custom: String) -> Bool {
        let value = resolvedValue(selected: selected, custom: custom)
        return !value.isEmpty && !isOther(value)
    }

    /// Map a stored budaya into chip selection + custom field.
    static func applyLoaded(
        _ stored: String?,
        selected: inout String,
        custom: inout String,
        knownOptions: [String]? = nil
    ) {
        let value = stored?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !value.isEmpty else {
            selected = ""
            custom = ""
            return
        }

        let known = knownOptions ?? chipOptions.filter { !isOther($0) }
        if known.contains(value) {
            selected = value
            custom = ""
        } else {
            selected = otherLabel
            custom = value
        }
    }
}

struct CultureChipGrid: View {
    @Binding var selected: String
    @Binding var customText: String
    var onSelect: ((String) -> Void)? = nil

    @FocusState private var isCustomFocused: Bool

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(CultureSelection.chipOptions, id: \.self) { item in
                    let isSelected = selected == item
                    Button {
                        selected = item
                        if !CultureSelection.isOther(item) {
                            customText = ""
                        }
                        onSelect?(item)
                    } label: {
                        Text(item)
                            .font(AppFont.semibold(15))
                            .foregroundStyle(isSelected ? Color.white : AppTheme.titleOnGlass)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.sage, AppTheme.brandGradientEnd],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(AppTheme.nestedGlassFill)
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(isSelected ? Color.white.opacity(0.2) : AppTheme.iconChipStroke, lineWidth: 1)
                            }
                            .shadow(color: AppTheme.sageDark.opacity(isSelected ? 0.14 : 0.05), radius: isSelected ? 10 : 6, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }

            if CultureSelection.isOther(selected) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Onboarding.cultureCustomLabel)
                        .font(AppFont.semibold(13))
                        .foregroundStyle(AppTheme.sageMuted(0.9))

                    HStack(spacing: 12) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.gold)
                            .frame(width: 22)

                        TextField(L10n.Onboarding.cultureCustomPlaceholder, text: $customText)
                            .font(AppFont.medium(16))
                            .foregroundStyle(AppTheme.titleOnGlass)
                            .textInputAutocapitalization(.words)
                            .focused($isCustomFocused)
                            .submitLabel(.done)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .premiumGlassCard(cornerRadius: 18)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: selected)
        .onChange(of: selected) { _, newValue in
            if CultureSelection.isOther(newValue) {
                isCustomFocused = true
            }
        }
    }
}
