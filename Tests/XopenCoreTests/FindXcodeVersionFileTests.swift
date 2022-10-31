import Path
import XCTest

import class Foundation.Bundle

@testable import XopenCore

final class FindXcodeVersionFileTests: XCTestCase {
    func testFindXcodeVersionFileAtRoot() throws {
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

            let xcodeVersionFile = Xopen.findXcodeVersionFile(from: root.url)
            XCTAssertEqual(Path(url: xcodeVersionFile!), (root/".xcode-version"))
        }
    }

    func testFindXcodeVersionFileInNestedDirectory() throws {
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

            let xcodeVersionFile = Xopen.findXcodeVersionFile(from: root.url)
            XCTAssertEqual(Path(url: xcodeVersionFile!), (root/".xcode-version"))
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
