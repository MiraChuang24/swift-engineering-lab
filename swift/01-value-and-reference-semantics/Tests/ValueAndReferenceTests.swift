//
//  ValueAndReferenceTests.swift
//  SwiftEngineeringLab
//
//  Created by Wen-Yu Chuang on 2026/10/15.
//

import Testing

@Suite("01 值與參考語意")
struct ValueAndReferenceTests {

    // MARK: - A：純 struct

    @Test("A：複製 struct 後，兩份值互相獨立")
    func copyingStruct_createsIndependentValue() {
        var productA = Product(name: "iPhone", price: 30000)
        let productB = productA

        productA.name = "iPad"

        #expect(productA.name == "iPad")
        #expect(productB.name == "iPhone")
    }

    // MARK: - B：class

    @Test("B：複製 class 只複製參考，兩個常數指向同一實例")
    func copyingClass_sharesInstance() {
        let a = Person(name: "Cindy", age: 25)
        let b = a

        b.name = "Barney" // b 是 let 也能改：let 鎖的是參考，不是實例內容

        #expect(a === b)
        #expect(a.name == "Barney")
    }

    // MARK: - C：struct 內含 class

    @Test("C：修改共享物件會互相影響；替換參考則不會")
    func structContainingClass_mutateVsReplace() {
        let companyA = Company(name: "Apple", leader: Person(name: "Barney", age: 26))
        var companyB = companyA

        #expect(companyA.leader === companyB.leader)

        // 修改共享實例的內部狀態 → 兩邊都看得到
        companyB.leader.name = "Lydia"
        #expect(companyA.leader.name == "Lydia")

        // 替換 companyB 自己的 leader 參考 → 只改到 companyB
        companyB.leader = Person(name: "Cindy", age: 25)
        #expect(companyA.leader !== companyB.leader)
        #expect(companyA.leader.name == "Lydia")
        #expect(companyB.leader.name == "Cindy")
    }

    // MARK: - D：let 的限制

    @Test("D：let struct 仍可修改其內部 class 實例的狀態")
    func letStruct_canStillMutateReferencedObject() {
        let company = Company(name: "Apple", leader: Person(name: "Cindy", age: 25))

        // 以下皆無法編譯（Swift 6.2 實際錯誤訊息）：
        // company.name = "Google"
        //   ❌ cannot assign to property: 'company' is a 'let' constant
        // company.leader = Person(name: "Bob", age: 30)
        //   ❌ cannot assign to property: 'company' is a 'let' constant
        // company.rename(to: "Google")
        //   ❌ cannot use mutating member on immutable value: 'company' is a 'let' constant

        company.leader.name = "Kon"

        #expect(company.leader.name == "Kon")
    }

    @Test("D：let class 可修改 var 屬性，但不能重新指派")
    func letClass_canMutatePropertiesButNotRebind() {
        let a = Person(name: "BB", age: 37)

        // a = Person(name: "Chine", age: 29)
        //   ❌ cannot assign to value: 'a' is a 'let' constant

        a.name = "Boat"

        #expect(a.name == "Boat")
    }

    // MARK: - E：恢復值語意的三種做法

    @Test("E1：成員全為值型別 → 複製後完全獨立")
    func allValueMembers_restoresValueSemantics() {
        let companyA = CompanyWithValueLeader(name: "Apple", leader: PersonValue(name: "Barney", age: 26))
        var companyB = companyA

        companyB.leader.name = "Lydia"

        #expect(companyA.leader.name == "Barney")
        #expect(companyB.leader.name == "Lydia")
    }

    @Test("E2：不可變 class → 共享也安全，修改必須建立新實例")
    func immutableClass_sharingIsSafe() {
        let companyA = CompanyWithImmutableLeader(name: "Apple", leader: ImmutablePerson(name: "Barney", age: 26))
        var companyB = companyA

        // companyB.leader.name = "Lydia"
        //   ❌ cannot assign to property: 'name' is a 'let' constant
        companyB.leader = companyB.leader.renamed("Lydia")

        #expect(companyA.leader.name == "Barney")
        #expect(companyB.leader.name == "Lydia")
    }

    @Test("E3：Copy-on-Write → 複製時共用儲存體，第一次寫入才複製")
    func copyOnWrite_copiesOnlyOnFirstWrite() {
        let a = CoWPerson(name: "Barney", age: 26)
        var b = a

        #expect(a.storageIdentity == b.storageIdentity) // 尚未寫入：共用，複製成本低

        b.name = "Lydia"

        #expect(a.storageIdentity != b.storageIdentity) // 寫入時偵測到共享 → 複製
        #expect(a.name == "Barney")
        #expect(b.name == "Lydia")
    }

    @Test("E3：唯一持有者寫入時原地修改，不會多複製")
    func copyOnWrite_uniqueOwnerMutatesInPlace() {
        var a = CoWPerson(name: "Barney", age: 26)
        let identityBefore = a.storageIdentity

        a.name = "Lydia"

        #expect(a.storageIdentity == identityBefore)
        #expect(a.name == "Lydia")
    }
}
