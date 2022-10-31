import Foundation
import Path

public struct Tree {

    public struct Report: Equatable {
        let indentLevel: UInt
        let name: String
        let isDirectory: Bool
        let parents: [String]
    }

    let tree: String

    private let directorySuffix = "/"
    private let rootDirectoryMark = "./"
    private let itemPrefixMark = "├── "
    private let lastItemPrefixMark = "└── "
    private let nestSpaces = String(repeating: " ", count: 4)

    public init(string: String) {
        tree = string
    }

    public func parse() -> [Report] {
        var reports: [Report] = []
        parse { a in
            reports.append(a)
        }
        return reports
    }

    public func parse(reporting: @escaping (Report) -> ()) {
        /*
         基本的に行単位で対応。行で分割。

         "├── ", "└── " のどちらかが存在する Index 位置から行末までを取り出す。ここがファイルかフォルダの名前となる。
         ファイルかフォルダの区別は名前の末尾に "/" があるかどうか。

         ネストの深さの検出。
         "│   " の出現回数
         前の処理よりもネストが深くなっているのか浅くなっているのかをトラッキングしておく必要がある

         */

        var currentIndentLevel: UInt = 0
        var parents: [String] =  []
        var lastDir: String? = nil
        tree.enumerateLines { line, _ in
            guard line != rootDirectoryMark else {
                return
            }

            guard let markRange = line.range(of: itemPrefixMark) ?? line.range(of: lastItemPrefixMark) else {
                return
            }

            let indentLevel = UInt(line[line.startIndex..<markRange.lowerBound].count / nestSpaces.count)

            let item = String(line[markRange.upperBound...])
            let isDirectory = item.hasSuffix(directorySuffix)
            let name = item.trimmingCharacters(in: CharacterSet(charactersIn: directorySuffix))

            if currentIndentLevel < indentLevel {
                // インデントが深くなった
                parents.append(lastDir!)
            } else if currentIndentLevel > indentLevel {
                // インデントが浅くなった

                let diff = currentIndentLevel - indentLevel
                parents.removeLast(Int(diff))
            } else {
                // インデントは変わってない

            }

            if isDirectory {
                lastDir = name
            }

            currentIndentLevel = indentLevel

            print(indentLevel, terminator: "\t")
            print(line, terminator: "\t")
            print("\(isDirectory ? "d" : "f")", terminator: "\t")
            print(name)

            reporting(Report(indentLevel: indentLevel, name: name, isDirectory: isDirectory, parents: parents))
        }
    }
}

extension Tree {
//    internal func indentLevel(of input: String) -> UInt {
//        _indentLevel(of: input, currentIndentLevel: 0)
//    }
//
//    private func _indentLevel(of input: String, currentIndentLevel: UInt) -> UInt {
//        guard let range = input.range(of: nestMark) else {
//            return currentIndentLevel
//        }
//
//        return _indentLevel(of: String(input[range.upperBound...]),
//                            currentIndentLevel: currentIndentLevel + 1)
//    }
}

