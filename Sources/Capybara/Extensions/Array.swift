import Foundation

extension Array where Element == Game {
    func contains(_ team: Team) -> Bool {
        for game in self {
            if game.contains(team) {
                return true
            }
        }

        return false
    }
}

extension Array where Element: Identifiable {
    @discardableResult
    mutating func remove(element: Element) -> Bool {
        for (index, loopElement) in self.enumerated() {
            if loopElement.id == element.id {
                self.remove(at: index)
                return true
            }
        }
        
        return false
    }
}
