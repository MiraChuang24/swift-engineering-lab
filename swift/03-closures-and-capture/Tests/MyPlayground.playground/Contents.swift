import UIKit


//let boss: String = "John"
//
//var closure = {
//    print("Hello, \(boss)! My name is \(employee).")
//}
//
//let employee: String = "Alice"
//closure()

//let name = "Jone"
//var hellowClosure: () -> Void = { [name] in
//    print("Hello, \(name)!")
//}
//var whoClosure: () -> Void = {
//   print("Hello, \(name)!")
//}
//
func cook(name: String, onReady: (String) -> Void) {
    print("開始料理 \(name)")
    onReady(name)
}

// 一般寫法
cook(name: "炒飯", onReady: { dish in
    print("\(dish) 好了，可以上桌！")
})

// 尾隨閉包：最後一個參數是 closure，可以移到括號外
cook(name: "炒飯") { dish in
    print("\(dish) 好了，可以上桌！")
}

cook(name: "炒飯", onReady: { print("\($0) 好了，可以上桌！") })
