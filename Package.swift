// swift-tools-version: 6.0
//
//  Package.swift
//  SwiftEngineeringLab
//
//  Created by Wen-Yu Chuang on 2026/10/15.
//

import PackageDescription

// 每個實驗是一個獨立的 test target，測試檔放在該實驗資料夾的 Tests/ 底下。
// 新增實驗時，在 experiments 陣列加一行即可。
let experiments: [(name: String, path: String)] = [
    ("E01ValueAndReferenceTests", "swift/01-value-and-reference-semantics/Tests"),
]

let package = Package(
    name: "SwiftEngineeringLab",
    platforms: [.macOS(.v14)],
    targets: experiments.map { .testTarget(name: $0.name, path: $0.path) }
)
