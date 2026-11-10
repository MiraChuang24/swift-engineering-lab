//
//  Models.swift
//  SwiftEngineeringLab
//
//  Created by Wen-Yu Chuang on 2026/11/6.
//

enum Closures {
    // 1. Capture List
    struct Kitchen {
        func prepareWithCaptureList(originalDish: String, updatedDish: String) -> String {
            var dish = originalDish
            // 保存建立 closure 當下的 String 值。
            let onReady = { [dish] in
                "\(dish) 好了，可以上桌！"
            }
            dish = updatedDish
            return onReady()
        }

        func prepareWithoutCaptureList(originalDish: String, updatedDish: String) -> String {
            var dish = originalDish
            // 捕獲區域變數 dish，與外部程式碼共用同一份儲存位置。
            let onReady = {
                "\(dish) 好了，可以上桌！"
            }
            dish = updatedDish
            return onReady()
        }
    }

    final class Dish {
        var name: String

        init(name: String) {
            self.name = name
        }
    }
}
