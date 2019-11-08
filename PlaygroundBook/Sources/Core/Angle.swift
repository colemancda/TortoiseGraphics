import Foundation

struct Angle: Equatable, Codable {

    static var currentUnit: Unit = .degree

    enum Unit: String, Codable {
        case degree
        case radian
    }

    init(_ value: Double, _ unit: Unit = Angle.currentUnit) {
        switch unit {
        case .degree:
            self.degree = value
        case .radian:
            self.degree = Angle(value, .radian).degree
        }
    }

    let degree: Double

    var radian: Double {
        return degree * (.pi / 180.0)
    }

    var value: Double {
        switch Angle.currentUnit {
        case .degree: return degree
        case .radian: return radian
        }
    }

}

func + (left: Angle, right: Angle) -> Angle {
    return Angle(left.value + right.value)
}

func - (left: Angle, right: Angle) -> Angle {
    return Angle(left.value - right.value)
}
