//
//  Models.swift
//  SwiftEngineeringLab
//
//  Created by Wen-Yu Chuang on 2026/10/15.
//

// MARK: - 實驗 A–D 使用的型別

final class Person {
    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

struct Company {
    var name: String
    var leader: Person

    mutating func rename(to newName: String) {
        name = newName
    }
}

struct Product {
    var name: String
    var price: Int
}

// MARK: - 實驗 E：讓「struct 內含 class」恢復值語意的三種做法

/// 做法 1：把 Person 改成 struct，整個 Company 都是值型別。
struct PersonValue {
    var name: String
    var age: Int
}

struct CompanyWithValueLeader {
    var name: String
    var leader: PersonValue
}

/// 做法 2：class 保留，但所有屬性都是 let，共享也不會被改到。
/// 要「修改」只能建立新實例。
final class ImmutablePerson {
    let name: String
    let age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    func renamed(_ newName: String) -> ImmutablePerson {
        ImmutablePerson(name: newName, age: age)
    }
}

struct CompanyWithImmutableLeader {
    var name: String
    var leader: ImmutablePerson
}

/// 做法 3：Copy-on-Write。內部用 class 儲存（複製很便宜），
/// 寫入前若儲存體被共享，才真正複製一份。Array、String 也是用這個技巧。
struct CoWPerson {
    private final class Storage {
        var name: String
        var age: Int

        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }

    private var storage: Storage

    init(name: String, age: Int) {
        storage = Storage(name: name, age: age)
    }

    var name: String {
        get { storage.name }
        set {
            makeUniqueIfNeeded()
            storage.name = newValue
        }
    }

    var age: Int {
        get { storage.age }
        set {
            makeUniqueIfNeeded()
            storage.age = newValue
        }
    }

    /// 測試用：儲存體的身分，用來觀察是否發生複製。
    var storageIdentity: ObjectIdentifier {
        ObjectIdentifier(storage)
    }

    private mutating func makeUniqueIfNeeded() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = Storage(name: storage.name, age: storage.age)
        }
    }
}
