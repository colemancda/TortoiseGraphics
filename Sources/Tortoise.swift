//
//  Tortoise.swift
//  TortoiseGraphics
//
//  Created by Tomoki Kobayashi on 2019/07/15.
//

import Foundation
import CoreGraphics

public class Tortoise {

    public init(canvas: Canvas) {
        self.canvas = canvas
        delegate?.initialized(self.state)
    }

    // MARK: - [Motion] Move and Draw

    public func forward(_ distance: Double) {
        let transform = CGAffineTransform(translationX: state.position.x, y: state.position.y)
            .rotated(by: -state.heading.radian)
        let newPosition = CGPoint(x: 0, y: distance).applying(transform)
        setPosition(Double(newPosition.x), Double(newPosition.y))
    }

    public func backword(_ distance: Double) {
        forward(-distance)
    }

    public func right(_ angle: Double) {
        let newHeading = state.heading.degree + CGFloat(angle)
        setHeading(Double(newHeading))
    }

    public func left(_ angle: Double) {
        right(-angle)
    }

    public func setPosition(_ x: Double, _ y: Double) {
        let oldPosition = state.position
        let newPosition = CGPoint(x: x, y: y)
        state.position = newPosition
        state.fillPath?.append(newPosition)
        delegate?.positionChanged(state, from: oldPosition)
    }

    public func setX(_ x: Double) {
        setPosition(x, Double(state.position.y))
    }

    public func setY(_ y: Double) {
        setPosition(Double(state.position.x), y)
    }

    public func setHeading(_ heading: Double) {
        let oldHeading = state.heading
        state.heading = Degree(state.heading.degree + CGFloat(heading))
        delegate?.headingChanged(state, from: oldHeading)

    }

    public func home() {
        // TODO: impl
    }

    public func dot(_ size: Double? = nil) {
        // TODO: impl
    }

    public func circle(_ radius: Double, _ extent: Double = 360, _ steps: Int = 0) {
        // TODO: impl
    }

    public func `repeat`(_ times: Int, _ block: () -> Void) {
        (0 ..< times).forEach { _ in block() }
    }

    // MARK: - [Motion] Tell tortoise's state

    public var position: Vec2D {
        return Vec2D(Double(state.position.x), Double(state.position.y))
    }

    public var pos: Vec2D {
        return position
    }

    public func towards(_ x: Double, _ y: Double) -> Double {
        let tan = CGFloat((y - Double(state.position.y)) / (x - Double(state.position.x)))
        return 90 - Double(Radian(atan(tan)).degree)
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
        return Double(state.heading.value)
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
        let oldPen = state.pen
        state.pen.isDown = true
        delegate?.penChanged(state, from: oldPen)
    }

    public func penUp() {
        let oldPen = state.pen
        state.pen.isDown = false
        delegate?.penChanged(state, from: oldPen)
    }

    public func penSize(_ size: Double) {
        let oldPen = state.pen
        state.pen.width = CGFloat(size)
        delegate?.penChanged(state, from: oldPen)

    }

    public var isDown: Bool {
        return state.pen.isDown
    }

    public var penSize: Double {
        return Double(state.pen.width)
    }

    // MARK: - [Pen control] Color control

    public func penColor(_ color: Color) {
        let oldPen = state.pen
        state.pen.color = color.cgColor
        delegate?.penChanged(state, from: oldPen)
    }

    public func penColor(_ r: Double, _ g: Double, _ b: Double) {
        let oldPen = state.pen
        state.pen.color = CGColor.rgb(CGFloat(r/255), CGFloat(g/255), CGFloat(b/255))
        delegate?.penChanged(state, from: oldPen)
    }

    public func penColor(_ rgb: (r: Double, g: Double, b: Double)) {
        let oldPen = state.pen
        state.pen.color = CGColor.rgb(CGFloat(rgb.r/255), CGFloat(rgb.g/255), CGFloat(rgb.b/255))
        delegate?.penChanged(state, from: oldPen)
    }

    public var penColor: (r: Double, g: Double, b: Double) {
        let rgb = state.pen.color.rgb
        return (r: Double(rgb.0*255), g: Double(rgb.1*255), b: Double(rgb.2*255))
    }

    public func fillColor(_ color: Color) {
        let oldPen = state.pen
        state.pen.fillColor = color.cgColor
        delegate?.penChanged(state, from: oldPen)

    }

    public func fillColor(_ r: Double, _ g: Double, _ b: Double) {
        let oldPen = state.pen
        state.pen.fillColor = CGColor.rgb(CGFloat(r/255), CGFloat(g/255), CGFloat(b/255))
        delegate?.penChanged(state, from: oldPen)
    }

    public func fillColor(_ rgb: (r: Double, g: Double, b: Double)) {
        let oldPen = state.pen
        state.pen.fillColor = CGColor.rgb(CGFloat(rgb.r/255), CGFloat(rgb.g/255), CGFloat(rgb.b/255))
        delegate?.penChanged(state, from: oldPen)
    }

    public var fillColor: (r: Double, g: Double, b: Double) {
        let rgb = state.pen.fillColor.rgb
        return (r: Double(rgb.0*255), g: Double(rgb.1*255), b: Double(rgb.2*255))
    }

    // MARK: - [Pen Control] Filling

    public var filling: Bool {
        return state.fillPath != nil
    }

    public func beginFill() {
        state.fillPath = [state.position]
    }

    public func endFill() {
        delegate?.fillRequested(state)
        state.fillPath = nil
    }

    // MARK: - [Pen control] More drawing control

    public func reset() {
        // TODO: impl
    }

    public func clear() {
        // TODO: impl
    }

    // MARK: - [Tortoise state] Visiblity

    public func showTortoise() {
        var oldShape = state.shape
        state.shape.isVisible = true
        delegate?.shapeChanged(state, from: oldShape)
    }

    public func hideTortoise() {
        var oldShape = state.shape
        state.shape.isVisible = false
        delegate?.shapeChanged(state, from: oldShape)
    }

    public var isVisible: Bool {
        return state.shape.isVisible
    }

    public func shape(_ shape: Shape) {
        var oldShape = state.shape
        state.shape = shape
        delegate?.shapeChanged(state, from: oldShape)
    }

    public var shape: Shape {
        return state.shape
    }

    // MARK: - Internal

    var state: TortoiseState = TortoiseState()

    let canvas: Canvas

    var delegate: TortoiseDelegate? {
        return canvas as? TortoiseDelegate
    }

}
