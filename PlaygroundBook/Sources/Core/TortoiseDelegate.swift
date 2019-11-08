import Foundation

protocol TortoiseDelegate: class {

    func tortoiseDidInitialize(id: UUID, state: TortoiseState)

    func tortoiseDidChangeState(id: UUID, oldState: TortoiseState, newState: TortoiseState)

    func tortoiseDidRequestToClear(id: UUID)

    func tortoiseDidAddToOtherCanvas(id: UUID, state: TortoiseState)

}
