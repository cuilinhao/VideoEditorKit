import Foundation

/// Built-in video filters supported by both live preview and export.
///
/// The raw values are intentionally stable because `VideoFilter` is encoded in
/// `VideoEditingConfiguration`. Renaming a case would break saved projects unless
/// a schema migration is added at the same time.
public enum VideoFilter: String, CaseIterable, Codable, Equatable, Identifiable, Sendable {

    // MARK: - Cases

    /// Leaves the source pixels unchanged.
    case none
    /// Boosts saturation and contrast while keeping the effect reversible.
    case vivid
    /// Shifts white balance toward a warmer target temperature.
    case warm
    /// Shifts white balance toward a cooler target temperature.
    case cool
    /// Uses Core Image's high-contrast chrome photo effect.
    case chrome
    /// Uses Core Image's low-contrast fade photo effect.
    case fade
    /// Converts the video to a neutral monochrome look.
    case mono
    /// Converts the video to a higher-contrast black-and-white look.
    case noir

    // MARK: - Public Properties

    /// Identifiable conformance for SwiftUI filter pickers.
    public var id: String {
        rawValue
    }

    /// Localized label shown in the editor toolbar and filter picker.
    ///
    /// The values live in `VideoEditorStrings` instead of this enum so host apps
    /// keep the same localization extension point as the other editor tools.
    var title: String {
        switch self {
        case .none:
            VideoEditorStrings.filterNone
        case .vivid:
            VideoEditorStrings.filterVivid
        case .warm:
            VideoEditorStrings.filterWarm
        case .cool:
            VideoEditorStrings.filterCool
        case .chrome:
            VideoEditorStrings.filterChrome
        case .fade:
            VideoEditorStrings.filterFade
        case .mono:
            VideoEditorStrings.filterMono
        case .noir:
            VideoEditorStrings.filterNoir
        }
    }

    /// Symbol used by the demo swatch UI.
    ///
    /// This is not used for rendering the actual filter. The render path is kept
    /// in `Helpers.createVideoFilter(_:)` so UI decoration and pixel processing
    /// remain separate.
    var systemImage: String {
        switch self {
        case .none:
            "circle.slash"
        case .vivid:
            "sparkles"
        case .warm:
            "sun.max"
        case .cool:
            "snowflake"
        case .chrome:
            "camera.filters"
        case .fade:
            "circle.dashed"
        case .mono:
            "circle.lefthalf.filled"
        case .noir:
            "moon"
        }
    }

    /// Indicates whether the filter contributes any Core Image work.
    ///
    /// Preview and export use this to avoid creating an `AVVideoComposition` when
    /// the user has selected "None" and no color adjustments are active.
    var isIdentity: Bool {
        self == .none
    }

}
