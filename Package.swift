// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "rogue",
    
    platforms: [
        .macOS(.v12)
    ],
    
    products: [
        .executable(name: "rogue", targets: ["rogue"]),
    ],
    
    targets: [
        .executableTarget(
            name: "rogue",
            dependencies: ["domain", "controller", "presentation", "data", "services"],
            path: "Sources",
            sources: ["main.swift"],
            linkerSettings: [
                .linkedLibrary("ncurses")
            ]
        ),

        .target(
            name: "domain",
            dependencies: ["data"],
            path: "Sources/domain"
        ),
        
        .target(
            name: "presentation",
            path: "Sources/presentation"
        ), 

        .target(
            name: "controller",
            dependencies: ["presentation", "domain", "services"],
            path: "Sources/controller"
        ),
        
        .target(
            name: "data",
            path: "Sources/data"
        ),
        
        .target(
            name: "services",
            dependencies: ["presentation", "domain", "data"],
            path: "Sources/services"
        )
    ]
)
