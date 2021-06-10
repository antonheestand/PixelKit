// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PixelKit",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "PixelKit", targets: ["PixelKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/RenderKit", .branch("lite")),
        .package(url: "https://github.com/heestand-xyz/PixelColor", from: "1.2.1"),
        .package(url: "https://github.com/heestand-xyz/Resolution", from: "1.0.1"),
    ],
    targets: [
        .target(name: "PixelKit", dependencies: ["RenderKit"], path: "Source", exclude: [
            "PIX/PIXs/Output/Syphon Out/SyphonOutPIX.swift",
            "PIX/PIXs/Content/Resource/Syphon In/SyphonInPIX.swift",
            "PIX/Auto/PIXUIs.stencil",
            "PIX/Auto/PIXAuto.stencil",
            "Other/NDI",
            "Shaders/README.md",
        ], resources: [
            .process("metaltest.txt"),
            .process("metaltest.metal"),
        ]),
        .testTarget(name: "PixelKitTests", dependencies: ["PixelKit"])
    ]
)
