// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "OpenClawEventKitHandoff",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "OpenClawKit", targets: ["OpenClawKit"]),
        .library(name: "OpenClawRuntime", targets: ["OpenClawRuntime"]),
    ],
    targets: [
        .target(
            name: "OpenClawKit",
            path: "Sources/OpenClawKit"
        ),
        .target(
            name: "OpenClawRuntime",
            dependencies: ["OpenClawKit"],
            path: "Sources/OpenClawRuntime"
        ),
        .testTarget(
            name: "OpenClawKitTests",
            dependencies: ["OpenClawKit"],
            path: "Tests/OpenClawKitTests"
        ),
        .testTarget(
            name: "OpenClawRuntimeTests",
            dependencies: ["OpenClawRuntime", "OpenClawKit"],
            path: "Tests/OpenClawRuntimeTests"
        ),
    ]
)
