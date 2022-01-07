import Path
import XCTest

import class Foundation.Bundle

@testable import XopenCore

final class FindXcodeVersionFileTests: XCTestCase {
    func testReadXcodeVersionFileAtSameDirectory() throws {
        try Path.mktemp { tmpdir in
            try (tmpdir / "Package.swift").touch()
            let versionFile = try (tmpdir / Xopen.xcodeVersionFileName).touch()

            let version = "13.0.0"

            try version.write(to: versionFile)

            let readVersion = Xopen.readXcodeVersionFile(at: tmpdir.url)

            XCTAssertNotNil(readVersion)
            XCTAssertEqual(version, readVersion)
        }
    }

    func testFindXcodeVersionFileAtSameDirectory() throws {
        try Path.mktemp { tmpdir in
            let fileURL = try (tmpdir / "Package.swift").touch()
            let versionFile = try (tmpdir / Xopen.xcodeVersionFileName).touch()

            let version = "13.0.0"

            try version.write(to: versionFile)

            let xcodeVersionFile = Xopen.findXcodeVersionFile(openFileURL: fileURL.url)

            XCTAssertNotNil(xcodeVersionFile)
            XCTAssertEqual(xcodeVersionFile, versionFile.url)
        }
    }

    func testFindXcodeVersionFileAtRoot() throws {
        try Path.mktemp { tmpdir in
            let fileURL = try (tmpdir.a.mkdir() / "Package.swift").touch()
            let versionFile = try (tmpdir / Xopen.xcodeVersionFileName).touch()

            let uuidString = UUID().uuidString
            let version = "13.0.0 \(uuidString)"

            print(uuidString)

            try version.write(to: versionFile)

            let xcodeVersionFile = Xopen.findXcodeVersionFile(openFileURL: fileURL.url)

            XCTAssertNotNil(xcodeVersionFile)
            XCTAssertEqual(xcodeVersionFile, versionFile.url)
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
