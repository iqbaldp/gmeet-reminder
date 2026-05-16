// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "MeetingReminder",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MeetingReminderApp", targets: ["MeetingReminderApp"]),
        .executable(name: "ScreenshotRenderer", targets: ["ScreenshotRenderer"]),
        .library(name: "MeetingReminderCore", targets: ["MeetingReminderCore"])
    ],
    targets: [
        .target(
            name: "MeetingReminderCore",
            path: "Sources/MeetingReminderCore"
        ),
        .executableTarget(
            name: "MeetingReminderApp",
            dependencies: ["MeetingReminderCore"],
            path: "Sources/MeetingReminderApp"
        ),
        .executableTarget(
            name: "ScreenshotRenderer",
            dependencies: ["MeetingReminderCore"],
            path: "Sources/ScreenshotRenderer"
        ),
        .testTarget(
            name: "MeetingReminderCoreTests",
            dependencies: ["MeetingReminderCore"],
            path: "Tests/MeetingReminderCoreTests"
        )
    ]
)
