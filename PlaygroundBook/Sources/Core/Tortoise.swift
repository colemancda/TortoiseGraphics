import Foundation

public class Tortoise {

    public let name: String

    public init(_ name: String? = nil) {
        self.name = name ?? Tortoise.randomName()
    }

    // MARK: - [Motion] Move and Draw

    public func forward(_ distance: Double) {
        setPosition(state.position.moved(distance, toward: state.heading))
    }

    public func backword(_ distance: Double) {
        forward(-distance)
    }

    public func right(_ angle: Double) {
        let newHeading = state.heading + Angle(angle)
        _setHeading(newHeading)
    }

    public func left(_ angle: Double) {
        right(-angle)
    }

    public func setPosition(_ position: Vec2D) {
        guard state.position != position else { return }
        let oldState = state
        state.position = position
        state.fillPath?.append(position)
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public func setPosition(_ x: Double, _ y: Double) {
        setPosition(x, y)
    }

    public func setX(_ x: Double) {
        setPosition(x, Double(state.position.y))
    }

    public func setY(_ y: Double) {
        setPosition(Double(state.position.x), y)
    }

    public func setHeading(_ heading: Double) {
        _setHeading(Angle(heading))
    }

    public func home() {
        setPosition(0, 0)
        setHeading(0)
    }

    public func circle(_ radius: Double, _ extent: Double = 360, _ steps: Int = 0) {
        let checkedExtent = max(min(extent, 360), 1)

        // Step
        let minSteps = max(Int(checkedExtent / 10), 1)
        let definedSteps = steps <= 0 ? minSteps : min(steps, minSteps)

        // Execute
        let baseAngle = (180 - checkedExtent / Double(definedSteps)) * 0.5
        let leftAngle1 = 90 - baseAngle
        let leftAngleN = 2 * leftAngle1
        let distance = 2 * radius * cos(Angle(baseAngle, .degree).radian)
        for index in 1 ... definedSteps {
            if index == 1 {
                right(-leftAngle1)
            } else {
                right(-leftAngleN)
            }
            forward(distance)
        }
        right(-leftAngle1)
    }

    public func speed(_ speed: Speed) {
        guard state.speed != speed else { return }
        let oldState = state
        state.speed = speed
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    var speed: Speed {
        return state.speed
    }

    public func `repeat`(_ times: Int, _ block: () -> Void) {
        if times > 0 {
            (0 ..< times).forEach { _ in block() }
        }
    }

    // MARK: - [Motion] Tell tortoise's state

    public var position: Vec2D {
        return Vec2D(Double(state.position.x), Double(state.position.y))
    }

    public var pos: Vec2D {
        return position
    }

    public func towards(_ x: Double, _ y: Double) -> Double {
        let tan = (y - state.position.y) / (x - state.position.x)
        return (Angle(90, .degree) - Angle(atan(tan), .radian)).value
    }

    public func towards(_ position: Vec2D) -> Double {
        return towards(position.x, position.y)
    }

    public var xcor: Double {
        return Double(state.position.x)
    }

    public var ycor: Double {
        return Double(state.position.y)
    }

    public var heading: Double {
        return state.heading.value
    }

    public func distance(_ x: Double, _ y: Double) -> Double {
        let distanceX = x - Double(state.position.x)
        let distanceY = y - Double(state.position.y)
        return sqrt(pow(distanceX, 2) + pow(distanceY, 2))
    }

    public func distance(_ position: Vec2D) -> Double {
        return distance(position.x, position.y)
    }

    public func random(_ max: Double) -> Double {
        let upperBound = UInt32(Swift.min(Swift.max(Int64(max), 0), Int64(UInt32.max)))
        return Double(arc4random_uniform(upperBound))
    }

    // MARK: - [Pen control] Drawing state

    public func penDown() {
        guard !state.pen.isDown else { return }
        let oldState = state
        state.pen.isDown = true
        state.strokePath = [state.position]
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public func penUp() {
        guard state.pen.isDown else { return }
        let oldState = state
        state.pen.isDown = false
        state.strokePath = []
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public func penSize(_ size: Double) {
        guard state.pen.width != size else { return }
        let oldState = state
        state.pen.width = size
        state.strokePath = []
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public var isDown: Bool {
        return state.pen.isDown
    }

    public var penSize: Double {
        return Double(state.pen.width)
    }

    // MARK: - [Pen control] Color control

    public func penColor(_ palette: ColorPalette) {
        penColor(palette.color)
    }

    public func penColor(_ r: Double, _ g: Double, _ b: Double) {
        penColor(Color(r, g, b))
    }

    public func penColor(_ hex: String) {
        penColor(Color(hex))
    }

    public func penColor(_ color: Color) {
        guard state.pen.color != color else { return }
        let oldState = state
        state.pen.color = color
        state.strokePath = []
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public var penColor: Color {
        return state.pen.color
    }

    public func fillColor(_ palette: ColorPalette) {
        fillColor(palette.color)
    }

    public func fillColor(_ r: Double, _ g: Double, _ b: Double) {
        fillColor(Color(r, g, b))
    }

    public func fillColor(_ hex: String) {
        fillColor(Color(hex))
    }

    public func fillColor(_ color: Color) {
        guard state.pen.fillColor != color else { return }
        let oldState = state
        state.pen.fillColor = color
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public var fillColor: Color {
        return state.pen.fillColor
    }

    // MARK: - [Pen Control] Filling

    public var filling: Bool {
        return state.fillPath != nil
    }

    public func beginFill() {
        guard !filling else { return }
        let oldState = state
        state.fillPath = [state.position]
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public func endFill() {
        guard filling else { return }
        let oldState = state
        state.fillPath = nil
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    // MARK: - [Pen control] More drawing control

    public func reset() {
        state = TortoiseState()
        delegate?.tortoiseDidRequestToClear(id: id)
        delegate?.tortoiseDidInitialize(id: id, state: state)
    }

    public func clear() {
        delegate?.tortoiseDidRequestToClear(id: id)
    }

    // MARK: - [Tortoise state] Visiblity

    public func showTortoise() {
        guard !state.isVisible else { return }
        let oldState = state
        state.isVisible = true
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public func hideTortoise() {
        guard state.isVisible else { return }
        let oldState = state
        state.isVisible = false
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public var isVisible: Bool {
        return state.isVisible
    }

    public func shape(_ shape: Shape) {
        guard state.shape != shape else { return }
        let oldState = state
        state.shape = shape
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

    public var shape: Shape {
        return state.shape
    }

    // MARK: - Internal

    let id: UUID = UUID()

    var state: TortoiseState = TortoiseState()

    weak var delegate: TortoiseDelegate?

    // MARK: - Private

    private func _setHeading(_ heading: Angle) {
        guard state.heading != heading else { return }
        let oldState = state
        state.heading = heading
        delegate?.tortoiseDidChangeState(id: id, oldState: oldState, newState: state)
    }

}
