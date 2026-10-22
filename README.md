# Swift Engineering Lab

[![Tests](https://github.com/MiraChuang24/swift-engineering-lab/actions/workflows/test.yml/badge.svg)](https://github.com/MiraChuang24/swift-engineering-lab/actions/workflows/test.yml)

Small, runnable experiments that verify how Swift and iOS actually behave, covering language semantics, memory management, concurrency, and software design. Every conclusion is backed by an automated test (Swift Testing) that runs in CI. Notes are written in Traditional Chinese.

以可執行的小型實驗，整理 Swift 與 iOS 開發中的原理、設計選擇及驗證方法。每個主題記錄**問題 → 預測 → 實驗 → 結果 → 理解修正**，所有結論都有對應的自動化測試。

## 實驗索引

| # | 主題 | 研究問題 | 關鍵收穫 |
| --- | --- | --- | --- |
| 01 | [值與參考語意](swift/01-value-and-reference-semantics/README.md) | 複製 struct、class，以及內含 class 的 struct，分別會發生什麼？ | struct 內含 class 會破壞值語意；比較三種修法，包含自己實作 Copy-on-Write |

## 執行方式

```bash
swift test
```

需要 Xcode 16 以上（Swift 6 / Swift Testing）。每個實驗的實際環境記錄在該實驗的筆記開頭。

## 學習方式

1. 提出具體問題，寫下目前理解與預測。
2. 建立最小可執行實驗，用測試驗證行為。
3. 對照官方文件，修正解釋。
4. 整理實務取捨、小結與延伸問題。

新增實驗請參考 [TEMPLATE.md](TEMPLATE.md)。

## 學習目標

- 複習 Swift 語意、資料結構與記憶體管理。
- 掌握並行、任務生命週期與狀態一致性。
- 練習責任分離、依賴注入與可測試設計。
- 透過測試與除錯工具驗證程式行為。
- 累積能清楚解釋設計取捨的技術紀錄。

## 主題規劃

- Swift 語言基礎與語意
- ARC 與 Closure
- 資料結構與演算法
- Swift Concurrency
- 軟體設計與測試
- iOS 除錯與工程實務

## 目錄結構

```
.
├── Package.swift                 # 登記有 Swift 測試的資料夾，每個是一個 test target
├── TEMPLATE.md                   # 筆記範本
└── swift/                        # Swift
    └── NN-topic-name/
        ├── README.md             # 筆記
        └── Tests/                # 實驗程式與測試（只有需要驗證時才有）
```
