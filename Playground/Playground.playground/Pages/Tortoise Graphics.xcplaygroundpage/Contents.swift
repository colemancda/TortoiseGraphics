//: # 🐢 Tortoise Graphics
import PlaygroundSupport
import TortoiseGraphics

let 🐢 = Tortoise()

let canvas = XCPlaygroundCanvas(size: Vec2D(300, 300))
canvas.add(🐢)
PlaygroundPage.current.liveView = canvas

🐢.penUp()
🐢.back(100)
🐢.penDown()

// Turtle Star!
🐢.penColor(.blue)
🐢.fillColor(.deepPurple)
🐢.beginFill()
🐢.repeat(36) {
    🐢.forward(200)
    🐢.left(170)
}
🐢.endFill()
