//
//  Models.swift
//  SwiftEngineeringLab
//
//  Created by Wen-Yu Chuang on 2026/10/16.
//

// 每個實驗一個 enum 命名空間，裡面的角色名稱固定為 Owner / Pet，
// 差異只在「引用的種類」，方便對照。

// MARK: - 觀察工具

/// 依序記錄事件（deinit、closure 執行等），讓生命週期可以用 #expect 驗證，而不是只靠 print。
final class EventRecorder {
    private(set) var events: [String] = []

    func record(_ event: String) {
        events.append(event)
    }
}

// MARK: - 實驗 A：強引用與實例生命週期

enum StrongReference {
    final class Pet {
        private let recorder: EventRecorder?

        init(recorder: EventRecorder? = nil) {
            self.recorder = recorder
        }

        deinit {
            recorder?.record("Pet deinit")
        }
    }
}

// MARK: - 實驗 B：雙向強引用 → 循環

enum StrongCycle {
    final class Owner {
        var pet: Pet?
        private let recorder: EventRecorder?

        init(recorder: EventRecorder? = nil) {
            self.recorder = recorder
        }

        deinit {
            recorder?.record("Owner deinit")
        }
    }

    final class Pet {
        var owner: Owner?
        private let recorder: EventRecorder?

        init(recorder: EventRecorder? = nil) {
            self.recorder = recorder
        }

        deinit {
            recorder?.record("Pet deinit")
        }
    }
}

// MARK: - 實驗 C、E：反向引用改為 weak → 沒有循環

enum WeakBackReference {
    final class Owner {
        var pet: Pet?
    }

    final class Pet {
        weak var owner: Owner?   // 與 StrongCycle 的差異
    }
}

// MARK: - 實驗 D、E：反向引用改為 unowned

enum UnownedBackReference {
    final class Owner {
        var pet: Pet?
        private let recorder: EventRecorder?

        init(recorder: EventRecorder? = nil) {
            self.recorder = recorder
        }

        deinit {
            recorder?.record("Owner deinit")
        }
    }

    final class Pet {
        unowned let owner: Owner   // 非 Optional：建立時就必須有 Owner，之後不會變成 nil
        private let recorder: EventRecorder?

        init(owner: Owner, recorder: EventRecorder? = nil) {
            self.owner = owner
            self.recorder = recorder
        }

        deinit {
            recorder?.record("Pet deinit")
        }
    }
}

// MARK: - 實驗 F：Closure 捕獲 self 造成循環

enum ClosureCycle {
    final class Owner {
        var feedCount = 0
        var onFeed: (() -> Void)?

        /// 預設強捕獲：Owner → onFeed → self（Owner），形成循環
        func setUpStrongCapture() {
            onFeed = {
                self.feedCount += 1
            }
        }

        /// [weak self]：closure 不延長 Owner 的生命週期
        func setUpWeakCapture() {
            onFeed = { [weak self] in
                self?.feedCount += 1
            }
        }
    }
}

// MARK: - 實驗 G：Capture List 的選擇

enum CaptureStrategy {
    /// 外部的工作佇列：保存 escaping closure，之後才執行。
    final class TaskQueue {
        private var jobs: [() -> Void] = []

        func enqueue(_ job: @escaping () -> Void) {
            jobs.append(job)
        }

        func runAll() {
            jobs.forEach { $0() }
            jobs.removeAll()
        }
    }

    final class Owner {
        var feedCount = 0
        var onFeed: (() -> Void)?
        private let recorder: EventRecorder

        init(recorder: EventRecorder) {
            self.recorder = recorder
        }

        /// 同步、non-escaping closure：執行完就結束，不會被保存，強捕獲也不會造成循環
        func feed(times: Int) {
            (0..<times).forEach { _ in
                self.feedCount += 1
            }
        }

        /// closure 由 self 保存，生命週期不會比 self 長 → 適合 [unowned self]
        func setUpUnownedCapture() {
            onFeed = { [unowned self] in
                self.feedCount += 1
            }
        }

        /// 交給外部佇列 + 強捕獲：在工作執行完之前，Owner 都會被延長生命週期
        func scheduleSaveStrong(on queue: TaskQueue) {
            queue.enqueue {
                self.save()
            }
        }

        /// 交給外部佇列 + [weak self]：Owner 若先被釋放，工作會被略過
        func scheduleSaveWeak(on queue: TaskQueue) {
            queue.enqueue { [weak self] in
                self?.save()
            }
        }

        private func save() {
            recorder.record("saved")
        }

        deinit {
            recorder.record("Owner deinit")
        }
    }
}