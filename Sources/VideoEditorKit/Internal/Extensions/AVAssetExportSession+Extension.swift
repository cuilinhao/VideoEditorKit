import AVFoundation

extension AVAssetExportSession {

    // MARK: - Public Methods

    func exportCompatible(
        to outputURL: URL,
        as outputFileType: AVFileType
    ) async throws {
        if #available(iOS 18.0, *) {
            try await export(to: outputURL, as: outputFileType)
            return
        }

        let sessionBox = UncheckedAssetExportSessionBox(self)

        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
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
            sessionBox.session.cancelExport()
        }
    }

}

private struct UncheckedAssetExportSessionBox: @unchecked Sendable {

    // MARK: - Public Properties

    let session: AVAssetExportSession

    // MARK: - Initializer

    init(_ session: AVAssetExportSession) {
        self.session = session
    }

}
