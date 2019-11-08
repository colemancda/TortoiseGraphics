import Foundation

public struct Color: Equatable, Codable, CustomStringConvertible {

    public var r: Double { convertToCurrentMode(_r) }

    public var g: Double { convertToCurrentMode(_g) }

    public var b: Double { convertToCurrentMode(_b) }

    public let name: String?

    public init(_ r: Double, _ g: Double, _ b: Double, name: String? = nil) {
        self.init(r, g, b, name: name, mode: Color.currentMode)
    }

    public init(_ hex: String, name: String? = nil) {
        let scanner = Scanner(string: hex)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = Double((color & 0xFF0000) >> 16)
            let g = Double((color & 0x00FF00) >> 8)
            let b = Double((color & 0x0000FF) >> 0)
            self.init(r, g, b, name: name ?? hex, mode: .range255)
        } else {
            self.init(0, 0, 0, name: name ?? hex, mode: .range255)
        }
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        return "\(name ?? "") (\(r),\(g),\(b))"
    }

    // MARK: - Internal

    enum Mode: String, Codable {
        case range1
        case range255
    }

    static var currentMode: Mode = .range255

    init(_ r: Double, _ g: Double, _ b: Double, name: String? = nil, mode: Mode) {
        switch mode {
        case .range1:
            self._r = max(0.0, r, min(r, 1.0))
            self._g = max(0.0, g, min(g, 1.0))
            self._b = max(0.0, b, min(b, 1.0))
        case .range255:
            self._r = max(0.0, r, min(r, 255.0)) / 255.0
            self._g = max(0.0, g, min(g, 255.0)) / 255.0
            self._b = max(0.0, b, min(b, 255.0)) / 255.0
        }
        self.name = name
    }

    // MARK: - Private

    private let _r: Double
    private let _g: Double
    private let _b: Double

    private func convertToCurrentMode(_ v: Double) -> Double {
        switch Color.currentMode {
        case .range1: return v
        case .range255: return v * 255.0
        }
    }

}
