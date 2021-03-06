// LogKitTests.swift
//
// Copyright (c) 2015 - 2016, Justin Pawela & The LogKit Project
// http://www.logkit.info/
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import Foundation
import XCTest
@testable import HyperLogKit


class PriorityLevelTests: XCTestCase {

    func testPriorities() {
        XCTAssertEqual(LXPriorityLevel.Error, LXPriorityLevel.Error, "LXPriorityLevel: .Error != .Error")
        XCTAssertNotEqual(LXPriorityLevel.Info, LXPriorityLevel.Notice, "LXPriorityLevel: .Info == .Notice")
        XCTAssertEqual(
            min(LXPriorityLevel.All, LXPriorityLevel.Debug, LXPriorityLevel.Info, LXPriorityLevel.Notice,
                LXPriorityLevel.Warning, LXPriorityLevel.Error, LXPriorityLevel.Critical, LXPriorityLevel.None),
            LXPriorityLevel.All, "LXPriorityLevel: .All is not minimum")
        XCTAssertLessThan(LXPriorityLevel.Debug, LXPriorityLevel.Info, "LXPriorityLevel: .Debug !< .Info")
        XCTAssertLessThan(LXPriorityLevel.Info, LXPriorityLevel.Notice, "LXPriorityLevel: .Info !< .Notice")
        XCTAssertLessThan(LXPriorityLevel.Notice, LXPriorityLevel.Warning, "LXPriorityLevel: .Notice !< .Warning")
        XCTAssertLessThan(LXPriorityLevel.Warning, LXPriorityLevel.Error, "LXPriorityLevel: .Warning !< .Error")
        XCTAssertLessThan(LXPriorityLevel.Info, LXPriorityLevel.Critical, "LXPriorityLevel: .Error !< .Critical")
        XCTAssertEqual(
            max(LXPriorityLevel.All, LXPriorityLevel.Debug, LXPriorityLevel.Info, LXPriorityLevel.Notice,
                LXPriorityLevel.Warning, LXPriorityLevel.Error, LXPriorityLevel.Critical, LXPriorityLevel.None),
            LXPriorityLevel.None, "LXPriorityLevel: .None is not maximum")
    }

}


class ConsoleEndpointTests: XCTestCase {

    let endpoint = LXConsoleEndpoint()

    func testWrite() {
        self.endpoint.write(string: "Hello from the Console Endpoint!")
    }

}

class FileEndpointTests: XCTestCase {

    var endpoint: LXFileEndpoint?
    let endpointURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("info.hyperlogkit.test", isDirectory: true)!
        .appendingPathComponent("info.hyperlogkit.test.endpoint.file", isDirectory: false)

    override func setUp() {
        super.setUp()
        self.endpoint = LXFileEndpoint(fileURL: self.endpointURL as NSURL, shouldAppend: false)
        XCTAssertNotNil(self.endpoint, "Could not create Endpoint")
    }

    override func tearDown() {
        self.endpoint?.resetCurrentFile()
//        self.endpoint = nil //TODO: do we need an endpoint close method?
//        try! NSFileManager.defaultManager().removeItemAtURL(self.endpointURL)
        //FIXME: crashes because Endpoint has not deinitialized yet
        super.tearDown()
    }

    func testFileURLOutput() {
        print("\(type(of: self)) temporary file URL: \(self.endpointURL.absoluteString)")
    }

    func testRotation() {
        let startURL = self.endpoint?.currentURL
        XCTAssertEqual(self.endpointURL, startURL! as URL, "Endpoint opened with unexpected URL")
        self.endpoint?.rotate()
        XCTAssertEqual(self.endpoint?.currentURL, startURL, "File Endpoint should not rotate files")
    }

    #if !os(watchOS) // watchOS 2 does not support extended attributes
    func testXAttr() {
        let key = "info.hyperlogkit.endpoint.FileEndpoint"
        let path = self.endpoint?.currentURL.path
        XCTAssertGreaterThanOrEqual(getxattr(path!, key, nil, 0, 0, 0), 0, "The xattr is not present")
        XCTAssertEqual(removexattr(path!, key, 0), 0, "The xattr could not be removed")
    }
    #endif

    func testWrite() {
        let testString = "Hello 👮🏾 from the File Endpoint!"
        let writeCount = Array(1...4)
        writeCount.forEach({ _ in self.endpoint?.write(string: testString) })
        let bytes = writeCount.flatMap({ _ in testString.utf8 })
        let canonical = NSData(bytes: bytes, length: bytes.count)
        let _ = self.endpoint?.barrier() // Doesn't return until the writes are finished.
        XCTAssert(NSData(contentsOf: self.endpoint!.currentURL as URL)!.isEqual(to: canonical as Data))
    }

}

class RotatingFileEndpointTests: XCTestCase {

    var endpoint: LXRotatingFileEndpoint?
    let endpointURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("info.hyperlogkit.test", isDirectory: true)!
        .appendingPathComponent("info.hyperlogkit.test.endpoint.rotatingFile", isDirectory: false)

    override func setUp() {
        super.setUp()
        self.endpoint = LXRotatingFileEndpoint(baseURL: self.endpointURL as NSURL, numberOfFiles: 5)
        XCTAssertNotNil(self.endpoint, "Could not create Endpoint")
    }

    override func tearDown() {
        self.endpoint?.resetCurrentFile()
        super.tearDown()
    }

    func testRotation() {
        let startURL = self.endpoint?.currentURL
        self.endpoint?.rotate()
        XCTAssertNotEqual(self.endpoint?.currentURL, startURL, "URLs should not match after just one rotation")
        self.endpoint?.rotate()
        self.endpoint?.rotate()
        self.endpoint?.rotate()
        self.endpoint?.rotate()
        XCTAssertEqual(self.endpoint?.currentURL, startURL, "URLs don't match after full rotation cycle")
    }

