import AVFoundation

extension AVAssetExportSession {

    // MARK: - Public Methods

    /// Exports an asset using the newest async API when available and an iOS 17
    /// compatible continuation wrapper otherwise.
    ///
    /// `AVAssetExportSession.export(to:as:)` is only available on iOS 18. The
    /// package now supports iOS 17, so every export path goes through this method
    /// instead of calling the iOS 18 API directly.
    func exportCompatible(
        to outputURL: URL,
        as outputFileType: AVFileType
    ) async throws {
        if #available(iOS 18.0, *) {
            // Prefer the framework-provided async API when the runtime has it.
            try await export(to: outputURL, as: outputFileType)
            return
        }

        let sessionBox = UncheckedAssetExportSessionBox(self)

        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                // The legacy API requires output configuration before starting the
                // asynchronous export operation.
                sessionBox.session.outputURL = outputURL
                sessionBox.session.outputFileType = outputFileType
                sessionBox.session.exportAsynchronously {
                    switch sessionBox.session.status {
                    case .completed:
                        continuation.resume()
                    case .cancelled:
                        continuation.resume(throwing: CancellationError())
                    case .failed:
                        continuation.resume(
                            throwing: sessionBox.session.error ?? ExporterError.unknow
                        )
                    default:
                        continuation.resume(
                            throwing: sessionBox.session.error ?? ExporterError.unknow
                        )
                    }
                }
            }
        } onCancel: {
            // Tie Swift task cancellation back to AVFoundation so background export
            // work does not continue after the caller has moved on.
            sessionBox.session.cancelExport()
        }
    }

}

/// Minimal Sendable wrapper used by the iOS 17 fallback export path.
///
/// `AVAssetExportSession` is not annotated as `Sendable`, but the legacy callback
/// API requires us to keep a reference alive across the async continuation and
/// cancellation handler. The wrapper is intentionally private so the unchecked
/// guarantee stays constrained to this compatibility bridge.
private struct UncheckedAssetExportSessionBox: @unchecked Sendable {

    // MARK: - Public Properties

    let session: AVAssetExportSession

    // MARK: - Initializer

    init(_ session: AVAssetExportSession) {
        self.session = session
    }

}
