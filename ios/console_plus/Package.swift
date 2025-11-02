// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "console_plus",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "console_plus",
            targets: ["console_plus"])
    ],
    targets: [
        .target(
            name: "console_plus",
            path: "../Classes",
            publicHeadersPath: "."
        )
    ]
)
