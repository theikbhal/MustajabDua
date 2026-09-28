// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MustajabDua",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MustajabDua", targets: ["MustajabDua"])
    ],
    targets: [
        .executableTarget(
            name: "MustajabDua",
            path: "Sources/MustajabDua"
        )
    ]
)
