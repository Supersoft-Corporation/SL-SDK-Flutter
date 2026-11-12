// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "softlink_flutter",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "softlink-flutter", targets: ["softlink_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "softlink_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                .linkedFramework("StoreKit")
            ]
        )
    ]
)
