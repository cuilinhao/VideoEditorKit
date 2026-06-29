// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "VideoEditorKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VideoEditorKit",
            targets: ["VideoEditorKit"]
        )
    ],
    targets: [
        .target(
            name: "VideoEditorKit",
            path: "Sources/VideoEditorKit",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "VideoEditorKitTests",
            dependencies: ["VideoEditorKit"]
        ),
    ]
)
