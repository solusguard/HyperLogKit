// swift-tools-version:5.1

// Package.swift
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

import PackageDescription

let package = Package(
        name: "HyperLogKit",
        products: [
            .library(
                    name: "HyperLogKit",
                    targets: ["HyperLogKit"]),
        ],
        platforms: [
            .iOS(.v10),
            .macOS(.v10_10),
            .tvOS(.v9),
            .watchOS(.v2),
        ],
        targets: [
            .target(
                    name: "HyperLogKit",
                    path: "Sources"
            ),
            .testTarget(
                    name: "HyperLogKitTest",
                    path: "Tests"
            )
        ],
        swiftLanguageVersions: [.v5]
)