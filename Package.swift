// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Panda",
    platforms: [
      .iOS(.v11) // 指定 iOS 平台
           ],
    products: [
        .library(
            name: "Panda",
            targets: ["Panda"]
        )
    ],
    dependencies: [.package(url: "git@github.com:nangege/Cassowary.git", branch:"master"),
                   .package(url: "git@github.com:nangege/Layoutable.git", branch:"master")],
    targets: [
        .target(
            name: "Panda",
            dependencies: ["Cassowary","Layoutable"],
            path: "Panda"
        ),
        .testTarget(
            name: "PandaTests",
            dependencies: ["Panda"],
            path: "PandaTests"
        )
    ]
)
