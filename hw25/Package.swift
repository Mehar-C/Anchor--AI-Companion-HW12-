// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Anchor",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "AnchorCore",
            targets: ["AnchorCore"]
        ),
    ],
    dependencies: [
        // Add dependencies here if needed
    ],
    targets: [
        .target(
            name: "AnchorCore",
            dependencies: []
        ),
    ]
)

