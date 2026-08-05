import ImageIO
import SwiftUI
import UIKit

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
                                        .background(AppTheme.nestedGlassFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
                        .foregroundStyle(AppTheme.titleOnBackground)

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

// MARK: - Performance helpers

/// Rewrites media URLs so the app hits a reachable API host (and auth-backed photo route).
enum MediaURL {
    private static let loopbackHosts: Set<String> = [
        "localhost", "127.0.0.1", "0.0.0.0", "::1",
    ]

    static func resolving(_ url: URL) -> URL {
        if isAuthenticatedCouplePhoto(url) {
            return couplePhotoAPIURL(preservingQueryFrom: url)
        }

        #if DEBUG
        guard let mediaHost = url.host?.lowercased(),
              loopbackHosts.contains(mediaHost) else {
            return url
        }

        let api = APIConfig.baseURL
        guard let apiHost = api.host?.lowercased(),
              !loopbackHosts.contains(apiHost) else {
            return url
        }

        var parts = URLComponents(url: url, resolvingAgainstBaseURL: false)
        parts?.scheme = api.scheme
        parts?.host = api.host
        parts?.port = api.port
        return parts?.url ?? url
        #else
        return url
        #endif
    }

    static func needsAuthorization(_ url: URL) -> Bool {
        isAuthenticatedCouplePhoto(url)
    }

    private static func isAuthenticatedCouplePhoto(_ url: URL) -> Bool {
        url.path.contains("/wedding-info/photo")
    }

    private static func couplePhotoAPIURL(preservingQueryFrom url: URL) -> URL {
        var components = URLComponents(url: APIConfig.baseURL.appending(path: "wedding-info/photo"), resolvingAgainstBaseURL: false)
        components?.query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.query
        return components?.url ?? APIConfig.baseURL.appending(path: "wedding-info/photo")
    }
}

private enum ImageDownsampleCache {
    static let shared = NSCache<NSString, UIImage>()

    static func key(url: URL, maxPixelSize: CGFloat) -> NSString {
        "\(url.absoluteString)#\(Int(maxPixelSize))" as NSString
    }

    static func removeAll() {
        shared.removeAllObjects()
    }
}

enum MediaImageCache {
    /// Drop downsampled thumbnails after couple photo replace/delete.
    static func invalidateAll() {
        ImageDownsampleCache.removeAll()
    }
}

/// Loads a remote image and decodes a thumbnail near the display size (avoids full-res decode in lists).
/// Shows `placeholder` while idle/failed; overlays a progress indicator only while a request is in flight.
struct DownsampledAsyncImage<Placeholder: View>: View {
    let url: URL?
    let maxPixelSize: CGFloat
    var showsProgressIndicator: Bool = true
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder()
                if isLoading, showsProgressIndicator {
                    ProgressView()
                        .tint(AppTheme.sageDark)
                }
            }
        }
        .onChange(of: url?.absoluteString, initial: true) { _, _ in
            reload()
        }
        .onDisappear {
            loadTask?.cancel()
        }
    }

    private func reload() {
        loadTask?.cancel()
        image = nil
        isLoading = false

        guard let rawURL = url else { return }
        let resolved = MediaURL.resolving(rawURL)
        let cacheKey = ImageDownsampleCache.key(url: resolved, maxPixelSize: maxPixelSize)

        if let cached = ImageDownsampleCache.shared.object(forKey: cacheKey) {
            image = cached
            return
        }

        isLoading = true
        loadTask = Task {
            let loaded = await Self.loadDownsampled(url: resolved, maxPixelSize: maxPixelSize)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                isLoading = false
                image = loaded
                if let loaded {
                    ImageDownsampleCache.shared.setObject(loaded, forKey: cacheKey)
                }
            }
        }
    }

    private static func loadDownsampled(url: URL, maxPixelSize: CGFloat) async -> UIImage? {
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 20
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.setValue("image/*,*/*", forHTTPHeaderField: "Accept")

            if MediaURL.needsAuthorization(url), let token = KeychainStore.loadToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard !Task.isCancelled else { return nil }
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                #if DEBUG
                print("[Media] \(http.statusCode) \(url.absoluteString)")
                #endif
                return nil
            }
            // JSON/HTML error bodies are not images.
            if let contentType = (response as? HTTPURLResponse)?
                .value(forHTTPHeaderField: "Content-Type")?
                .lowercased(),
               contentType.contains("application/json") || contentType.contains("text/html") {
                #if DEBUG
                print("[Media] unexpected content-type \(contentType) \(url.absoluteString)")
                #endif
                return nil
            }
            let displayScale = await MainActor.run { UITraitCollection.current.displayScale }
            return await Task.detached(priority: .userInitiated) {
                ImageDownsampler.downsample(data: data, maxPixelSize: maxPixelSize, displayScale: displayScale)
            }.value
        } catch {
            #if DEBUG
            print("[Media] failed \(url.absoluteString): \(error.localizedDescription)")
            #endif
            return nil
        }
    }
}

/// Pure image decode helper — kept off `View` so it is not MainActor-isolated under Swift 6.
private enum ImageDownsampler {
    static func downsample(data: Data, maxPixelSize: CGFloat, displayScale: CGFloat) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return UIImage(data: data)
        }

        let maxPixels = max(maxPixelSize * max(displayScale, 2), 1)
        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixels,
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else {
            return UIImage(data: data)
        }
        return UIImage(cgImage: cgImage)
    }
}

/// Simple wrapping layout for chip rows (avoids nested horizontal ScrollView when item count is small).
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(in: proposal.width ?? .infinity, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x - spacing)
        }

        return (
            size: CGSize(width: maxWidth, height: y + rowHeight),
            frames: frames
        )
    }
}
