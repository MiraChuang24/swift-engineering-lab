//
//  ClosuresTest.swift
//  SwiftEngineeringLab
//
//  Created by 莊雯聿 on 2026/11/10.
//

import Testing

struct ClosureCaptureTests {

    @Test("捕獲列表保留 closure 建立時的 String 值")
    func captureListPreservesOriginalValue() {
        let kitchen = Closures.Kitchen()
        let result = kitchen.prepareWithCaptureList(originalDish: "pizza", updatedDish: "pasta")
        #expect(result == "pizza 好了，可以上桌！")
    }

    @Test("未使用捕獲列表時，closure 讀取修改後的 String 值")
    func implicitCaptureUsesUpdatedValue() {
        let kitchen = Closures.Kitchen()
        let result = kitchen.prepareWithoutCaptureList(originalDish: "pizza", updatedDish: "pasta")
        #expect(result == "pasta 好了，可以上桌！")
    }

    @Test("捕獲物件參考後，仍會讀到同一物件修改後的屬性")
    func capturedReferenceObservesPropertyChanges() {
        let dish = Closures.Dish(name: "pizza")
        let onReady = { [dish] in
            dish.name
        }

        dish.name = "pasta"

        #expect(onReady() == "pasta")
    }

    @Test("捕獲列表保留原本的物件參考，不受外部變數重新指派影響")
    func captureListPreservesOriginalReference() {
        var dish = Closures.Dish(name: "pizza")
        let originalDish = dish
        let capturedDish = { [dish] in
            dish
        }

        dish = Closures.Dish(name: "pasta")

        #expect(capturedDish() === originalDish)
        #expect(capturedDish() !== dish)
        #expect(capturedDish().name == "pizza")
    }

    @Test("未使用捕獲列表時，closure 讀取重新指派後的物件")
    func implicitCaptureUsesReassignedReference() {
        var dish = Closures.Dish(name: "pizza")
        let capturedDish = {
            dish
        }

        dish = Closures.Dish(name: "pasta")

        #expect(capturedDish() === dish)
        #expect(capturedDish().name == "pasta")
    }

    @Test("直接捕獲 String 屬性，可保留物件修改前的名稱")
    func capturingPropertyPreservesOriginalName() {
        let dish = Closures.Dish(name: "pizza")
        let onReady = { [name = dish.name] in
            name
        }

        dish.name = "pasta"

        #expect(onReady() == "pizza")
    }
}
