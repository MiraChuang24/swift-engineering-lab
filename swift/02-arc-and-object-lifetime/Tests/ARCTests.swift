//
//  ARCTests.swift
//  SwiftEngineeringLab
//
//  Created by Wen-Yu Chuang on 2026/10/16.
//

import Testing

// 觀察方式：
// 1. weak probe：weak 不增加引用計數，實例被釋放時自動變成 nil，因此 `probe == nil` 就代表實例已釋放。
// 2. EventRecorder：在 deinit 中記錄事件，可以驗證「是否執行」與「執行順序」。

@Suite("02 ARC 與實例生命週期")
struct ARCTests {

    // MARK: - A：Strong Reference 與實例生命週期

    @Test("A：清除其中一個強引用，實例仍存在；最後一個強引用消失才執行 deinit")
    func strongReference_releasedOnlyAfterLastReferenceCleared() {
        let recorder = EventRecorder()
        var a: StrongReference.Pet? = StrongReference.Pet(recorder: recorder)
        var b = a
        weak var probe = a

        a = nil
        #expect(probe != nil)            // b 還持有
        #expect(b != nil)
        #expect(recorder.events.isEmpty) // 尚未 deinit

        b = nil
        #expect(probe == nil)            // 最後一個強引用消失 → 釋放
        #expect(recorder.events == ["Pet deinit"])
    }

    // MARK: - B：Strong Reference Cycle

    @Test("B：互相強引用時，外部變數都設為 nil 也不會執行 deinit；手動斷開後才釋放")
    func strongCycle_preventsDeinit_untilCycleBroken() {
        let recorder = EventRecorder()
        var owner: StrongCycle.Owner? = StrongCycle.Owner(recorder: recorder)
        var pet: StrongCycle.Pet? = StrongCycle.Pet(recorder: recorder)
        owner?.pet = pet
        pet?.owner = owner

        weak var ownerProbe = owner
        weak var petProbe = pet

        owner = nil
        pet = nil
        // 外部已無任何變數，但兩者互相持有，計數都不為 0 → 洩漏
        #expect(ownerProbe != nil)
        #expect(petProbe != nil)
        #expect(recorder.events.isEmpty)

        // 手動斷開 Owner → Pet：Pet 先釋放，連帶放開它對 Owner 的強引用，Owner 接著釋放
        ownerProbe?.pet = nil
        #expect(petProbe == nil)
        #expect(ownerProbe == nil)
        #expect(recorder.events == ["Pet deinit", "Owner deinit"])
    }

    // MARK: - C：Weak Reference 與自動歸零

    @Test("C：Pet.owner 改為 weak 後，Owner 可以被釋放，pet.owner 自動變成 nil")
    func weakBackReference_releasesOwner_andZeroesReference() {
        var owner: WeakBackReference.Owner? = WeakBackReference.Owner()
        var pet: WeakBackReference.Pet? = WeakBackReference.Pet()
        owner?.pet = pet
        pet?.owner = owner

        weak var ownerProbe = owner
        weak var petProbe = pet

        owner = nil
        // Owner 只被 pet.owner 弱引用 → 立即釋放
        #expect(ownerProbe == nil)
        #expect(pet?.owner == nil)  // weak 被自動設為 nil
        #expect(petProbe != nil)    // pet 變數仍強持有

        pet = nil
        #expect(petProbe == nil)
    }

    // MARK: - D：Unowned Reference 與生命週期契約

    @Test("D：Pet 以 unowned 指向 Owner，Owner 存活時可安全存取，釋放時不會形成循環")
    func unownedBackReference_safeWhileOwnerAlive_andNoCycle() {
        let recorder = EventRecorder()
        var owner: UnownedBackReference.Owner? = UnownedBackReference.Owner(recorder: recorder)
        owner?.pet = UnownedBackReference.Pet(owner: owner!, recorder: recorder)

        weak var ownerProbe = owner
        weak var petProbe = owner?.pet

        // Owner 仍存活：unowned 可直接存取，不需要解包
        #expect(owner?.pet?.owner === owner)

        owner = nil
        // unowned 不增加計數 → Owner 釋放，連帶釋放只被它持有的 Pet
        #expect(ownerProbe == nil)
        #expect(petProbe == nil)
        #expect(recorder.events == ["Owner deinit", "Pet deinit"])
    }

