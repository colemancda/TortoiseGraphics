import Foundation
import CoreGraphics

public class ImageCanvas: Canvas, TortoiseDelegate {

    public init(size: Vec2D, scale: Double = 1, color: Color? = nil) {
        self.canvasSize = size
        self.canvasColor = color ?? ColorPalette.white.color
        self.bitmapScale = CGFloat(scale)
        self.bitmapContext = createForegroundContext(size: size.toCGSize(),
                                                     scale: self.bitmapScale)
    }

    public var cgImage: CGImage? {
        let size = canvasSize.toCGSize()
        let bgContext = createBackgroundContext(size: size, scale: bitmapScale)
        bgContext?.setFillColor(canvasColor.toCGColor())
        bgContext?.fill(CGRect(origin: .zero, size: size))
        if let fgImage = bitmapContext?.makeImage() {
            bgContext?.draw(fgImage, in: CGRect(origin: .zero, size: size))
        }
        return bgContext?.makeImage()
    }

    // MARK: - Canvas

    public func add(_ tortoise: Tortoise) {
        guard tortoise.delegate !== self else { return }
        tortoise.delegate?.tortoiseDidAddToOtherCanvas(id: tortoise.id, state: tortoise.state)
        tortoise.delegate = self
        tortoiseDidInitialize(id: tortoise.id, state: tortoise.state)
    }

    public var canvasSize: Vec2D

    public func canvasColor(_ palette: ColorPalette) {
        canvasColor = palette.color
    }

    public func canvasColor(_ r: Double, _ g: Double, _ b: Double) {
        canvasColor = Color(r, g, b)
    }

    public func canvasColor(_ hex: String) {
        canvasColor = Color(hex)
    }

    public func canvasColor(_ color: Color) {
        canvasColor = color
    }

    public private(set) var canvasColor: Color

    // MARK: - TortoiseDelegate

    func tortoiseDidInitialize(id: UUID, state: TortoiseState) {
    }

    func tortoiseDidChangeState(id: UUID, oldState: TortoiseState, newState: TortoiseState) {
        // Stroke path
        if oldState.position != newState.position, newState.pen.isDown {
            bitmapContext?.saveGState()
            bitmapContext?.setStrokeColor(newState.pen.color.toCGColor())
            bitmapContext?.setFillColor(CGColor.clear)
            bitmapContext?.setLineWidth(CGFloat(newState.pen.width))
            bitmapContext?.addPath([oldState.position, newState.position].toCGPath())
            bitmapContext?.strokePath()
            bitmapContext?.restoreGState()
        }

        // Fill path
        if newState.fillPath == nil, let oldFillPath = oldState.fillPath {
            bitmapContext?.saveGState()
            bitmapContext?.setStrokeColor(CGColor.clear)
            bitmapContext?.setFillColor(newState.pen.fillColor.toCGColor())
            bitmapContext?.addPath(oldFillPath.toCGPath())
            bitmapContext?.fillPath(using: .evenOdd)
            bitmapContext?.restoreGState()
        }

    }

    func tortoiseDidRequestToClear(id: UUID) {
        bitmapContext = createForegroundContext(size: canvasSize.toCGSize(),
                                                scale: bitmapScale)
    }

    func tortoiseDidAddToOtherCanvas(id: UUID, state: TortoiseState) {
    }

    // MARK: - Internal

    func drawImage(_ image: CGImage, in rect: CGRect) {
        bitmapContext?.draw(image, in: rect)
    }

    // MARK: - Private

    private var bitmapContext: CGContext?

    private let bitmapScale: CGFloat

}

private func createBackgroundContext(size: CGSize, scale: CGFloat) -> CGContext? {
    let width = Int(size.width * scale)
    let height = Int(size.height * scale)
    guard width > 0, height > 0 else { return nil }

    let context = CGContext(data: nil,
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: width * 4,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
    // swiftlint:disable:previous force_unwrapping
    context.scaleBy(x: scale, y: scale)
    return context
}

private func createForegroundContext(size: CGSize, scale: CGFloat) -> CGContext? {
    let context = createBackgroundContext(size: size, scale: scale)
    context?.translateBy(x: size.width * 0.5, y: size.height * 0.5)
    return context
}
