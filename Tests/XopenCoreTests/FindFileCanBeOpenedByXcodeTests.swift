import Path
import Bucker
import XCTest

import class Foundation.Bundle

@testable import XopenCore

final class FindFileCanBeOpenedByXcodeTests: XCTestCase {
    func testFindPackageSwiftAtRoot() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── .xcode-version
        ├── Package.swift
        ├── app/
        └── scripts/
        """

        try Path.mktemp(treeString: tree) { root in
            try root.find().execute { path in
                if path.basename() == ".xcode-version" {
                    let version = "13.0.0"
                    try version.write(to: path)
                }
                return .continue
            }

            print(root.url.path)
            print("")

            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"Package.swift"))
        }
    }

    func testFindPackageSwiftInNestedDirectory() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── App/
        │   ├── .xcode-version
        │   └── Package.swift
        ├── Build/
        └── Scripts/
        """

        try Path.mktemp(treeString: tree) { root in
            try root.find().execute { path in
                if path.basename() == ".xcode-version" {
                    let version = "13.0.0"
                    try version.write(to: path)
                }
                return .continue
            }

            print(root.url.path)
            print("")

            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"App"/"Package.swift"))
        }
    }

    func testFindXcrowkspace() throws {
        let tree = """
        ./
        ├── .DS_Store
        ├── .gitignore
        ├── .xcode-version
        ├── GolfScoreCounter/
        │   ├── .DS_Store
        │   ├── App/
        │   │   ├── .DS_Store
        │   │   └── GolfScoreCounter/
        │   │       ├── .DS_Store
        │   │       └── GolfScoreCounter.xcodeproj/
        │   │           ├── project.pbxproj
        │   │           ├── xcshareddata/
        │   │           │   └── xcschemes/
        │   │           │       ├── GolfScoreCounter.xcscheme
        │   │           │       ├── GolfScoreCounterWatch Watch App.xcscheme
        │   │           │       ├── GolfScoreCounterWidgetsExtension.xcscheme
        │   │           │       └── WatchWidgetExtension.xcscheme
        │   │           └── xcuserdata/
        │   │               └── stewie.xcuserdatad/
        │   │                   └── xcschemes/
        │   │                       └── xcschememanagement.plist
        │   └── Package/
        │       ├── .DS_Store
        │       ├── .build/
        │       │   └── .DS_Store
        │       ├── .gitignore
        │       ├── .swiftpm/
        │       │   └── .DS_Store
        │       ├── Package.swift
        │       ├── Sources/
        │       │   ├── .DS_Store
        │       │   └── AppFeature/
        │       │       ├── .DS_Store
        │       │       └── AppLogger.swift
        │       └── Tests/
        │           └── .DS_Store
        ├── GolfScoreCounter.xcworkspace/
        │   ├── contents.xcworkspacedata
        │   ├── xcshareddata/
        │   │   ├── IDEWorkspaceChecks.plist
        │   │   └── swiftpm/
        │   │       └── configuration/
        │   └── xcuserdata/
        │       └── stewie.xcuserdatad/
        │           ├── UserInterfaceState.xcuserstate
        │           └── xcdebugger/
        │               └── Breakpoints_v2.xcbkptlist
        └── README.md
        """

        try Path.mktemp(treeString: tree) { root in
            let url = try Xopen.findFileToOpen(under: root.url)
            XCTAssertEqual(Path(url: url), (root/"GolfScoreCounter.xcworkspace"))
        }
    }
}

/*

 try Path.mktemp { tmpdir in
     try tmpdir.a.touch()
     try tmpdir.b.touch()
     try tmpdir.c.mkdir().join("e").touch()

     do {
         let finder = tmpdir.find().depth(max: 1)
         XCTAssertEqual(finder.depth, 1...1)
       #if !os(Linux) || swift(>=5)
         XCTAssertEqual(Set(finder), Set([tmpdir.a, tmpdir.b, tmpdir.c].map(Path.init)))
       #endif
     }
     do {
         let finder = tmpdir.find().depth(max: 0)
         XCTAssertEqual(finder.depth, 0...0)
       #if !os(Linux) || swift(>=5)
         XCTAssertEqual(Set(finder), Set())
       #endif
     }
 }
 */