    // MARK: - E：生命週期不符合預期時的 Weak Reference 與 Unowned Reference

    @Test("E-1：Pet 比 Owner 活得久時，weak 會變成 nil")
    func petOutlivesOwner_weakBecomesNil() {
        var owner: WeakBackReference.Owner? = WeakBackReference.Owner()
        let pet = WeakBackReference.Pet()
        pet.owner = owner

        owner = nil
        #expect(pet.owner == nil)   // 安全：讀到 nil
    }

    @Test("E-2：Pet 比 Owner 活得久時，存取 unowned 會觸發 runtime trap")
    func petOutlivesOwner_unownedTraps() async {
        // 在子行程中執行，crash 不會影響其他測試
        await #expect(processExitsWith: .failure) {
            var owner: UnownedBackReference.Owner? = UnownedBackReference.Owner()
            let pet = UnownedBackReference.Pet(owner: owner!)

            owner = nil
            _ = pet.owner   // Owner 已釋放 → trap
        }
    }

    // MARK: - F：Closure 的 Strong Reference Cycle

    @Test("F-1：實例保存的 closure 強捕獲 self，形成循環，實例無法釋放")
    func closureStrongCapture_createsCycle() {
        var owner: ClosureCycle.Owner? = ClosureCycle.Owner()
        owner?.setUpStrongCapture()
        weak var probe = owner

        owner = nil
        #expect(probe != nil)   // Owner → onFeed → Owner

        probe?.onFeed = nil     // 手動斷開 closure
        #expect(probe == nil)
    }

    @Test("F-2：改用 [weak self]，closure 不延長生命週期，實例可以釋放")
    func closureWeakCapture_breaksCycle() {
        var owner: ClosureCycle.Owner? = ClosureCycle.Owner()
        owner?.setUpWeakCapture()
        weak var probe = owner

        owner?.onFeed?()
        #expect(owner?.feedCount == 1)  // 存活時正常運作

        owner = nil
        #expect(probe == nil)
    }

    // MARK: - G：Closure Capture List 的選擇

    @Test("G-1：同步、non-escaping closure 強捕獲 self 不會造成循環")
    func nonEscapingClosure_strongCaptureIsFine() {
        let recorder = EventRecorder()
        var owner: CaptureStrategy.Owner? = CaptureStrategy.Owner(recorder: recorder)
        weak var probe = owner

        owner?.feed(times: 3)
        #expect(owner?.feedCount == 3)

        owner = nil
        #expect(probe == nil)
    }

    @Test("G-2：closure 由 self 保存、不會比 self 活得久時，[unowned self] 安全且不形成循環")
    func storedClosure_unownedCaptureIsSafe() {
        let recorder = EventRecorder()
        var owner: CaptureStrategy.Owner? = CaptureStrategy.Owner(recorder: recorder)
        owner?.setUpUnownedCapture()
        weak var probe = owner

        owner?.onFeed?()
        #expect(owner?.feedCount == 1)

        owner = nil
        #expect(probe == nil)
    }

    @Test("G-3：交給外部佇列並強捕獲，實例會活到工作執行完；適合「一定要完成」的工作")
    func externalQueue_strongCaptureExtendsLifetime() {
        let recorder = EventRecorder()
        let queue = CaptureStrategy.TaskQueue()
        var owner: CaptureStrategy.Owner? = CaptureStrategy.Owner(recorder: recorder)
        owner?.scheduleSaveStrong(on: queue)
        weak var probe = owner

        owner = nil
        #expect(probe != nil)   // 佇列中的 closure 仍持有 Owner，但這不是循環

        queue.runAll()          // 工作執行完、closure 被移除
        #expect(probe == nil)
        #expect(recorder.events == ["saved", "Owner deinit"])
    }

    @Test("G-4：交給外部佇列並使用 [weak self]，實例先釋放時工作會被略過")
    func externalQueue_weakCaptureSkipsWork() {
        let recorder = EventRecorder()
        let queue = CaptureStrategy.TaskQueue()
        var owner: CaptureStrategy.Owner? = CaptureStrategy.Owner(recorder: recorder)
        owner?.scheduleSaveWeak(on: queue)
        weak var probe = owner

        owner = nil
        #expect(probe == nil)   // 立即釋放

        queue.runAll()
        #expect(recorder.events == ["Owner deinit"])  // 沒有 "saved"
    }
}
