//: # Let's play with 🐢
//: [👉 Next](@next)
import UIKit
import PlaygroundSupport
import TortoiseGraphics

let size = CGSize(width: 300, height: 300)
let liveView = PlaygroundCanvasLiveView(size: size)
PlaygroundPage.current.liveView = liveView

let 🐢 = Tortoise()
liveView.canvas.add(🐢)


🐢.penUp()
🐢.back(100)
🐢.penDown()

// Turtle Star!
🐢.penColor(.red)
🐢.fillColor(.yellow)
🐢.beginFill()
🐢.repeat(36) {
    🐢.forward(200)
    🐢.left(170)
}
🐢.endFill()
