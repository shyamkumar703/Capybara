import Foundation

extension Array where Element == Position {
    static let `guard`: Self = [.pointGuard, .shootingGuard]
    static let forward: Self = [.smallForward, .powerForward]
    static let bigMan: Self = [.powerForward, .center]
}
