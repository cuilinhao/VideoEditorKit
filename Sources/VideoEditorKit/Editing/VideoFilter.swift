import Foundation

/// Built-in video filters supported by preview and export.
public enum VideoFilter: String, CaseIterable, Codable, Equatable, Identifiable, Sendable {

    // MARK: - Cases

    case none
    case vivid
    case warm
    case cool
    case chrome
    case fade
    case mono
    case noir

    // MARK: - Public Properties

    public var id: String {
        rawValue
    }

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

    var isIdentity: Bool {
        self == .none
    }

}
