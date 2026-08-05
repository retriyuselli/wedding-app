import SwiftUI
import UIKit

/// Frosted strip under the system status bar so clock / signal / battery stay readable
/// when app chrome scrolls or sits on a dark stage (e.g. Midnight).
private struct StatusBarBlur: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            StatusBarBlurChrome()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

private struct StatusBarBlurChrome: View {
    private var wash: Color { AppTheme.background }

    private var prefersSolidStage: Bool {
        AppearanceStore.currentPalette.prefersLightContentChrome
    }

    var body: some View {
        GeometryReader { proxy in
            let topInset = resolvedTopInset(from: proxy)
            // Keep the band short; most of the height is soft fade (no hard edge).
            let fadeExtra: CGFloat = 20
            let blurHeight = topInset + fadeExtra

            frostLayer
                .frame(height: blurHeight)
                .mask {
                    // Top is already translucent; fade to clear — matches Live Container-style frost.
                    LinearGradient(
                        stops: [
                            .init(color: .black.opacity(prefersSolidStage ? 0.42 : 0.38), location: 0),
                            .init(color: .black.opacity(prefersSolidStage ? 0.22 : 0.20), location: 0.40),
                            .init(color: .black.opacity(0.08), location: 0.72),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var frostLayer: some View {
        if prefersSolidStage {
            // Dark frost on Midnight — avoids the thick milky-white lid.
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .overlay(Color.black.opacity(0.10))
        } else {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(wash.opacity(0.04))
        }
    }

    private func resolvedTopInset(from proxy: GeometryProxy) -> CGFloat {
        if proxy.safeAreaInsets.top > 0.5 {
            return proxy.safeAreaInsets.top
        }
        return Self.keyWindowTopInset
    }

    private static var keyWindowTopInset: CGFloat {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        for scene in scenes {
            if let inset = scene.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top, inset > 0.5 {
                return inset
            }
            if let inset = scene.windows.first?.safeAreaInsets.top, inset > 0.5 {
                return inset
            }
        }
        // Dynamic Island / notch devices — keep status icons clear if inset lookup fails.
        return 59
    }
}

enum KeyboardDismiss {
    static func resign() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

/// Installs a window-level tap recognizer that dismisses the keyboard without
/// blocking buttons, scroll, or text-field focus.
private struct KeyboardDismissTapInstaller: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            context.coordinator.attach(to: view.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.attach(to: uiView.window)
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.detach()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var window: UIWindow?
        private var gesture: UITapGestureRecognizer?

        func attach(to window: UIWindow?) {
            guard let window, window !== self.window else { return }
            detach()
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tap.cancelsTouchesInView = false
            tap.delegate = self
            window.addGestureRecognizer(tap)
            self.gesture = tap
            self.window = window
        }

        func detach() {
            if let window, let gesture {
                window.removeGestureRecognizer(gesture)
            }
            gesture = nil
            window = nil
        }

        @objc func handleTap() {
            KeyboardDismiss.resign()
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            var view = touch.view
            while let current = view {
                if current is UITextField || current is UITextView {
                    return false
                }
                view = current.superview
            }
            return true
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}

private struct DismissKeyboardOnTapModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(KeyboardDismissTapInstaller())
    }
}

private struct KeyboardDismissToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(L10n.Common.done) {
                    KeyboardDismiss.resign()
                }
            }
        }
    }
}

extension View {
    func statusBarBlur() -> some View {
        modifier(StatusBarBlur())
    }

    /// Dismisses the software keyboard when tapping outside text fields.
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTapModifier())
    }

    /// Adds a Done button above the keyboard as a reliable dismiss escape hatch.
    func keyboardDismissToolbar() -> some View {
        modifier(KeyboardDismissToolbarModifier())
    }
}