    #if !os(watchOS) // watchOS 2 does not support extended attributes
    func testXAttr() {
        let key = "info.hyperlogkit.endpoint.RotatingFileEndpoint"
        var path = self.endpoint?.currentURL.path
        XCTAssertGreaterThanOrEqual(getxattr(path!, key, nil, 0, 0, 0), 0, "The xattr is not present")
        XCTAssertEqual(removexattr(path!, key, 0), 0, "The xattr could not be removed")
        self.endpoint?.rotate()
        path = self.endpoint?.currentURL.path
        XCTAssertGreaterThanOrEqual(getxattr(path!, key, nil, 0, 0, 0), 0, "The xattr is not present")
        XCTAssertEqual(removexattr(path!, key, 0), 0, "The xattr could not be removed")
    }
    #endif

    func testWrite() {
        self.endpoint?.resetCurrentFile()
        let testString = "Hello 🎅🏽 from the Rotating File Endpoint!"
        let writeCount = Array(1...4)
        writeCount.forEach({ _ in self.endpoint?.write(string: testString) })
        let bytes = writeCount.flatMap({ _ in testString.utf8 })
        let canonical = NSData(bytes: bytes, length: bytes.count)
        let _ = self.endpoint?.barrier() // Doesn't return until the writes are finished.
        XCTAssert(NSData(contentsOf: self.endpoint!.currentURL as URL)!.isEqual(to: canonical as Data))
    }

}

class DatedFileEndpointTests: XCTestCase {

    var endpoint: LXDatedFileEndpoint?
    let endpointURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("info.hyperlogkit.test", isDirectory: true)!
        .appendingPathComponent("info.hyperlogkit.test.endpoint.datedFile", isDirectory: false)

    override func setUp() {
        super.setUp()
        self.endpoint = LXDatedFileEndpoint(baseURL: self.endpointURL as NSURL)
        XCTAssertNotNil(self.endpoint, "Could not create Endpoint")
    }

    override func tearDown() {
        self.endpoint?.resetCurrentFile()
        super.tearDown()
    }

    func testRotation() {
        let startURL = self.endpoint?.currentURL
        self.endpoint?.rotate()
        XCTAssertEqual(self.endpoint?.currentURL, startURL, "Dated File Endpoint should not manually rotate files")
    }

    #if !os(watchOS) // watchOS 2 does not support extended attributes
    func testXAttr() {
        let key = "info.hyperlogkit.endpoint.DatedFileEndpoint"
        let path = self.endpoint?.currentURL.path
        XCTAssertGreaterThanOrEqual(getxattr(path!, key, nil, 0, 0, 0), 0, "The xattr is not present")
        XCTAssertEqual(removexattr(path!, key, 0), 0, "The xattr could not be removed")
    }
    #endif

    func testWrite() {
        self.endpoint?.resetCurrentFile()
        let testString = "Hello 👷🏼 from the Dated File Endpoint!"
        let writeCount = Array(1...4)
        writeCount.forEach({ _ in self.endpoint?.write(string: testString) })
        let bytes = writeCount.flatMap({ _ in testString.utf8 })
        let canonical = NSData(bytes: bytes, length: bytes.count)
        let _ = self.endpoint?.barrier() // Doesn't return until the writes are finished.
        XCTAssert(NSData(contentsOf: self.endpoint!.currentURL as URL)!.isEqual(to: canonical as Data))
    }
    
}

class HTTPEndpointTests: XCTestCase {

    let endpoint = LXHTTPEndpoint(URL: NSURL(string: "https://httpbin.org/post/")!, HTTPMethod: "POST")

    func testWrite() {
        self.endpoint.write(string: "Hello from the HTTP Endpoint!")
    }

}

class DataBaseEndpointTests: XCTestCase{
    
    let endpoint = LXDataBaseEndpoint()
    
    func testWrite() {
        self.endpoint.write(string: "Hello from the DataBase Endpoint!")
    }
}

class LoggerTests: XCTestCase {

    var log: LXLogger?
    var fileEndpoint: LXFileEndpoint?
    let endpointURL = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("info.hyperlogkit.test", isDirectory: true)!
        .appendingPathComponent("info.hyperlogkit.test.logger", isDirectory: false)
    let entryFormatter = LXEntryFormatter({ e in "[\(e.level.uppercased())] \(e.message)" }) // Nothing variable.

    override func setUp() {
        super.setUp()
        self.fileEndpoint = LXFileEndpoint(fileURL: self.endpointURL as NSURL, shouldAppend: false, entryFormatter: self.entryFormatter)
        XCTAssertNotNil(self.fileEndpoint, "Failed to init File Endpoint")
        self.log = LXLogger(endpoints: [ self.fileEndpoint, ])
        XCTAssertNotNil(self.log, "Failed to init Logger")
    }

    override func tearDown() {
        self.fileEndpoint?.resetCurrentFile()
        super.tearDown()
    }

    func testLog() {
        self.log?.debug(message: "debug")
        self.log?.info(message: "info")
        self.log?.notice(message: "notice")
        self.log?.warning(message: "warning")
        self.log?.error(message: "error")
        self.log?.critical(message: "critical")

        let targetContent = [
            "[DEBUG] debug", "[INFO] info", "[NOTICE] notice", "[WARNING] warning", "[ERROR] error", "[CRITICAL] critical",
        ].joined(separator: "\n") + "\n"
        
        self.fileEndpoint?.barrier() // Doesn't return until the writes are finished.

        let actualContent = try! String(contentsOf: self.fileEndpoint!.currentURL as URL, encoding: String.Encoding.utf8)

        XCTAssertEqual(actualContent, targetContent, "Output does not match expected output")
    }

}
